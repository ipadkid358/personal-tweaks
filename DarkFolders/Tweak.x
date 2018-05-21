#import <UIKit/UIKit.h>

@interface SBIconBlurryBackgroundView : UIView
@end

@interface SBFolderIconBackgroundView : SBIconBlurryBackgroundView
@end

@interface SBFolderBackgroundView : UIView
@end

// remove the fake blur and set the dark background color on closed folders
%hook SBFolderIconBackgroundView

- (void)setWallpaperBackgroundRect:(CGRect)rect forContents:(CGImageRef)contents withFallbackColor:(CGColorRef)fallbackColor {
    %orig(CGRectNull, NULL, NULL);
    
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
}

%end

// change the background color of open folders
%hook SBFolderBackgroundView

- (void)layoutSubviews {
    %orig;
    
    UIView *tintView = [self valueForKey:@"_tintView"];
    tintView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
}

%end
