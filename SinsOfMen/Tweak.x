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
%hook WGShortLookStyleButton

- (double)_dimension {
    return 0;
}

- (void)setTitle:(id)title {
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
%hook CCUINightShiftContentView

- (BOOL)isHidden {
    return YES;
}

%end
