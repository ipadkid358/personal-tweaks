#import <UIKit/UIKit.h>

@interface CKBalloonChatItem
@property (nonatomic, assign, readonly) BOOL failed;
@end

@interface CKMessagePartChatItem : CKBalloonChatItem
@end

// Settings darkmode as theme
%hook CKUIBehaviorPhone
- (id)theme {
    return [%c(CKUIThemeDark) new];
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
    UIView *tv = %orig;
    // only when creating a new message, it's a UILabel
    if ([tv respondsToSelector:@selector(setTextColor:)]) {
        UILabel *tl = (UILabel *)tv;
        tl.textColor = UIColor.whiteColor;
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

// The original tweak has a hook here labeled "fix message entry inactive color"
// It was for -collpasedPlaceholderLabel on CKMessageEntryView, which I've never seen visible

// set messages to red if they fail to send
%hook CKMessagePartChatItem
- (char)color {
    return self.failed ? 3 : %orig;
}
%end
