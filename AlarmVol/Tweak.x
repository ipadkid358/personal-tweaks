#import <Foundation/Foundation.h>

@interface AVSystemController : NSObject
+ (instancetype)sharedAVSystemController;
- (BOOL)setVolumeTo:(float)volume forCategory:(NSString *)category;
- (BOOL)getVolume:(float *)volume forCategory:(NSString *)category;
@end

// all volume values are floats, not doubles, which I find interesting
static float originalVol = 0.0f;

%hook SBClockDataProvider

// store the current volume so we can set it back, then set the volume to a reasonably high volume
- (void)_interruptAudioAndLockDeviceForNotification:(id)notification {
    %orig;
    
    AVSystemController *sysController = AVSystemController.sharedAVSystemController;
    [sysController getVolume:&originalVol forCategory:@"Ringtone"];
    [sysController setVolumeTo:0.7 forCategory:@"Ringtone"];
}

// set the volume back, when the alarm is dismissed
- (void)handleBulletinActionResponse:(id)response {
    %orig;
    
    [AVSystemController.sharedAVSystemController setVolumeTo:originalVol forCategory:@"Ringtone"];
}

%end
