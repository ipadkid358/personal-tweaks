#import <UIKit/UIKit.h>


%hook UIKeyboardLayoutStar

- (BOOL)shouldShowDictationKey {
	return NO;
}

%end
