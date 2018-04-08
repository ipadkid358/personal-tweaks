@interface SBUIChevronView : UIView
@end

@interface SBNotificationCenterViewController : UIViewController
@property (nonatomic, readonly) SBUIChevronView *grabberView;
@end

@interface SBNotificationCenterController : NSObject
@property (nonatomic, readonly) SBNotificationCenterViewController *viewController;
@end

static UILabel *timeLabelView;
static CAShapeLayer *batteryLineLayer;

static void setupTimeBatteryView(SBNotificationCenterController *controller) {
    SBUIChevronView *grabberView = controller.viewController.grabberView;
    
    if (!timeLabelView) {
        grabberView.subviews.firstObject.hidden = YES;
        
        timeLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 62, 36)];
        timeLabelView.textAlignment = NSTextAlignmentCenter;
        timeLabelView.textColor = UIColor.whiteColor;
        timeLabelView.font = [UIFont systemFontOfSize:11.5];
        
        UIBezierPath *batteryPath = [UIBezierPath bezierPath];
        [batteryPath moveToPoint:CGPointMake(6, 30)];
        [batteryPath addLineToPoint:CGPointMake(56, 30)];
        
        batteryLineLayer = [CAShapeLayer layer];
        batteryLineLayer.path = batteryPath.CGPath;
        batteryLineLayer.fillColor = UIColor.clearColor.CGColor;
        batteryLineLayer.lineWidth = 2;
        batteryLineLayer.lineCap = kCALineCapRound;
        
        CAShapeLayer *outlineLayer = [CAShapeLayer layer];
        outlineLayer.path = batteryPath.CGPath;
        outlineLayer.fillColor = UIColor.clearColor.CGColor;
        outlineLayer.strokeColor = UIColor.whiteColor.CGColor;
        outlineLayer.lineWidth = 3.2;
        outlineLayer.lineCap = kCALineCapRound;
        
        [outlineLayer addSublayer:batteryLineLayer];
        [timeLabelView.layer addSublayer:outlineLayer];
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    timeLabelView.text = [dateFormatter stringFromDate:NSDate.date];
    
    double batteryPercent = UIDevice.currentDevice.batteryLevel;
    batteryLineLayer.strokeColor = [[UIColor colorWithRed:(1-batteryPercent) green:batteryPercent blue:0 alpha:1] CGColor];
    batteryLineLayer.strokeEnd = batteryPercent;
    
    for (UIView *brotherView in grabberView.superview.subviews) {
        if (brotherView.class == UIView.class) {
            [brotherView addSubview:timeLabelView];
        }
    }
}

void removeTimeBatteryView() {
    [timeLabelView removeFromSuperview];
}

%hook SBNotificationCenterController

- (void)_setGrabberEnabled:(BOOL)enabled {
    %orig;
    
    if (enabled) {
        setupTimeBatteryView(self);
    } else {
        removeTimeBatteryView();
    }
}

// Triggered when the grabber is actually pulled to bring down the Notification Center
- (void)_setupForViewPresentation {
    %orig;
    
    removeTimeBatteryView();
}

%end
