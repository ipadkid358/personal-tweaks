#import <UIKit/UIKit.h>
#import <Flipswitch/Flipswitch.h>
#import <dlfcn.h>

@interface CCUIControlCenterPagePlatterView : UIView
@end

@interface _UIBackdropView : UIView
@property (nonatomic, retain) UIView *colorTintView;
@end

@interface NCMaterialView : UIView
@end

@interface MPUMediaRemoteControlsView : UIView
@end

@interface MPUControlCenterMediaControlsView : MPUMediaRemoteControlsView
@end

@interface MPAVRoutingTableViewCell : UITableViewCell
@end

@interface CAFilter : NSObject
+ (instancetype)filterWithType:(NSString *)type;
@end

@interface MPAVRoutingViewController : UIViewController
@end

@interface _FSSwitchButton : UIButton
@end


static CAFilter *invertFilter = NULL;

// For safety reasons, flipswitch classes are hooked inside a different group
%group FlipSwitchHooks

// set off switches to a grayed out "disabled" color, and white if they're on
%hook _FSSwitchButton

- (void)displayLayer:(CALayer *)layer {
    %orig;
    
    FSSwitchPanel *sharedPanel = [%c(FSSwitchPanel) sharedPanel];
    FSSwitchState switchState = [sharedPanel stateForSwitchIdentifier:[self valueForKey:@"switchIdentifier"]];
    CALayer *thisLayer = self.layer;
    
    if (switchState == FSSwitchStateOn) {
        thisLayer.filters = NULL;
    } else if (!thisLayer.filters.count) {
        thisLayer.filters = @[invertFilter];
    }
}

%end

%end /* FlipSwitchHooks */

// Remove the odd cut-out that control center pages have
%hook CCUIControlCenterPagePlatterView

- (id)initWithDelegate:(id)arg1 {
    if ((self = %orig)) {
        UIImageView *cutoutView = [self valueForKey:@"_whiteLayerView"];
        cutoutView.hidden = YES;
    }
    
    return self;
}

// set the main background view to black color
- (void)layoutSubviews {
    %orig;
    
    NCMaterialView *materialView = [self valueForKey:@"_baseMaterialView"];
    _UIBackdropView *backdrop = [materialView valueForKey:@"_backdropView"];
    UIView *colorView = backdrop.colorTintView;
    colorView.backgroundColor = UIColor.blackColor;
}

%end

// set the background color of the table view to the same color we set the rest of the control center above
%hook MPUControlCenterMediaControlsView

- (void)layoutSubviews {
    %orig;
    
    UIView *introspectView = self.subviews[1];
    UIView *routingView = introspectView.subviews.firstObject;
    UITableView *tableView = routingView.subviews.firstObject;
    NCMaterialView *materialView = tableView.subviews.firstObject;
    _UIBackdropView *backdrop = [materialView valueForKey:@"_backdropView"];
    UIView *colorView = backdrop.colorTintView;
    colorView.backgroundColor = UIColor.blackColor;
}

%end

// make sure all labels are white color
%hook CCUIControlCenterLabel

- (void)setTextColor:(UIColor *)color {
    %orig(UIColor.whiteColor);
}

%end

// this handles turning a lot of elements a lighter color, mostly filters are not applied to labels and sliders
%hook CCUIControlCenterVisualEffect

- (id)initWithPrivateStyle:(NSInteger)style {
    return %orig(1);
}

%end

// invert colors on the cells of the audio route picker
%hook MPAVRoutingViewController

- (MPAVRoutingTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPAVRoutingTableViewCell *ret = %orig;
    ret.layer.filters = @[invertFilter];
    return ret;
}

%end

%ctor {
    // if the flipswitch library is able to be opened in SpringBoard, setup those hooks
    void *flipswitch = dlopen("/usr/lib/libflipswitch.dylib", RTLD_NOW);
    if (flipswitch) {
        %init(FlipSwitchHooks);
        dlclose(flipswitch);
    }
    
    // this filter is used a fair amount, so we'll just create it once here
    invertFilter = [CAFilter filterWithType:@"colorInvert"];
    
    %init;
}
