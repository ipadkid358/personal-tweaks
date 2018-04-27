#import <objc/runtime.h>

#import "SVStatusVolX.h"

@interface SBStatusBarStateAggregator : NSObject
+ (instancetype)sharedInstance;
- (void)_resetTimeItemFormatter;
- (void)_updateTimeItems;
@end


@implementation SVStatusVolX {
    int _volume;
    NSTimer *_hideTimer;
    SBStatusBarStateAggregator *_sbsa;
}

- (instancetype)init {
    if (self = [super init]) {
        _sbsa = [objc_getClass("SBStatusBarStateAggregator") sharedInstance];
    }
    
    return self;
}

- (void)showVolume:(float)vol {
    _volume = (int)vol;
    _showingVolume = YES;
    
    [_sbsa _resetTimeItemFormatter];
    [_sbsa _updateTimeItems];
    
    if (_hideTimer) {
        [_hideTimer invalidate];
    }
    
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(setNotShowingVolume) userInfo:NULL repeats:NO];
}

- (void)setNotShowingVolume {
    _hideTimer = NULL;
    
    _showingVolume = NO;
    
    [_sbsa _resetTimeItemFormatter];
    [_sbsa _updateTimeItems];
}

- (NSString *)volumeString {
    return [NSString stringWithFormat:@"%c%d", '#', _volume];
}

@end
