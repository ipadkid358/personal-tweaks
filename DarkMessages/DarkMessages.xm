#import <UIKit/UIKit.h>

@interface CKUITheme : NSObject
@end

@interface CKUIThemeDark : CKUITheme
- (UIColor *)entryFieldDarkStyleButtonColor;
@end

typedef NS_ENUM(NSUInteger, CKBalloonViewColor) {
    CKBalloonViewColorGreen,
    CKBalloonViewColorBlue,
    CKBalloonViewColorWhite,
    CKBalloonViewColorRed,
    CKBalloonViewColorWhiteAgain,
    CKBalloonViewColorBlack
};

@interface CKChatItem : NSObject
@end

@interface CKBalloonChatItem : CKChatItem
@property (nonatomic, assign, readonly) BOOL failed;
@end

@interface CKMessagePartChatItem : CKBalloonChatItem
@end

static CKUIThemeDark *darkTheme;

//------------------------------------------------------------------------------


%hook CKUIBehaviorPhone
- (id)theme {
    darkTheme = [%c(CKUIThemeDark) new];
    return darkTheme;
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
- (id)titleView {
    id tv = %orig;
    if (tv && [tv respondsToSelector:@selector(setTextColor:)]) {
        [(UILabel *)tv setTextColor:UIColor.whiteColor];
    }
    return tv;
}
%end

// fix group details: contact names
%hook CKDetailsContactsTableViewCell
- (UILabel *)nameLabel {
    UILabel *nl = %orig;
    nl.textColor = UIColor.whiteColor;
    return nl;
}
%end

// fix message entry inactive color
%hook CKMessageEntryView
- (UILabel *)collpasedPlaceholderLabel {
    UILabel *label = %orig;
    label.textColor = [darkTheme entryFieldDarkStyleButtonColor];
    return label;
}
%end

// set messages to red if they fail to send
%hook CKMessagePartChatItem
- (CKBalloonViewColor)color {
    return self.failed ? CKBalloonViewColorRed : %orig;
}
%end
