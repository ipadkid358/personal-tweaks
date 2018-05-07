//
//  SBSnapperWindow.m
//  SnapperRemake
//
//  Created by ipad_kid on 3/30/18.
//  Copyright © 2018 BlackJacket. All rights reserved.
//

#import "SBSnapperWindow.h"

// hardcoded Plus width
#define kPlusWidth  414.0f
// hardcoded Plus height
#define kPlusHeight 736.0f

/// Get an image representation of the current screen. Image is at full device resolution, pre-scaling.
/// See http://iphonedevwiki.net/index.php/UIImage#UICreateScreenUIImage for more information
OBJC_EXTERN UIImage *_UICreateScreenUIImage() NS_RETURNS_RETAINED;


@implementation SBSnapperWindow {
    /// View whose frame is used for screenshot area, and is edited via GestureRecognizers
    UIView *_internalView;
    
    /// The origin when the first pan recognizer hit is registered
    CGPoint _startingPoint;
    
    /// The xDiff when first pinch recognizer hit is registered
    CGFloat _startingDiffX;
    /// The yDiff when first pinch recognizer hit is registered
    CGFloat _startingDiffY;
    /// The full rect when first pinch or drag recognizer hit is registered
    CGRect _startingRect;
    
    /// Layer used to cutout a clear image
    CAShapeLayer *_darkeningLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        self.windowLevel = 1200;
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdGesture:)]];
        [self addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)]];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        _internalView = UIView.new;
        _internalView.layer.borderWidth = 1;
        _internalView.layer.borderColor = UIColor.whiteColor.CGColor;
        // need to have a non-clear/NULL background color to allow touches to be caught
        // this is only an issue with SpringBoard presenting a window on top of another app
        _internalView.backgroundColor = [UIColor colorWithWhite:0.001 alpha:0.001];
        [_internalView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(internalViewPanGesture:)]];
        
        _darkeningLayer = CAShapeLayer.layer;
        _darkeningLayer.fillRule = kCAFillRuleEvenOdd;
        _darkeningLayer.fillColor = [[UIColor colorWithWhite:0.1 alpha:0.6] CGColor];
        [self.layer addSublayer:_darkeningLayer];
        
        [self addSubview:_internalView];
    }
    
    return self;
}

// Thanks https://stackoverflow.com/a/16518739
- (void)updateDarkeningLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRect:_internalView.frame]];
    path.usesEvenOddFillRule = YES;
    _darkeningLayer.path = path.CGPath;
}

- (void)tapGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGRect rect = _internalView.frame;
    __weak __typeof(self) weakself = self;
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0 delay:0 options:0 animations:^{
        _internalView.frame = CGRectZero;
        weakself.hidden = YES;
    } completion:^(UIViewAnimatingPosition finalPosition) {
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 3.0);
        
        UIImage *image = _UICreateScreenUIImage();
        
        CGRect patchRect = rect;
        patchRect.size = image.size;
        patchRect.origin = CGPointMake(-rect.origin.x, -rect.origin.y);
        
        [image drawInRect:patchRect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(image, NULL, NULL, NULL);
    }];
}

- (void)holdGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self dismiss];
    }
}

