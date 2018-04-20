#import <UIKit/UIKit.h>

@interface SBPocketStateMonitor : NSObject
@end

@interface SBBacklightController : NSObject
@property (nonatomic, readonly) BOOL screenIsOn;
@end

@interface SpringBoard
- (void)_simulateLockButtonPress;
- (void)_simulateHomeButtonPress;
@end


%hook SBBacklightController

- (void)pocketStateMonitor:(SBPocketStateMonitor *)stateMonitor pocketStateDidChangeFrom:(long long)changeFrom to:(long long)changeTo {
    %orig;
    
    // filter plist indicates this tweak should only be loaded into SpringBoard
    SpringBoard *springBoard = (SpringBoard *)UIApplication.sharedApplication;
    BOOL screenIsOn = self.screenIsOn;
    
    /*   Possible change values  *
     *  0: up                    *
     *  2: down                  *
     *  3: unknown               *
     *  Never seen 1 show up     */
    
    if ((changeTo == 2) && screenIsOn) {
        [springBoard _simulateLockButtonPress];
    }
    
    if ((changeTo == 0) && !screenIsOn) {
        [springBoard _simulateHomeButtonPress];
    }
}

%end
