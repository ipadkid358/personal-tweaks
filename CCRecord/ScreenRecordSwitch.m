#import <Flipswitch/FSSwitchDataSource.h>
#import <objc/runtime.h>

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

@implementation ScreenRecordSwitch {
    CCUIRecordScreenShortcut *_screenRecorder;
    FSSwitchState _switchState;
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return _switchState;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    SBControlCenterController *controlCenterController = [objc_getClass("SBControlCenterController") sharedInstance];
    
    if (newState == FSSwitchStateOn) {
        _switchState = FSSwitchStateOn;
        [controlCenterController dismissAnimated:YES completion:^{
            [_screenRecorder _startRecording];
        }];
    }
    if (newState == FSSwitchStateOff) {
        _switchState = FSSwitchStateOff;
        [controlCenterController dismissAnimated:YES completion:^{
            [_screenRecorder _stopRecording];
        }];
    }
}

- (void)switchWasRegisteredForIdentifier:(NSString *)switchIdentifier {
    _screenRecorder = [CCUIRecordScreenShortcut new];
}

@end
