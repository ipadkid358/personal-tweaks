#import <UIKit/UIKit.h>

@interface FCCButtonsScrollView : UIScrollView
@end

%hook FCCButtonsScrollView

- (void)reloadButtons {
    %orig;
    
    NSBundle *templateBundle = [self valueForKey:@"templateBundle"];
    if ([templateBundle.bundleIdentifier isEqualToString:@"com.rpetrich.flipcontrolcenter.bottomshelf"]) {
        MSHookIvar<CGSize>(self, "buttonSize") = CGSizeMake(47, 47);
    }
}

%end
