#import "BJMusiCenterView.h"

@interface CCUISystemControlsPageViewController : UIViewController
@end

@interface UIStackView (UIStackViewArrangedSetter)
- (void)setArrangedSubviews:(NSArray *)subviews;
@end


%hook CCUISystemControlsPageViewController

- (void)_updateSectionViews {
    %orig;
    
    UIStackView *topStackView = [self valueForKey:@"_horizontalStackView"];
    
    NSArray<UIStackView *> *organizingViews = topStackView.arrangedSubviews;
    
    UIStackView *targetStackView = organizingViews.firstObject;
    NSArray<UIView *> *controlCenterViews = targetStackView.arrangedSubviews;
    
    BOOL isLandscape = (organizingViews.count == 3);
    BOOL portraitSetup = (controlCenterViews.firstObject.class == BJMusiCenterView.class);
    
    if (isLandscape == portraitSetup) {
        if (isLandscape) {
            controlCenterViews = @[controlCenterViews.lastObject];
        } else {
            UIView *toggles    = controlCenterViews[0];
            UIView *brightness = controlCenterViews[1];
            UIView *airstuff   = controlCenterViews[2];
            UIView *nightshift = controlCenterViews[3];
            UIView *shortcuts  = controlCenterViews[4];
            
            static BJMusiCenterView *musicView = NULL;
            if (!musicView) {
                musicView = [[BJMusiCenterView alloc] initWithFrame:nightshift.frame];
            }
            controlCenterViews = @[musicView, toggles, brightness, airstuff, shortcuts];
        }
        
        [targetStackView setArrangedSubviews:controlCenterViews];
    }
}

%end

%hook MPUControlCenterMediaControlsViewController

%new
- (BOOL)wantsVisible {
    return NO;
}

%end

// Hide the night shift view that's still around even though we removed it form the stack view
%hook CCUINightShiftContentView

- (void)setHidden:(BOOL)hidden {
    %orig(YES);
}

- (BOOL)isHidden {
    return YES;
}

%end
