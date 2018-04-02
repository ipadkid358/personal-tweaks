//
//  SBSnapperWindow.m
//  SnapperRemake
//
//  Created by ipad_kid on 3/30/18.
//  Copyright © 2018 BlackJacket. All rights reserved.
//

#import "SBSnapperWindow.h"

/// Get an image representation of the current screen. Image is at full device resolution, pre-scaling. Calling with function from outside of SpringBoard will yeild a black image
UIImage *_UICreateScreenUIImage();


@implementation SBSnapperWindow {
    UIView *_internalView;
    CGPoint _startingPoint;
}

// TODO: Cut out screenshot view, instead of making it even darker
// TODO: Allow resizing of the screenshot view after dragging

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        self.windowLevel = 1200;
        
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(holdGesture:)]];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        _internalView = UIView.new;
        _internalView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.6];
        _internalView.layer.borderWidth = 1;
        _internalView.layer.borderColor = UIColor.whiteColor.CGColor;
        [_internalView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(internalViewPanGesture:)]];
        
        [self addSubview:_internalView];
    }
    
    return self;
}

- (void)internalViewPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:self];
    CGRect origFrame = _internalView.frame;
    CGPoint originPatch = origFrame.origin;
    
    CGFloat newOX = originPatch.x + translation.x;
    CGFloat newOY = originPatch.y + translation.y;
    if ((newOX >= 0) && ((origFrame.size.width + newOX) <= 414)) {
        originPatch.x = newOX;
    }
    
    if ((newOY >= 0) && ((origFrame.size.height + newOY) <= 736)) {
        originPatch.y = newOY;
    }
    
    origFrame.origin = originPatch;
    _internalView.frame = origFrame;
    
    [gestureRecognizer setTranslation:CGPointZero inView:self];
}

- (void)tapGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGRect rect = _internalView.frame;
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0 delay:0 options:0 animations:^{
        _internalView.frame = CGRectZero;
        self.hidden = YES;
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

- (void)panGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint hitPoint = [gestureRecognizer locationInView:self];
    UIGestureRecognizerState recognizerState = gestureRecognizer.state;
    CGRect framePatch = _internalView.frame;
    
    if (recognizerState == UIGestureRecognizerStateBegan) {
        framePatch.origin = _startingPoint = hitPoint;
    } else if (recognizerState == UIGestureRecognizerStateChanged) {
        CGFloat xDiff = _startingPoint.x-hitPoint.x;
        if (xDiff < 0) {
            framePatch.size.width = -1.0*xDiff;
        } else {
            framePatch.origin.x = hitPoint.x;
            framePatch.size.width = xDiff;
        }
        
        CGFloat yDiff = _startingPoint.y-hitPoint.y;
        if (yDiff < 0) {
            framePatch.size.height = -1.0*yDiff;
        } else {
            framePatch.origin.y = hitPoint.y;
            framePatch.size.height = yDiff;
        }
    }
    
    _internalView.frame = framePatch;
}

- (void)dismiss {
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:0 animations:^{
        _internalView.frame = CGRectZero;
        self.hidden = YES;
    } completion:NULL];
}

- (void)show {
    self.hidden = NO;
}

- (BOOL)_shouldCreateContextAsSecure {
    return YES;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    [self show];
}

+ (void)load {
    NSNotificationCenter *notifCenter = NSNotificationCenter.defaultCenter;
    [notifCenter addObserverForName:UIApplicationDidFinishLaunchingNotification object:NULL queue:NULL usingBlock:^(NSNotification *note) {
        SBSnapperWindow *listener = self.new;
        listener.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.25];
        [LASharedActivator registerListener:listener forName:@"com.ipadkid.snapper"];
    }];
}

@end
