#import <UIKit/UIKit.h>

@interface UIStatusBarForegroundStyleAttributes : NSObject
- (id)textColorForStyle:(int)style;
- (int)legibilityStyle;
@end

@interface UIStatusBarTimeItemView : UIView
@property (readonly, nonatomic) UIStatusBarForegroundStyleAttributes *foregroundStyle;
@end

@interface _UILegibilityImageSet
+ (id)imageFromImage:(UIImage *)image withShadowImage:(id)shadowImage;
@end


%hook UIStatusBarTimeItemView
- (id)imageWithText:(NSString *)text {
    if ((text.length > 0) && ([text characterAtIndex:0] == '#')) {
        int val = [[text substringFromIndex:1] intValue];
        
        // Get color from foregroundStyle
        UIStatusBarForegroundStyleAttributes *fgStyle = self.foregroundStyle;
        UIColor *fgColor = [fgStyle textColorForStyle:fgStyle.legibilityStyle];
        
        // Setup context
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(0.5+(7*16), 5.5), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        // Set line width
        CGContextSetLineWidth(ctx, 0.3);
        
        // Draw each circle
        for (int i = 0; i < 16; i++) {
            CGRect rect = CGRectMake((7*i)+0.25, 0.25, 5, 5);
            CGContextSetFillColorWithColor(ctx, fgColor.CGColor);
            CGContextSetStrokeColorWithColor(ctx, fgColor.CGColor);
            CGContextStrokeEllipseInRect(ctx, rect);
            
            // Fill appropriate ones
            if (i < val) {
                CGContextFillEllipseInRect(ctx, rect);
            }
        }
        
        // Save and flush state
        CGContextRestoreGState(ctx);
        UIImage *circles = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return [%c(_UILegibilityImageSet) imageFromImage:circles withShadowImage:NULL];
    }
    
    return %orig;
}

%end
