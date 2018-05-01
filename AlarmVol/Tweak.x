#import <Foundation/Foundation.h>

@interface AVSystemController : NSObject
+ (instancetype)sharedAVSystemController;
- (BOOL)setVolumeTo:(float)volume forCategory:(NSString *)category;
- (BOOL)getVolume:(float *)volume forCategory:(NSString *)category;
@end


static float originalVol = 0.0f;

%hook SBClockDataProvider

- (void)_interruptAudioAndLockDeviceForNotification:(id)notification {
    %orig;
    
    AVSystemController *sysController = AVSystemController.sharedAVSystemController;
    [sysController getVolume:&originalVol forCategory:@"Ringtone"];
    [sysController setVolumeTo:0.7 forCategory:@"Ringtone"];
}

- (void)handleBulletinActionResponse:(id)response {
    %orig;
    
    [AVSystemController.sharedAVSystemController setVolumeTo:originalVol forCategory:@"Ringtone"];
}

%end
