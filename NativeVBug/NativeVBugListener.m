#import <libactivator/libactivator.h>
#import <objc/runtime.h>
#import <notify.h>

@interface SBApplication
- (NSString *)bundleIdentifier;
@end

@interface SpringBoard
- (SBApplication *)_accessibilityFrontMostApplication;
@end

@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
- (BOOL)isUILocked;
@end

@interface UIDebuggingInformationOverlay : UIWindow <UISplitViewControllerDelegate>
+ (instancetype)overlay;
+ (void)prepareDebuggingOverlay;
- (void)toggleVisibility;
@end

@interface NativeVBugListener : NSObject <LAListener>
@end

@implementation NativeVBugListener

static UIDebuggingInformationOverlay *debugOverlay;

static void toggleNativeDebugger() {
    if (!debugOverlay) {
        Class UIDebuggingInformationOverlay = objc_getClass("UIDebuggingInformationOverlay");
        [UIDebuggingInformationOverlay prepareDebuggingOverlay];
        debugOverlay = [UIDebuggingInformationOverlay overlay];
    }
    
    [debugOverlay toggleVisibility];
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName {
    SBApplication *frontmostApp = [(SpringBoard *)UIApplication.sharedApplication _accessibilityFrontMostApplication];
    SBLockScreenManager *lockscreenManager = [objc_getClass("SBLockScreenManager") sharedInstance];
    
    if (frontmostApp && !lockscreenManager.isUILocked) {
        notify_post([[NSString stringWithFormat:@"com.ipadkid.nativevbug/%@", frontmostApp.bundleIdentifier] UTF8String]);
    } else {
        toggleNativeDebugger();
    }
}

+ (void)load {
    NSString *currentID = NSBundle.mainBundle.bundleIdentifier;
    if ([currentID isEqualToString:@"com.apple.springboard"]) {
        // This string just needs to match whatever is in layout/Library/Activator/Listeners
        [LAActivator.sharedInstance registerListener:self.new forName:@"com.ipadkid.nativevbug"];
    } else {
        int regToken;
        NSString *notifForBundle = [NSString stringWithFormat:@"com.ipadkid.nativevbug/%@", currentID];
        notify_register_dispatch(notifForBundle.UTF8String, &regToken, dispatch_get_main_queue(), ^(int token) {
            toggleNativeDebugger();
        });
    }
}

@end
