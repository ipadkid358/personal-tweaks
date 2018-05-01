#import <UIKit/UIKit.h>

@interface NCShortLookView : UIView
@end

@interface NCNotificationShortLookView : NCShortLookView
- (UIView *)_notificationContentView;
@end

@interface NCLookHeaderContentView : UIView
- (UILabel *)_titleLabel;
- (UILabel *)_dateLabel;
@end

@interface NCNotificationListCellActionButtonsView : UIView
@property (nonatomic, retain) UIStackView *buttonsStackView;
@end

@interface NCNotificationListCellActionButton : UIControl
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UILabel *titleLabel;
@end

@interface NCAnimatableBlurringView : UIView
@end

@interface NCNotificationLongLookView : NCAnimatableBlurringView
@property (nonatomic, readonly) UIView *customContentView;
@end


static UIColor *ourCachedWhite() {
    static UIColor *ourWhite = NULL;
    if (!ourWhite) {
        ourWhite = [UIColor colorWithWhite:0.95 alpha:1.0];
    }
    
    return ourWhite;
}

static void configureMainBackgroundView(UIView *view) {
    view.backgroundColor = UIColor.blackColor;
    view.alpha = 0.7;
}

// View shown when notification is expanded
%hook NCNotificationLongLookView

- (void)layoutSubviews {
    %orig;
    
    NSArray<UIView *> *topSubviews = self.subviews;
    NSArray<UIView *> *scrollViews = topSubviews.firstObject.subviews;
    topSubviews.lastObject.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.4];
    UIView *contentView = scrollViews.lastObject.subviews.firstObject.subviews.firstObject;
    scrollViews.firstObject.backgroundColor = NULL;
    
    contentView.backgroundColor = UIColor.blackColor;
    UIColor *ourWhite = ourCachedWhite();
    for (UILabel *subLabel in contentView.subviews.firstObject.subviews) {
        if ([subLabel respondsToSelector:@selector(setTextColor:)]) {
            subLabel.textColor = ourWhite;
        }
    }
    
    UIView *headerView = [self valueForKey:@"_headerContentView"];
    headerView.superview.backgroundColor = UIColor.blackColor;
}

%end

// The standard "view" and "clear" buttons presented when notifications are slid to the left
%hook NCNotificationListCellActionButton

- (void)layoutSubviews {
    %orig;
    
    configureMainBackgroundView(self.backgroundView.subviews.firstObject.subviews.lastObject);
    
    self.titleLabel.textColor = ourCachedWhite();
}

%end

// Main default notification view
%hook NCNotificationShortLookView

- (void)layoutSubviews {
    %orig;
    
    NSArray<UIView *> *topSubviews = self.subviews;
    UIView *mainBackground;
    for (UIView *subView in topSubviews) {
        if (subView.class == %c(NCMaterialView)) {
            mainBackground = subView;
            break;
        }
    }
    
    configureMainBackgroundView(mainBackground.subviews.firstObject.subviews.lastObject);
    
    UIColor *ourWhite = ourCachedWhite();
    for (UILabel *label in self._notificationContentView.subviews.firstObject.subviews) {
        if ([label respondsToSelector:@selector(setTextColor:)]) {
            label.textColor = ourWhite;
        }
    }
}

%end

// Make sure those filters are really removed
%hook NCLookHeaderContentView

- (void)_configureDateLabelIfNecessary {
    %orig;
    
    UILabel *dateLabel = self._dateLabel;
    UILabel *titleLabel = self._titleLabel;
    UIColor *ourWhite = ourCachedWhite();
    
    dateLabel.layer.filters = NULL;
    titleLabel.layer.filters = NULL;
    
    dateLabel.textColor = ourWhite;
    titleLabel.textColor = ourWhite;
}

%end

// Make all materialviews clear
%hook NCMaterialView

- (void)setBackgroundColor:(UIColor *)color {
    %orig(UIColor.clearColor);
}

%end
