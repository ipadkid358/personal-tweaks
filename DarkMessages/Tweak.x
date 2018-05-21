#import <UIKit/UIKit.h>

@interface CKBalloonChatItem
@property (nonatomic, assign, readonly) BOOL failed;
@end

@interface CKMessagePartChatItem : CKBalloonChatItem
@end

@interface CKUITheme : NSObject
@end

@interface CKUIThemeDark : CKUITheme
@end

// set darkmode as theme
%hook CKUIBehaviorPhone

- (CKUITheme *)theme {
    // This requires private frameworks for iOS 10 to link against
    return [CKUIThemeDark new];
}

%end

// fix navbar: style
%hook CKAvatarNavigationBar

- (void)_setBarStyle:(int)style {
    %orig(1);
}

%end

// fix navbar: contact names
%hook CKAvatarContactNameCollectionReusableView

- (void)setStyle:(int)style {
    %orig(3);
}

%end

// fix navbar: group names
%hook CKAvatarTitleCollectionReusableView

- (void)setStyle:(int)style {
    %orig(3);
}

%end

// fix navbar: new message label
%hook CKNavigationBarCanvasView

- (UIView *)titleView {
    UIView *title = %orig;
    
    // only when creating a new message, it's a UILabel
    if ([title respondsToSelector:@selector(setTextColor:)]) {
        UILabel *label = (UILabel *)title;
        label.textColor = UIColor.whiteColor;
    }
    
    return title;
}

%end

// fix group details: contact names
%hook CKDetailsContactsTableViewCell

- (UILabel *)nameLabel {
    UILabel *label = %orig;
    label.textColor = UIColor.whiteColor;
    return label;
}

%end

// set messages to red if they fail to send
%hook CKMessagePartChatItem

- (char)color {
    return (self.failed ? 3 : %orig);
}

%end
