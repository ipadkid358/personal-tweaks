#import <Flipswitch/FSSwitchDataSource.h>
#import <substrate.h>

@interface CCUIButtonModule : NSObject
@end

@interface CCUIShortcutModule : CCUIButtonModule
@end

@interface CCUIRecordScreenShortcut : CCUIShortcutModule
- (void)_startRecording;
- (void)_stopRecording;
- (BOOL)_toggleState;
@end

@interface SBControlCenterController : NSObject
+ (instancetype)sharedInstance;
- (void)dismissAnimated:(BOOL)animated completion:(void (^)())completionBlock;
@end


@interface ScreenRecordSwitch : NSObject <FSSwitchDataSource>
@end

static FSSwitchState switchState = FSSwitchStateOff;
static CCUIRecordScreenShortcut *screenRecording = NULL;

static BOOL patched_CCUIRecordScreenShortcut_isSupported(Class const self, SEL _cmd, int arg) {
    return YES;
}

@implementation ScreenRecordSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return switchState;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    SBControlCenterController *controlCenterController = [objc_getClass("SBControlCenterController") sharedInstance];
    
    if (newState == FSSwitchStateOn) {
        switchState = FSSwitchStateOn;
        [controlCenterController dismissAnimated:YES completion:^{
            [screenRecording _startRecording];
        }];
    }
    if (newState == FSSwitchStateOff) {
        switchState = FSSwitchStateOff;
        [controlCenterController dismissAnimated:YES completion:^{
            [screenRecording _stopRecording];
        }];
    }
}

- (void)switchWasRegisteredForIdentifier:(NSString *)switchIdentifier {
    Class ScreenRecorderClass = objc_getClass("CCUIRecordScreenShortcut");
    if (ScreenRecorderClass) {
        Class ScreenRecorderMetaClass = object_getClass(ScreenRecorderClass); 
        MSHookMessageEx(ScreenRecorderMetaClass, @selector(isSupported:), (IMP)&patched_CCUIRecordScreenShortcut_isSupported, NULL);
        screenRecording = [ScreenRecorderClass new];
    }
}

@end
