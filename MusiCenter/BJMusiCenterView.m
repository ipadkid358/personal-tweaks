#import <MediaRemote/MediaRemote.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

#import "BJMusiCenterView.h"

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
- (BOOL)isPlaying;
- (BOOL)togglePlayPause;
- (void)_changeVolumeBy:(float)vol;
- (BOOL)_sendMediaCommand:(unsigned)command;
@end

@interface VolumeControl : NSObject
+ (instancetype)sharedVolumeControl;
- (float)volumeStepDown;
- (float)volumeStepUp;
@end

@interface CCUIControlCenterLabel : UILabel
@end

@interface UIApplication (UILaunchApplication)
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface MPAVRoutingSheet : UIView
- (instancetype)initWithAVItemType:(NSInteger)type;
- (void)showInView:(UIView *)view withCompletionHandler:(void (^)())completionHandler;
@end


@implementation BJMusiCenterView {
    CCUIControlCenterLabel *_musicInfoLabel;
}

// we're supporting portrait only
// x: 350, y: 55
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _musicInfoLabel = [[CCUIControlCenterLabel alloc] initWithFrame:CGRectMake(0, 0, 350, 55)];
        _musicInfoLabel.numberOfLines = 2;
        _musicInfoLabel.text = @"Hold to launch YouTube Music!";
        _musicInfoLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _musicInfoLabel.textAlignment = NSTextAlignmentCenter;
        _musicInfoLabel.userInteractionEnabled = YES;
        [_musicInfoLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticTouches:)]];
        [_musicInfoLabel addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticDrag:)]];
        [_musicInfoLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticPress:)]];
        
        UILongPressGestureRecognizer *doublePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticDoublePress:)];
        doublePress.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:doublePress];
        [self addSubview:_musicInfoLabel];
        
        self.clipsToBounds = YES;
        [self updateMusicLabel:NULL];
        
        NSString *playingInfoNotifName = (__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification;
        NSString *isPlayingNotifName = (__bridge NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
        NSNotificationCenter *notifCenter = NSNotificationCenter.defaultCenter;
        
        // this gets called twice per music event, as far as I can tell
        [notifCenter addObserver:self selector:@selector(updateMusicLabel:) name:playingInfoNotifName object:NULL];
        
        [notifCenter addObserverForName:isPlayingNotifName object:NULL queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
            NSNumber *isPlaying = note.userInfo[(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey];
            _musicInfoLabel.font = [UIFont systemFontOfSize:14 weight:(isPlaying.boolValue ? UIFontWeightRegular : UIFontWeightLight)];
        }];
    }
    
    return self;
}

- (void)handleGesticDoublePress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        MPAVRoutingSheet *routingSheet = [[MPAVRoutingSheet alloc] initWithAVItemType:2];
        UIView *cancelButton = [routingSheet valueForKey:@"_cancelButton"];
        cancelButton.backgroundColor = UIColor.blackColor;
        
        UIView *controlView = [routingSheet valueForKey:@"_controlsView"];
        UIView *containerView = controlView.subviews[1];
        UIView *tableView = containerView.subviews.firstObject;
        tableView.backgroundColor = UIColor.blackColor;
        
        [routingSheet showInView:self withCompletionHandler:NULL];
    }
}

- (void)handleGesticPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        SBMediaController *mediaController = [objc_getClass("SBMediaController") sharedInstance];
        NSString *nowPlaying = mediaController.nowPlayingApplication.bundleIdentifier ?: @"com.google.ios.youtubemusic";
        [UIApplication.sharedApplication launchApplicationWithIdentifier:nowPlaying suspended:NO];
    }
}

- (void)updateMusicLabel:(NSNotification *)note {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
        NSDictionary *musicDict = (__bridge NSDictionary *)result;
        
        NSString *songName = musicDict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
        NSString *artistName = musicDict[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
        
        if (!songName || !artistName) {
            return;
        }
        
        _musicInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", songName, artistName];
    });
}

- (void)handleGesticTouches:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint hitPoint = [gesture locationInView:self];
        CGFloat hitX = hitPoint.x;
        
        CGFloat const viewPOne = 350/3.0;
        CGFloat const viewPTwo = viewPOne*2;
        
        VolumeControl *volControl = [objc_getClass("VolumeControl") sharedVolumeControl];
        SBMediaController *mediaControl = [objc_getClass("SBMediaController") sharedInstance];
        
        if (hitX < viewPOne) {
            [mediaControl _changeVolumeBy:-volControl.volumeStepDown];
        }
        
        if ((hitX > viewPOne) && (hitX < viewPTwo)) {
            [mediaControl togglePlayPause];
        }
        
        if (hitX > viewPTwo) {
            [mediaControl _changeVolumeBy:volControl.volumeStepUp];
        }
    }
}

- (void)handleGesticDrag:(UIPanGestureRecognizer *)gesture {
    UIGestureRecognizerState gestState = gesture.state;
    
    CGPoint translation = [gesture translationInView:self];
    CGFloat newOX = translation.x;
    
    CGRect resetFrame = CGRectMake(0, 0, 350, 55);
    BOOL gestCancelled = (gestState == UIGestureRecognizerStateCancelled);
    
    if ((gestState == UIGestureRecognizerStateEnded) || gestCancelled) {
        __weak __typeof(self) weakself = self;
        void (^layoutSubviewsCompl)(UIViewAnimatingPosition finalPosition) = ^(UIViewAnimatingPosition finalPosition) {
            [weakself layoutSubviews];
        };
        
        BOOL back = (newOX < -200);
        BOOL skip = (newOX > 200);
        if ((back || skip) && !gestCancelled) {
            SBMediaController *mediaControl = [objc_getClass("SBMediaController") sharedInstance];
            [mediaControl _sendMediaCommand:(back ? 4 : 5)];
            
            /* maths
             screen width = 414
             view width = 350
             (414-350)/2 = 32
             0-350-32 = -382
             0+350+32 = +382
             offset = ± 18
             */
            CGRect skipFrame = resetFrame;
            skipFrame.origin.x = -400;
            CGRect backFrame = resetFrame;
            backFrame.origin.x = 400;
            
            [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.075 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _musicInfoLabel.frame = back ? skipFrame : backFrame;
            } completion:^(UIViewAnimatingPosition finalPosition) {
                _musicInfoLabel.frame = back ? backFrame : skipFrame;
                [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    _musicInfoLabel.frame = resetFrame;
                } completion:layoutSubviewsCompl];
            }];
        } else {
            [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:(0.002 * ABS(newOX)) delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _musicInfoLabel.frame = resetFrame;
            } completion:layoutSubviewsCompl];
        }
    } else {
        resetFrame.origin.x = newOX;
        _musicInfoLabel.frame = resetFrame;
    }
}

@end
