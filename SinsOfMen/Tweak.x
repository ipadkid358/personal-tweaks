#import <UIKit/UIKit.h>

// Disable blurs in app switcher
%hook SBAppSwitcherSettings

- (void)setDeckSwitcherBackgroundBlurRadius:(CGFloat)radius {
    %orig(0);
}

- (void)setDeckSwitcherForegroundBlurRadius:(CGFloat)radius {
    %orig(0);
}

%end

// Don't hide the status bar in app switcher
%hook SBSwitcherMetahostingHomePageContentView

- (void)_createFakeStatusBar {
}

%end

// Show date on one line in Today View
%hook SBSearchEtceteraDateViewController

- (void)setUseMultiLineDate:(BOOL)multiLine {
    %orig(NO);
}

%end

// Allow user notifications to appear at full length
%hook NCNotificationShortLookView

- (void)setMessageNumberOfLines:(NSUInteger)numberOfLines {
    %orig(INFINITY);
} 

%end

// Don't add hint text to lockscreen notifications
%hook NCNotificationShortLookViewController

- (BOOL)_shouldAddHintTextToLookView {
    return NO;
}

%end

// Don't show Today View footer stuff
%hook WGWidgetListFooterView

- (id)initWithFrame:(CGRect)frame {
    return NULL;
}

%end

// Don't show grabber on notifications
%hook NCNotificationShortLookView

- (BOOL)_shouldShowGrabber {
    return NO;
}

%end

// Don't hide status bar in folders
%hook SBFolderController

- (void)_addFakeStatusBarView {
}

%end

// Don't show padlock and unlock text on lockscreen statusbar
%hook SBStatusBarStateAggregator

- (void)_updateLockItem {
}

%end

// Don't show lockscreen unlock prompt text
%hook SBUICallToActionLabel

- (id)initWithFrame:(CGRect)frame {
    return NULL;
}

%end

// Don't show bottom Notification Center separator
%hook SBNotificationSeparatorView

- (void)updateForCurrentState {
}

%end

// Don't show Notification Center page dots
%hook SBNotificationCenterViewController

- (void)_loadPageControl {
}

%end

// Don't show homescreen page dots
%hook SBIconListPageControl

- (void)_setIndicatorImage:(id)image toEnabled:(BOOL)enabled index:(NSInteger)index {
}

%end

// Don't show lockscreen page dots
%hook SBDashBoardPageControl

- (void)_setIndicatorImage:(id)image toEnabled:(BOOL)enabled index:(NSInteger)index {
}

%end

// Show time in status bar on lockscreen
%hook SBDashBoardViewController

- (BOOL)shouldShowLockStatusBarTime {
    return YES;
}

%end

// No update/beta icon badges (blue and green dots, respectively)
%hook SBLeafIcon

- (BOOL)isRecentlyUpdated {
    return NO;
}

- (BOOL)isBeta {
    return NO;
}

%end

// Remove Night Shift toggle from Control Center
%hook CCUINightShiftSectionController

- (BOOL)enabled {
    return NO;
}

%end

// Disable Camera on the lockscreen
%hook SpringBoard

- (BOOL)lockScreenCameraSupported {
    return NO;
}

%end

// Blank passcode buttons
%hook SBPasscodeNumberPadButton

+ (id)imageForCharacter:(unsigned)character {
    return NULL;
}

+ (id)imageForCharacter:(unsigned)character highlighted:(BOOL)highlighted {
    return NULL;
}

%end

// Don't play charging chime
%hook SBUIController

- (void)playConnectedToPowerSoundIfNecessary {
}

%end

// Hide all icon labels
%hook SBMutableIconLabelImageParameters

- (void)setScale:(CGFloat)scale {
    %orig(0);
}

%end

// Hide title of open folder
%hook SBFloatyFolderView

- (BOOL)_showsTitle {
    return NO;
}

%end

// Speed up animations
%hook SBAnimationFactorySettings

- (CGFloat)slowDownFactor {
    return 0.6;
}

%end

// Disable Home Control Center page
%hook HUHomeControlCenterViewController

- (BOOL)wantsVisible {
    return NO;
}

%end
