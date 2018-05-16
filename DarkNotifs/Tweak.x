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


static UIColor *cachedLightColor() {
    static UIColor *lightColor = NULL;
    if (!lightColor) {
        lightColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    }
    
    return lightColor;
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
    NSArray<UIView *> *seperatorViews = topSubviews.firstObject.subviews;
    topSubviews.lastObject.backgroundColor = NULL;
    seperatorViews.firstObject.backgroundColor = NULL;
    
    UIView *contentView = seperatorViews.lastObject.subviews.firstObject.subviews.firstObject;
    UIView *headerView = [self valueForKey:@"_headerContentView"];
    
    headerView.superview.backgroundColor = NULL;
    contentView.superview.backgroundColor = NULL;
    contentView.backgroundColor = NULL;
    
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    CALayer *thisLayer = self.layer;
    thisLayer.cornerRadius = 13;
    thisLayer.masksToBounds = YES;
    
    UIColor *ourWhite = cachedLightColor();
    for (UILabel *subLabel in contentView.subviews.firstObject.subviews) {
        if ([subLabel respondsToSelector:@selector(setTextColor:)]) {
            subLabel.textColor = ourWhite;
        }
    }
}

%end

// The standard "view" and "clear" buttons presented when notifications are slid to the left
%hook NCNotificationListCellActionButton

- (void)layoutSubviews {
    %orig;
    
    configureMainBackgroundView(self.backgroundView.subviews.firstObject.subviews.lastObject);
    self.titleLabel.textColor = cachedLightColor();
}

%end

// Main default notification view
%hook NCNotificationShortLookView

- (void)layoutSubviews {
    %orig;
    
    NSArray<UIView *> *topSubviews = self.subviews;
    for (UIView *subView in topSubviews) {
        if (subView.class == %c(NCMaterialView)) {
            configureMainBackgroundView(subView.subviews.firstObject.subviews.lastObject);
            break;
        }
    }
    
    
    UIColor *lightColor = cachedLightColor();
    UIView *contentView = [self _notificationContentView];
    for (UILabel *label in contentView.subviews.firstObject.subviews) {
        if ([label respondsToSelector:@selector(setTextColor:)]) {
            label.textColor = lightColor;
        }
    }
}

%end

// Make sure those filters are really removed
%hook NCLookHeaderContentView

- (void)_configureDateLabelIfNecessary {
    %orig;
    
    UILabel *dateLabel = [self _dateLabel];
    UILabel *titleLabel = [self _titleLabel];
    UIColor *lightColor = cachedLightColor();
    
    dateLabel.layer.filters = NULL;
    titleLabel.layer.filters = NULL;
    
    dateLabel.textColor = lightColor;
    titleLabel.textColor = lightColor;
}

%end

// Make all materialviews clear
%hook NCMaterialView

- (void)setBackgroundColor:(UIColor *)color {
    %orig(UIColor.clearColor);
}

%end
