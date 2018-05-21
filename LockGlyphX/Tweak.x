#import <UIKit/UIKit.h>

@interface PKGlyphView : UIView

@property (nonatomic) id delegate;
@property (nonatomic) BOOL fadeOnRecognized;
@property (nonatomic, copy) UIColor *primaryColor;
@property (nonatomic, copy) UIColor *secondaryColor;
@property (nonatomic, readonly) int state;

- (instancetype)initWithStyle:(UITableViewStyle)style;
- (void)setState:(int)state animated:(BOOL)animated completionHandler:(void (^)(void))block;

@end

@interface PKFingerprintGlyphView : UIView
@property (nonatomic, readonly) UIView *contentView;
@end

@interface SBLockScreenViewControllerBase : UIViewController
- (BOOL)isPasscodeLockVisible;
@end


@interface SBLockScreenManager : NSObject
+ (instancetype)sharedInstance;
@property (readonly) BOOL isUILocked;
@end

@interface SBDashBoardViewBase : UIView
@end

@interface SBDashBoardPageViewBase : SBDashBoardViewBase
@property (nonatomic, weak) UIViewController *pageViewController;
@end

@interface SBDashBoardViewControllerBase : UIViewController
@end

@interface SBDashBoardNotificationListViewController : SBDashBoardViewControllerBase
@end

#define kGlyphStateDefault  0
#define kGlyphStateScanning 1

#define kTouchIDFingerUp   0
#define kTouchIDFingerDown 1
#define kTouchIDMatched    3
#define kTouchIDSuccess    4
#define kTouchIDDisabled   6
#define kTouchIDNotMatched 10


static PKGlyphView *fingerglyph = NULL;

static UIColor *primaryColor = NULL;
static UIColor *secondaryColor = NULL;

static BOOL authenticated = NO;
static BOOL doingScanAnimation = NO;
static BOOL isObservingForCCCF = NO;
static BOOL canStartFingerDownAnimation = NO;

// Taken from this StackOverflow answer: http://stackoverflow.com/a/26081621
static void addFingerShineAnimation() {
    CAGradientLayer *gradient = CAGradientLayer.layer;
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    gradient.frame = CGRectMake(0, 0, 189, 63);
    
    id lowerAlpha = (id)[[UIColor colorWithWhite:1 alpha:0.78] CGColor];
    id higherAlpha = (id)[[UIColor colorWithWhite:1 alpha:1.0] CGColor];
    gradient.colors = @[lowerAlpha, lowerAlpha, higherAlpha, higherAlpha, higherAlpha, lowerAlpha, lowerAlpha];
    gradient.locations = @[@0.0, @0.4, @0.45, @0.5, @0.55, @0.6, @1.0];
    
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.duration = 2;
    theAnimation.repeatCount = INFINITY;
    theAnimation.autoreverses = NO;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue = @(-126);
    theAnimation.toValue = @0;
    [gradient addAnimation:theAnimation forKey:@"animateLayer"];
    
    fingerglyph.layer.mask = gradient;
}

static void performFingerScanAnimation() {
    if (canStartFingerDownAnimation && fingerglyph) {
        doingScanAnimation = YES;
        [fingerglyph setState:kGlyphStateScanning animated:YES completionHandler:^{
            doingScanAnimation = NO;
        }];
    }
}

static void resetFingerScanAnimation() {
    [UIView animateWithDuration:0.5 animations:^{
        fingerglyph.alpha = 1;
    }];
    
    [fingerglyph setState:kGlyphStateDefault animated:YES completionHandler:nil];
}

static void performShakeFingerFailAnimation() {
    if (fingerglyph) {
        CABasicAnimation *shakeanimation = [CABasicAnimation animationWithKeyPath:@"position"];
        shakeanimation.duration = 0.05;
        shakeanimation.repeatCount = 4;
        shakeanimation.autoreverses = YES;
        
        shakeanimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(fingerglyph.center.x - 10, fingerglyph.center.y)];
        shakeanimation.toValue = [NSValue valueWithCGPoint:CGPointMake(fingerglyph.center.x + 10, fingerglyph.center.y)];
        [fingerglyph.layer addAnimation:shakeanimation forKey:@"position"];
    }
}

// setup or clean up glyph
%hook SBDashBoardPageViewBase

