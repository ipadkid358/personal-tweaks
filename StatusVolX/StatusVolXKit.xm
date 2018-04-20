#import <UIKit/UIKit.h>

@interface UIStatusBarForegroundStyleAttributes : NSObject

@property (nonatomic, retain, readonly) UIColor *tintColor;

- (id)shadowImageForImage:(id)arg1 withIdentifier:(id)arg2 forStyle:(int)arg3 withStrength:(float)arg4;
- (id)textColorForStyle:(int)arg1;
- (int)legibilityStyle;

@end

@interface UIStatusBarTimeItemView : UIView

@property (readonly, nonatomic) UIStatusBarForegroundStyleAttributes *foregroundStyle;

- (UIImage *)makeVolumeImageForState:(int)state withColor:(UIColor *)color;
- (int)textStyle;

@end

@interface _UILegibilityImageSet
+ (id)imageFromImage:(id)arg1 withShadowImage:(id)arg2;
@end


%hook UIStatusBarTimeItemView
- (id)imageWithText:(NSString *)text {
    if ((text.length > 0) && ([text characterAtIndex:0] == '#')) {
        int val = [[text substringFromIndex:1] intValue];
        
        // Get color from foregroundStyle
        UIStatusBarForegroundStyleAttributes *fgStyle = self.foregroundStyle;
        UIColor *fgColor = [fgStyle textColorForStyle:fgStyle.legibilityStyle]; // fgStyle.tintColor;
        UIImage *whiteImage = [self makeVolumeImageForState:val withColor:fgColor];
        
        return [%c(_UILegibilityImageSet) imageFromImage:whiteImage withShadowImage:nil];
    }
    
    return %orig;
}

%new(@:d@)
- (UIImage *)makeVolumeImageForState:(int)state withColor:(UIColor *)color {
    // Setup context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(0.5+(7*16), 5.5), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    // Set line width
    CGContextSetLineWidth(ctx, 0.3);
    
    // Draw each circle
    for (int i = 0; i < 16; i++) {
        CGRect rect = CGRectMake((7*i)+0.25, 0.25, 5, 5);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextStrokeEllipseInRect(ctx, rect);
        
        // Fill appropriate ones
        if (i < state) {
            CGContextFillEllipseInRect(ctx, rect);
        }
    }
    
    // Save and flush state
    CGContextRestoreGState(ctx);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

%end
