#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>

#import <UIKit/UIKit.h>

#if __cplusplus
extern "C" {
#endif
    IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);
#if __cplusplus
}
#endif


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

@interface SBScreenshotManager : NSObject
- (void)saveScreenshots;
@end

@interface FBSystemApp : UIApplication
@end

@interface SpringBoard : FBSystemApp
- (void)_simulateHomeButtonPress;
- (SBScreenshotManager *)screenshotManager;
- (BOOL)isLocked;
@end

@interface SBBacklightController : NSObject
+ (instancetype)sharedInstance;
- (BOOL)screenIsOn;
@end

@interface SBMainSwitcherViewController
+ (instancetype)sharedInstance;
- (BOOL)activateSwitcherNoninteractively;
@end

static NSTimer *touchTimer = NULL;
static BOOL reachabilityHalt = NO;
static BOOL didTapScreenShotGesture = NO;
static BOOL didBeginHoldScreenShotGesture = NO;

%hook SBDashBoardViewController

- (void)handleBiometricEvent:(SBBiometricSensorEvent)event {
    %orig;
    
    SpringBoard *springboard = (SpringBoard *)[UIApplication sharedApplication];
    
    if (springboard.isLocked) {
        return;
    }
    
    if (event == SBBiometricSensorEventDown) {
        if (didTapScreenShotGesture) {
            didBeginHoldScreenShotGesture = YES;
            touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer *timer) {
                touchTimer = NULL;
                didTapScreenShotGesture = NO;
                didBeginHoldScreenShotGesture = NO;
                
                [springboard.screenshotManager saveScreenshots];
            }];
        } else {
            touchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer *timer) {
                touchTimer = NULL;
                SBMainSwitcherViewController *switcherController = [objc_getClass("SBMainSwitcherViewController") sharedInstance];
                [switcherController activateSwitcherNoninteractively];
            }];
        }
    }
    
    if (event == SBBiometricSensorEventUp) {
        if (touchTimer.valid) {
            [touchTimer invalidate];
            
            if (didTapScreenShotGesture) {
                if (didBeginHoldScreenShotGesture) {
                    didTapScreenShotGesture = NO;
                    didBeginHoldScreenShotGesture = NO;
                }
            } else {
                didTapScreenShotGesture = YES;
                
                [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:NO block:^(NSTimer *timer) {
                    didTapScreenShotGesture = NO;
                    if (!didBeginHoldScreenShotGesture) {
                        if (reachabilityHalt) {
                            reachabilityHalt = NO;
                        } else {
                            [springboard _simulateHomeButtonPress];
                        }
                    }
                }];
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

// thanks https://stackoverflow.com/a/15550916
static IOHIDEventSystemClientRef ioHIDClient;
static CFRunLoopRef ioHIDRunLoopScedule;

%ctor {
    ioHIDClient = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    ioHIDRunLoopScedule = CFRunLoopGetMain();
    
    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDClient, ioEventHandler, NULL, NULL);
}

%dtor {
    IOHIDEventSystemClientUnregisterEventCallback(ioHIDClient);
    IOHIDEventSystemClientUnscheduleWithRunLoop(ioHIDClient, ioHIDRunLoopScedule, kCFRunLoopDefaultMode);
}
