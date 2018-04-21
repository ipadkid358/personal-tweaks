#import <Foundation/Foundation.h>

@interface SBDashBoardPasscodeViewController
- (void)passcodeLockViewCancelButtonPressed:(id)button;
@end

static BOOL needsNuke = YES;

%hook SBDashBoardPasscodeViewController

- (void)performCustomTransitionToVisible:(BOOL)visible withAnimationSettings:(id)settings completion:(id)block {
    %orig;
    
    if (needsNuke) {
        [self passcodeLockViewCancelButtonPressed:NULL];
        needsNuke = NO;
    }
}

%end
