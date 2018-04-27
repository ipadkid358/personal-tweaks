#import "SVStatusVolX.h"

@interface VolumeControl : NSObject
+ (instancetype)sharedVolumeControl;
- (float)getMediaVolume;
- (float)volume;
@end

@interface SBStatusBarStateAggregator : NSObject
@end

static SVStatusVolX *svx;
static NSString *oldFormatter;

// Send indicator command to the statusbar
%hook SBStatusBarStateAggregator

- (void)_resetTimeItemFormatter {
    %orig;
    
    NSDateFormatter *timeFormat = [self valueForKey:@"_timeItemDateFormatter"];
    if (!oldFormatter) {
        oldFormatter = timeFormat.dateFormat; // Allows us to reset the format
    }
    
    timeFormat.dateFormat = svx.showingVolume ? svx.volumeString : oldFormatter;
}

%end

// Hook volume change events
%hook SBMediaController

- (void)_systemVolumeChanged:(id)arg1 {
    %orig;
    
    VolumeControl *volControl = [%c(VolumeControl) sharedVolumeControl];
    Ivar modeIvar = class_getInstanceVariable(%c(VolumeControl), "_mode");
    void *modePtr = ((__bridge void *)volControl) + ivar_getOffset(modeIvar);
    int theMode = *(int *)modePtr;
    float showVol = theMode ? volControl.volume : volControl.getMediaVolume;
    [svx showVolume:showVol*16];
}

%end

// Force hide volume HUD
%hook VolumeControl

- (BOOL)_HUDIsDisplayableForCategory:(id)category {
    return NO;
}

- (BOOL)_isCategoryAlwaysHidden:(id)hidden {
    return YES;
}

%end

// Create StatusVolX inside SpringBoard
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    svx = [SVStatusVolX new];
}

%end
