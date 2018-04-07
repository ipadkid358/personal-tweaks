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

// Don't add Today View footer stuff
%hook WGShortLookStyleButton

- (double)_dimension {
	return 0;
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
%hook SBDashBoardMainPageView

- (void)_layoutCallToActionLabel {
}

%end

// Remove Today View on homescreen
%hook SBRootFolderView

- (NSUInteger)_minusPageCount {
	return 0;
} 

%end
