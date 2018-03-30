@interface StatusVolX : NSObject

@property (nonatomic) BOOL showingVolume;

- (void)showVolume:(float)vol;
- (NSString *)volumeString;

@end

@interface VolumeControl : NSObject
+ (instancetype)sharedVolumeControl;
- (float)getMediaVolume;
- (float)volume;
@end

@interface SBStatusBarStateAggregator
+ (instancetype)sharedInstance;
- (void)_resetTimeItemFormatter;
- (void)_updateTimeItems;
@end

StatusVolX *svx;
NSString *oldFormatter;

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
    int theMode = MSHookIvar<int>(volControl,  "_mode");
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

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    // Create StatusVolX inside SpringBoard
    svx = [StatusVolX new];
}

%end


@implementation StatusVolX {
    int volume;
    NSTimer *hideTimer;
    BOOL svolCloseInterrupt;
    BOOL isAnimatingClose;
}

- (void)showVolume:(float)vol {
    volume = (int)vol;
    self.showingVolume = YES;
    
    SBStatusBarStateAggregator *sbsa = [%c(SBStatusBarStateAggregator) sharedInstance];
    [sbsa _resetTimeItemFormatter];
    [sbsa _updateTimeItems];
    
    if (hideTimer) {
        [hideTimer invalidate];
    }
    
    hideTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(setNotShowingVolume) userInfo:nil repeats:NO];
}

- (void)setNotShowingVolume {
    hideTimer = nil;
    
    self.showingVolume = NO;
    
    SBStatusBarStateAggregator *sbsa =[%c(SBStatusBarStateAggregator) sharedInstance];
    [sbsa _resetTimeItemFormatter];
    [sbsa _updateTimeItems];
}

- (NSString *)volumeString {
    return [NSString stringWithFormat:@"%c%d", '#', volume];
}

@end
