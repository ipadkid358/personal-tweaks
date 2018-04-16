#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>

typedef NS_ENUM(NSUInteger, SBBiometricSensorEvent) {
    SBBiometricSensorEventUp,
    SBBiometricSensorEventDown,
    
    // below are only triggered during a biometric challenge
    SBBiometricSensorEventHeld,
    SBBiometricSensorEventMatched,
    SBBiometricSensorEventUnlocked
};

@interface SBUIBiometricResource : NSObject
- (void)_fingerDetectAllowedStateMayHaveChangedForReason:(id)reason;
@end

@interface FBSystemApp : UIApplication
@end

@interface SpringBoard : FBSystemApp
- (void)_simulateHomeButtonPress;
@end

@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)screenIsOn;
@end

@interface SBMainSwitcherViewController
+ (instancetype)sharedInstance;
- (BOOL)activateSwitcherNoninteractively;
@end

static NSTimer *touchTimer;
static BOOL reachabilityHalt;


%hook SBDashBoardViewController

- (void)handleBiometricEvent:(SBBiometricSensorEvent)event {
    %orig;
    
    if (event == SBBiometricSensorEventDown) {
        touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer *timer) {
            SBMainSwitcherViewController *switcherController = [objc_getClass("SBMainSwitcherViewController") sharedInstance];
            [switcherController activateSwitcherNoninteractively];
        }];
    }
    
    if (event == SBBiometricSensorEventUp) {
        if (touchTimer.valid) {
            [touchTimer invalidate];
            
            if (reachabilityHalt) {
                reachabilityHalt = NO;
            } else {
                SpringBoard *springboard = (SpringBoard *)[UIApplication sharedApplication];
                [springboard _simulateHomeButtonPress];
            }
        }
    }
}

%end

%hook SBReachabilityManager

- (void)toggleReachability {
    [touchTimer invalidate];
    reachabilityHalt = YES;
    
    %orig;
}

%end

// Turn TouchID back on after the screen turns off
%hook SBUIBiometricResource

- (void)noteScreenDidTurnOff {
    [self _fingerDetectAllowedStateMayHaveChangedForReason:@"Screen off"];
}

%end

// special handler for when the screen is off
void ioEventHandler(void *target, void *refcon, IOHIDEventQueueRef queue, IOHIDEventRef event) {
    // mesa event
    if (IOHIDEventGetType(event) == 29) {
        // touch down (16777233 = touch up)
        if (IOHIDEventGetEventFlags(event) == 17) {
            SBBacklightController *backlight = [objc_getClass("SBBacklightController") sharedInstance];
            if (!backlight.screenIsOn) {
                SpringBoard *springboard = (SpringBoard *)[UIApplication sharedApplication];
                [springboard _simulateHomeButtonPress];
            }
        }
    }
}

%ctor {
    // thanks https://stackoverflow.com/a/15550916
    IOHIDEventSystemClientRef client = IOHIDEventSystemClient();
    IOHIDEventSystemClientScheduleWithRunLoop(client, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(client, ioEventHandler, NULL, NULL);
}
