#import <UIKit/UIKit.h>

%hook NCMaterialView

- (UIColor *)backgroundColor {
    return UIColor.clearColor;
}

- (void)setBackgroundColor:(UIColor *)arg1 {
    %orig(UIColor.clearColor);
}

- (UIView *)colorInfusionView {
    UIView *view = %orig;
    view.alpha = 0;
    return view;
}

- (void)setColorInfusionView:(UIView *)view {
    view.alpha = 0;
    %orig;
}

%end
