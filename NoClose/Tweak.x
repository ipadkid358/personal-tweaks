#import <UIKit/UIKit.h>

@interface SBAlertItem : NSObject
- (void)dismiss;
@end

@interface BJSBAlertItem : SBAlertItem

@property (nonatomic) NSArray<UIAlertAction *> *alertActions;
@property (nonatomic) NSString *alertTitle;

- (void)present;

@end

@interface SBDisplayItem : NSObject
@property (nonatomic, readonly) NSString *displayIdentifier;
@end

@interface SBDeckSwitcherItemContainer
@property(readonly, retain, nonatomic) SBDisplayItem *displayItem;
@end

@interface SBDeckSwitcherViewController
- (void)killDisplayItemOfContainer:(SBDeckSwitcherItemContainer *)container withVelocity:(CGFloat)velocity;
@end

@interface SBApplication : NSObject
- (NSString *)displayIdentifier;
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end

// Used to make sure another alert isn't triggered while one is already showing
static BOOL showingAlert;

%hook SBDeckSwitcherViewController

- (BOOL)isDisplayItemOfContainerRemovable:(SBDeckSwitcherItemContainer *)container {
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    if ([container.displayItem.displayIdentifier isEqualToString:mediaController.nowPlayingApplication.displayIdentifier]) {
        return NO;
    } else {
        return %orig;
    }
}

- (void)scrollViewKillingProgressUpdated:(CGFloat)progress ofContainer:(SBDeckSwitcherItemContainer *)container {
    %orig;
    
    SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
    if ((progress > 0.2) && [container.displayItem.displayIdentifier isEqualToString:mediaController.nowPlayingApplication.displayIdentifier] && !showingAlert) {
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
