#import <MediaRemote/MediaRemote.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

#import "BJMusiCenterView.h"

// hardcoded dimensions of the control center night shift button that we're replacing
#define kPlusButtonWidth  350.0f
#define kPlusButtonHeight 55.0f

@interface SBApplication : NSObject
- (NSString *)bundleIdentifier;
@end

// Thanks https://opensource.apple.com/source/WebCore/WebCore-7602.3.12/platform/spi/mac/MediaRemoteSPI.h.auto.html
typedef NS_ENUM(uint32_t, MRMediaRemoteCommand) {
    MRMediaRemoteCommandPlay,
    MRMediaRemoteCommandPause,
    MRMediaRemoteCommandTogglePlayPause,
    MRMediaRemoteCommandStop,
    MRMediaRemoteCommandNextTrack,
    MRMediaRemoteCommandPreviousTrack,
    MRMediaRemoteCommandAdvanceShuffleMode,
    MRMediaRemoteCommandAdvanceRepeatMode,
    MRMediaRemoteCommandBeginFastForward,
    MRMediaRemoteCommandEndFastForward,
    MRMediaRemoteCommandBeginRewind,
    MRMediaRemoteCommandEndRewind,
    MRMediaRemoteCommandRewind15Seconds,
    MRMediaRemoteCommandFastForward15Seconds,
    MRMediaRemoteCommandRewind30Seconds,
    MRMediaRemoteCommandFastForward30Seconds,
    MRMediaRemoteCommandToggleRecord,
    MRMediaRemoteCommandSkipForward,
    MRMediaRemoteCommandSkipBackward,
    MRMediaRemoteCommandChangePlaybackRate,
    MRMediaRemoteCommandRateTrack,
    MRMediaRemoteCommandLikeTrack,
    MRMediaRemoteCommandDislikeTrack,
    MRMediaRemoteCommandBookmarkTrack,
    MRMediaRemoteCommandSeekToPlaybackPosition,
    MRMediaRemoteCommandChangeRepeatMode,
    MRMediaRemoteCommandChangeShuffleMode,
    MRMediaRemoteCommandEnableLanguageOption,
    MRMediaRemoteCommandDisableLanguageOption
};

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
- (BOOL)isPlaying;
- (BOOL)togglePlayPause;
- (void)_changeVolumeBy:(float)vol;
- (BOOL)_sendMediaCommand:(MRMediaRemoteCommand)command;
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

// Thanks https://opensource.apple.com/source/WebCore/WebCore-7602.3.12/platform/spi/ios/MediaPlayerSPI.h.auto.html
typedef NS_ENUM(NSUInteger, MPAVItemType) {
    MPAVItemTypeUnknown,
    MPAVItemTypeAudio,
    MPAVItemTypeVideo,
};

@interface MPAVRoutingSheet : UIView
- (instancetype)initWithAVItemType:(MPAVItemType)avItemType;
- (void)showInView:(UIView *)view withCompletionHandler:(void (^)(void))completionHandler;
- (void)dismiss;
@end


@implementation BJMusiCenterView {
    CCUIControlCenterLabel *_musicInfoLabel;
    BOOL _musicHasStartedPlaying;
}

// we're supporting portrait only
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _musicInfoLabel = [[CCUIControlCenterLabel alloc] initWithFrame:CGRectMake(0, 0, kPlusButtonWidth, kPlusButtonHeight)];
        _musicInfoLabel.numberOfLines = 2;
        _musicInfoLabel.text = @"Hold to launch YouTube Music!";
        _musicInfoLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
        _musicInfoLabel.textAlignment = NSTextAlignmentCenter;
        _musicInfoLabel.userInteractionEnabled = YES;
        
        [_musicInfoLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticTouches:)]];
        [_musicInfoLabel addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticDrag:)]];
        [_musicInfoLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesticPress:)]];
        [self addSubview:_musicInfoLabel];
        
        self.clipsToBounds = YES;
        [self updateMusicLabel:NULL];
        
        _musicHasStartedPlaying = NO;
        
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
        
        _musicHasStartedPlaying = YES;
        _musicInfoLabel.text = [NSString stringWithFormat:@"%@\n%@", songName, artistName];
    });
}

- (void)handleGesticTouches:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint hitPoint = [gesture locationInView:self];
        CGFloat hitX = hitPoint.x;
        
        CGFloat const viewPOne = kPlusButtonWidth/3.0;
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
    BOOL shouldShowRoutePicker = (ABS(newOX) < 6) && (translation.y < -30);
    
    CGRect resetFrame = CGRectMake(0, 0, kPlusButtonWidth, kPlusButtonHeight);
    BOOL gestCancelled = (gestState == UIGestureRecognizerStateCancelled);
    
    if (((gestState == UIGestureRecognizerStateEnded) || gestCancelled) || shouldShowRoutePicker) {
        __weak __typeof(self) weakself = self;
        void (^layoutSubviewsCompl)(UIViewAnimatingPosition finalPosition) = ^(UIViewAnimatingPosition finalPosition) {
            [weakself layoutSubviews];
        };
        
        BOOL back = (newOX < -200);
        BOOL skip = (newOX > 200);
        if ((back || skip) && !gestCancelled && _musicHasStartedPlaying) {
            SBMediaController *mediaControl = [objc_getClass("SBMediaController") sharedInstance];
            [mediaControl _sendMediaCommand:(back ? MRMediaRemoteCommandNextTrack : MRMediaRemoteCommandPreviousTrack)];
            
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
            
            static BOOL routePickerIsPresenting = NO;
            if (shouldShowRoutePicker && !routePickerIsPresenting) {
                routePickerIsPresenting = YES;
                MPAVRoutingSheet *routingSheet = [[MPAVRoutingSheet alloc] initWithAVItemType:MPAVItemTypeAudio];
                [routingSheet showInView:self withCompletionHandler:^{
                    routePickerIsPresenting = NO;
                }];
            }
        }
    } else {
        if (_musicHasStartedPlaying) {
            resetFrame.origin.x = newOX;
            _musicInfoLabel.frame = resetFrame;
        }
    }
}

@end
