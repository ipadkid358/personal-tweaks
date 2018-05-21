#import <UIKit/UIKit.h>

@interface UIInterfaceActionGroupView : UIView
@end

@interface _UIAlertControllerInterfaceActionGroupView : UIInterfaceActionGroupView
@end

@interface _UIAlertControlleriOSActionSheetCancelBackgroundView : UIView
@end

// colors for title and body of alerts
%hook UIAlertControllerVisualStyleAlert

- (UIColor *)titleLabelColor {
    return UIColor.whiteColor;
}

- (UIColor *)messageLabelColor {
    return UIColor.whiteColor;
}

%end

// color of title and body of action sheets
%hook UIAlertControllerVisualStyleActionSheet

- (UIColor *)titleLabelColor {
    return UIColor.whiteColor;
}

- (UIColor *)messageLabelColor {
    return UIColor.whiteColor;
}

%end

// set the background of alerts to black. the alpha is 0.8, we'll keep that
// label colors are also set in here, however it's only for handling the
// edge case where I have attributed text in those feilds, otherwise
// those text colors should be set to the colors in the above hooks
%hook _UIAlertControllerInterfaceActionGroupView

- (void)layoutSubviews {
    %orig;
    
    UIView *filterView = self.subviews.firstObject.subviews.lastObject.subviews.lastObject;
    filterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    
    UIView *labelHolder = self.subviews.lastObject.subviews.firstObject.subviews.firstObject;
    for (UILabel *label in labelHolder.subviews) {
        if ([label respondsToSelector:@selector(setTextColor:)]) {
            label.textColor = UIColor.whiteColor;
        }
    }
}

%end

// Cancel button on UIAlertControllerStyleActionSheet needs its own handling
%hook _UIAlertControlleriOSActionSheetCancelBackgroundView

- (void)layoutSubviews {
    %orig;
    
    UIView *knockoutView = self.subviews[1];
    UIView *filterView = knockoutView.subviews.lastObject.subviews.lastObject;
    UIView *whiteView = self.subviews.firstObject;
    
    filterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    whiteView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
}

%end
