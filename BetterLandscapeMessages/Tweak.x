#import <UIKit/UIInterface.h>

// Don't automatically show handwriting view
%hook CKChatInputController

- (BOOL)presentsHandwritingOnRotation {
    return NO;
}

%end

// Don't show conversation list next to current conversation
%hook UITraitCollection

- (UIUserInterfaceSizeClass)horizontalSizeClass {
    return UIUserInterfaceSizeClassCompact;
}

%end