- (void)internalViewPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGRect origFrame = _internalView.frame;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _startingRect = origFrame;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGPoint originPatch = _startingRect.origin;
    
    CGFloat newOX = originPatch.x + translation.x;
    CGFloat newOY = originPatch.y + translation.y;
    
    if (newOX < 0)  {
        newOX = 0;
    }
    
    if (newOY < 0) {
        newOY = 0;
    }
    
    CGFloat currWidth = origFrame.size.width;
    if ((currWidth + newOX) > kPlusWidth) {
        newOX = kPlusWidth-currWidth;
    }
    
    CGFloat currHeight = origFrame.size.height;
    if ((currHeight + newOY) > kPlusHeight) {
        newOY = kPlusHeight-currHeight;
    }
    
    originPatch.x = newOX;
    originPatch.y = newOY;
    
    origFrame.origin = originPatch;
    _internalView.frame = origFrame;
    
    [self updateDarkeningLayer];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.numberOfTouches == 2) {
        CGPoint firstTouch = [gestureRecognizer locationOfTouch:0 inView:self];
        CGPoint secondTouch = [gestureRecognizer locationOfTouch:1 inView:self];
        CGFloat xDiff = ABS(firstTouch.x-secondTouch.x);
        CGFloat yDiff = ABS(firstTouch.y-secondTouch.y);
        
        UIGestureRecognizerState recognizerState = gestureRecognizer.state;
        
        if (recognizerState == UIGestureRecognizerStateBegan) {
            _startingRect = _internalView.frame;
            _startingDiffX = xDiff;
            _startingDiffY = yDiff;
        }
        
        if (recognizerState == UIGestureRecognizerStateChanged) {
            CGFloat xScale = xDiff/_startingDiffX;
            CGFloat yScale = yDiff/_startingDiffY;
            
            CGFloat lenX = _startingRect.size.width;
            CGFloat lenY = _startingRect.size.height;
            
            lenX *= xScale;
            lenY *= yScale;
            
            CGFloat origX = CGRectGetMidX(_startingRect) - (lenX/2);
            CGFloat origY = CGRectGetMidY(_startingRect) - (lenY/2);
            
            if (origX < 0)  {
                origX = 0;
            }
            
            if (origY < 0) {
                origY = 0;
            }
            
            if ((lenX + origX) > kPlusWidth) {
                lenX = kPlusWidth-origX;
            }
            
            if ((lenY + origY) > kPlusHeight) {
                lenY = kPlusHeight-origY;
            }
            
            _internalView.frame = CGRectMake(origX, origY, lenX, lenY);
        }
        
        [self updateDarkeningLayer];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint hitPoint = [gestureRecognizer locationInView:self];
    UIGestureRecognizerState recognizerState = gestureRecognizer.state;
    CGRect framePatch = _internalView.frame;
    
    if (recognizerState == UIGestureRecognizerStateBegan) {
        framePatch.origin = _startingPoint = hitPoint;
    }
    
    if (recognizerState == UIGestureRecognizerStateChanged) {
        CGFloat xDiff = _startingPoint.x-hitPoint.x;
        if (xDiff < 0) {
            framePatch.size.width = -xDiff;
        } else {
            framePatch.origin.x = hitPoint.x;
            framePatch.size.width = xDiff;
        }
        
        CGFloat yDiff = _startingPoint.y-hitPoint.y;
        if (yDiff < 0) {
            framePatch.size.height = -yDiff;
        } else {
            framePatch.origin.y = hitPoint.y;
            framePatch.size.height = yDiff;
        }
    }
    
    _internalView.frame = framePatch;
    [self updateDarkeningLayer];
}

- (void)dismiss {
    // duration, so it's not so abrupt
    __weak __typeof(self) weakself = self;
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:0 animations:^{
        _internalView.frame = CGRectZero;
        weakself.hidden = YES;
    } completion:NULL];
}

- (void)show {
    [self updateDarkeningLayer];
    self.hidden = NO;
}

// allows UIWindows to appear on the lockscreen
- (BOOL)_shouldCreateContextAsSecure {
    return YES;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [self show];
}

+ (void)load {
    NSNotificationCenter *notifCenter = NSNotificationCenter.defaultCenter;
    // loading a UIWindow before an application is done loading is bad. In this case, SpringBoard would crash when trying to set hidden to NO
    [notifCenter addObserverForName:UIApplicationDidFinishLaunchingNotification object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        // use the designated initializer to get the frame for free
        SBSnapperWindow *listener = self.new;
        // set the color here, as the designated initializer sets it to blackColor
        listener.backgroundColor = NULL;
        [LASharedActivator registerListener:listener forName:@"com.ipadkid.snapper"];
    }];
}

@end