- (void)didMoveToWindow {
    %orig;
    
    if (![self.pageViewController isKindOfClass:objc_getClass("SBDashBoardMainPageViewController")]) {
        return;
    }
    
    // main page is leaving it's window, do some clean up
    if (!self.window) {
        [fingerglyph removeFromSuperview];
        fingerglyph = nil;
        
        return;
    }
    
    authenticated = NO;
    canStartFingerDownAnimation = NO;
    
    if (fingerglyph) {
        return;
    }
    
    if (!primaryColor) {
        primaryColor = UIColor.whiteColor;
    }
    if (!secondaryColor) {
        secondaryColor = UIColor.clearColor;
    }
    
    fingerglyph = [[PKGlyphView alloc] initWithStyle:0];
    fingerglyph.delegate = self;
    fingerglyph.primaryColor = primaryColor;
    fingerglyph.secondaryColor = secondaryColor;
    
    [fingerglyph setState:kGlyphStateDefault animated:NO completionHandler:nil];
    
    fingerglyph.frame = CGRectMake(0, 0, 63, 63);
    fingerglyph.center = CGPointMake(207, 672);
    
    addFingerShineAnimation();
    
    [self addSubview:fingerglyph];
    canStartFingerDownAnimation = YES;
    
    // listen for notifications from ColorFlow/CustomCover
    if (!isObservingForCCCF) {
        void (^lgRevertUI)(NSNotification *) = ^(NSNotification *note) {
            primaryColor = UIColor.whiteColor;
            secondaryColor = UIColor.clearColor;
            
            if (fingerglyph) {
                fingerglyph.primaryColor = primaryColor;
                fingerglyph.secondaryColor = secondaryColor;
            }
        };
        
        void (^lgColorizeUI)(NSNotification *) = ^(NSNotification *note) {
            NSDictionary *userInfo = note.userInfo;
            NSString *noteName = note.name;
            if ([noteName isEqualToString:@"ColorFlowLockScreenColorizationNotification"]) {
                primaryColor = userInfo[@"PrimaryColor"];
                secondaryColor = userInfo[@"SecondaryColor"];
            }
            if ([noteName isEqualToString:@"CustomCoverLockScreenColourUpdateNotification"]) {
                primaryColor = userInfo[@"PrimaryColour"];
                secondaryColor = userInfo[@"SecondaryColour"];
            }
            
            fingerglyph.primaryColor = primaryColor;
            fingerglyph.secondaryColor = secondaryColor;
        };
        
        NSNotificationCenter *notifCenter = NSNotificationCenter.defaultCenter;
        [notifCenter addObserverForName:@"ColorFlowLockScreenColorReversionNotification" object:NULL queue:NULL usingBlock:lgRevertUI];
        [notifCenter addObserverForName:@"ColorFlowLockScreenColorizationNotification"   object:NULL queue:NULL usingBlock:lgColorizeUI];
        [notifCenter addObserverForName:@"CustomCoverLockScreenColourResetNotification"  object:NULL queue:NULL usingBlock:lgRevertUI];
        [notifCenter addObserverForName:@"CustomCoverLockScreenColourUpdateNotification" object:NULL queue:NULL usingBlock:lgColorizeUI];
        
        isObservingForCCCF = YES;
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    isObservingForCCCF = NO;
    
    %orig;
}

%end

// change some of the properties of glyphs to make it look better
%hook PKGlyphView

- (CALayer *)createCustomImageLayer {
    CALayer *result = %orig;
    
    result.contentsScale = 3;
    result.mask = nil;
    
    return result;
}

%end

// animate the glyph based on TouchID events
%hook SBDashBoardMesaUnlockBehavior

- (void)handleBiometricEvent:(NSUInteger)event {
    if (authenticated) {
        %orig;
        return;
    }
    
    SBLockScreenManager *manager = [objc_getClass("SBLockScreenManager") sharedInstance];
    if (manager.isUILocked) {
        switch (event) {
            case kTouchIDFingerDown:
                performFingerScanAnimation();
                break;
                
            case kTouchIDDisabled:
                canStartFingerDownAnimation = NO;
                %orig;
                break;
                
            case kTouchIDFingerUp:
                canStartFingerDownAnimation = YES;
                resetFingerScanAnimation();
                break;
                
            case kTouchIDNotMatched:
                performShakeFingerFailAnimation();
                break;
                
            case kTouchIDSuccess:
                authenticated = YES;
                %orig;
                break;
        }
    }
}

%end

// cut off the notification view so notifications and the glyph don't overlap, reverse engineered out of HotDog
%hook SBDashBoardNotificationListViewController

- (void)_layoutListView {
    %orig;
    
    UIView *clippingView = [self valueForKey:@"_clippingView"];
    CGRect patchRect = clippingView.frame;
    // high enough for the glyph to be nice
    patchRect.size.height = 416;
    clippingView.frame = patchRect;
}

%end
