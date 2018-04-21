#import <Foundation/Foundation.h>

@interface SBStatusBarStateAggregator : NSObject
@end


%hook SBStatusBarStateAggregator

- (void)_resetTimeItemFormatter {
    %orig;
    
    NSDateFormatter *timeFormat = [self valueForKey:@"_timeItemDateFormatter"];
    timeFormat.dateFormat = @"h:mm a   M/d/yy ";
}

%end
