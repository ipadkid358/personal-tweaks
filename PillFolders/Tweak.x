#import <UIKit/UIKit.h>


%hook SBFolderIconListView

+ (NSUInteger)iconColumnsForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation) ? 4 : 3;
}

+ (NSUInteger)maxVisibleIconRowsInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}

%end

%hook SBFloatyFolderView

- (CGRect)_frameForScalingView {
    CGRect frame = %orig;
    
    if (UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation)) {
        CGFloat const xInset = 30;
        frame.size.height = 196;
        frame.size.width = 414-(xInset*2);
        frame.origin.y = 396;
        frame.origin.x = xInset;
    }
    
    return frame;
}

%end

%hook SBFolderIconListView

- (CGFloat)bottomIconInset {
    return 0;
}

%end
