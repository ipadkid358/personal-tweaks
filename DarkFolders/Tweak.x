#import <UIKit/UIKit.h>

@interface SBIconBlurryBackgroundView : UIView
@end

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end

@interface SBFolderBackgroundView : UIView
@end


%hook SBFolderIconBackgroundView

- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
    %orig(CGRectNull, NULL, NULL);
    
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
}

%end

%hook SBFolderBackgroundView

- (void)layoutSubviews {
    %orig;
    
    UIView *tintView = [self valueForKey:@"_tintView"];
    tintView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
}

%end
