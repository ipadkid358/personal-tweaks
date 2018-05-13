#import <UIKit/UIKit.h>

%hook PUOneUpSettings

- (void)setDefaultMaximumZoomFactor:(CGFloat)factor {
    %orig(INFINITY);
}

%end
