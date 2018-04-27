#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface SBAlertItem : NSObject
- (void)dismiss;
@end

@interface BJSBAlertItem : SBAlertItem

@property (nonatomic) NSArray<UIAlertAction *> *alertActions;
@property (nonatomic) NSString *alertTitle;

- (void)present;

@end

@interface SBDisplayItem : NSObject
@property (nonatomic, copy, readonly) NSString *displayIdentifier;
@end

@interface SBDeckSwitcherItemContainer : UIView
@property (nonatomic, readonly) SBDisplayItem *displayItem;
@end

@interface SBDeckSwitcherViewController : UIViewController
- (void)killDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container withVelocity:(CGFloat)velocity;
@end

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end


// Used to make sure another alert isn't triggered while one is already showing
static BOOL showingAlert;

/// The container is for an app which is the NowPlaying app
static BOOL isContainerNowPlayingApp(SBDeckSwitcherItemContainer *container) {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    return [container.displayItem.displayIdentifier isEqualToString:mediaController.nowPlayingApplication.bundleIdentifier];
}


%hook SBDeckSwitcherViewController

- (BOOL)isDisplayItemOfContainerRemovable:(SBDeckSwitcherItemContainer *)container {
    return isContainerNowPlayingApp(container) ? NO : %orig;
}

- (void)scrollViewKillingProgressUpdated:(CGFloat)progress ofContainer:(SBDeckSwitcherItemContainer *)container {
    %orig;
    
    if ((progress > 0.2) && isContainerNowPlayingApp(container) && !showingAlert) {
        showingAlert = YES;
        
        BJSBAlertItem *sbAlert = [objc_getClass("BJSBAlertItem") new];
        
        sbAlert.alertTitle = @"Are you sure you'd like to close the now playing app?";
        sbAlert.alertActions = @[[UIAlertAction actionWithTitle:@"No, Keep" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [sbAlert dismiss];
            showingAlert = NO;
        }], [UIAlertAction actionWithTitle:@"Yes, Close" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self killDisplayItemOfContainer:container withVelocity:1.0];
            [sbAlert dismiss];
            showingAlert = NO;
        }]];
        
        [sbAlert present];
    }
}

%end
