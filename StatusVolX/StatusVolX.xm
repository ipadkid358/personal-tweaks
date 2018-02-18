@interface StatusVolX : NSObject {
    int volume;
    NSTimer *hideTimer;
    BOOL svolCloseInterrupt;
    BOOL isAnimatingClose;
}

@property(nonatomic) BOOL showingVolume;

- (void)showVolume:(float)vol;
- (NSString *)volumeString;
@end

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (float)getMediaVolume;
- (float)volume;
@end

@interface SBStatusBarStateAggregator
+ (id)sharedInstance;
- (void)_resetTimeItemFormatter;
- (void)_updateTimeItems;
@end

StatusVolX *svx;
NSString *oldFormatter;

// Send indicator command to the statusbar
%hook SBStatusBarStateAggregator

- (void)_resetTimeItemFormatter {
    %orig;
    
    NSDateFormatter *timeFormat = MSHookIvar<NSDateFormatter *>(self,"_timeItemDateFormatter");
    if (oldFormatter == nil) {
        oldFormatter = [timeFormat dateFormat]; // Allows us to reset the format
    }
    
    timeFormat.dateFormat = svx.showingVolume ? svx.volumeString : oldFormatter;
}

%end

// Hook volume change events
%hook VolumeControl
- (void)_changeVolumeBy:(float)volumeStep {
    %orig;
    
    int theMode = MSHookIvar<int>(self,  "_mode");
    float showVol = theMode ? self.volume : self.getMediaVolume;
    [svx showVolume:showVol*16];
}

// Force hide volume HUD
- (BOOL)_HUDIsDisplayableForCategory:(id)arg1 {
    return NO;
}

- (BOOL)_isCategoryAlwaysHidden:(id)arg1 {
    return YES;
}

%end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
    %orig;
    
    // Create StatusVolX inside SpringBoard
    svx = [StatusVolX new];
}
%end

@implementation StatusVolX

- (void)showVolume:(float)vol {
    volume = (int)vol;
    self.showingVolume = YES;
    
    SBStatusBarStateAggregator *sbsa = [%c(SBStatusBarStateAggregator) sharedInstance];
    [sbsa _resetTimeItemFormatter];
    [sbsa _updateTimeItems];
    
    if (hideTimer != nil) {
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
    return [NSString stringWithFormat:@"'#%d'", volume];
}

@end
