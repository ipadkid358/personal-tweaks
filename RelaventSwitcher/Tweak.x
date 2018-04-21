#import <UIKit/UIKit.h>

@interface SBApplication : NSObject
- (BOOL)isRunning;
@end

@interface SBApplicationController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)identifier;
@end

@interface SBDisplayItem : NSObject
- (NSString *)displayIdentifier;
@end

%hook SBAppSwitcherModel

- (NSArray<SBDisplayItem *> *)displayItemsForAppsOfRoles:(id)roles {
    NSArray<SBDisplayItem *> *originalApps = %orig;
    NSMutableArray<SBDisplayItem *> *activeApps = [NSMutableArray array];
    
    SBApplicationController *appController = [objc_getClass("SBApplicationController") sharedInstance];
    
    for (SBDisplayItem *displayItem in originalApps) {
        NSString *bundleIdentifier = displayItem.displayIdentifier;
        SBApplication *app = [appController applicationWithBundleIdentifier:bundleIdentifier];
        if (app.isRunning) {
            [activeApps addObject:displayItem];
        }
    }

    return [NSArray arrayWithArray:activeApps];
}

%end
