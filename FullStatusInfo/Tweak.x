#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

#define FAKE_BATTERY_PERCENTAGE 11800642
#define floatsEqualWithPrecision(a, b, p) ((a) > ((b)-(p))) && ((a) < ((b)+(p)))

@interface SBStatusBarStateAggregator : NSObject
@end

@interface BCBatteryDevice : NSObject
@property (assign, nonatomic) NSInteger percentCharge;
@end


%hook SBStatusBarStateAggregator

- (void)_resetTimeItemFormatter {
    %orig;
    
    NSDateFormatter *timeFormat = [self valueForKey:@"_timeItemDateFormatter"];
    timeFormat.dateFormat = @"h:mm a   M/d/yy ";
}

- (void)_updateBatteryItems:(BCBatteryDevice *)items {
    items.percentCharge = FAKE_BATTERY_PERCENTAGE;
    %orig;
}

%end

%hook NSNumberFormatter

- (NSString *)stringFromNumber:(NSNumber *)number {
    if (self.numberStyle == 3) {
        float numValue = number.floatValue;
        float targetVal = FAKE_BATTERY_PERCENTAGE/100.0;
        if (floatsEqualWithPrecision(numValue, targetVal, 1.5)) {
            io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPMPowerSource"));
            
            CFTypeRef currentCapacity = IORegistryEntryCreateCFProperty(service, CFSTR("AppleRawCurrentCapacity"), kCFAllocatorDefault, 0);
            CFTypeRef maxCapacity = IORegistryEntryCreateCFProperty(service, CFSTR("AppleRawMaxCapacity"), kCFAllocatorDefault, 0);
            CFTypeRef instantAmperage = IORegistryEntryCreateCFProperty(service, CFSTR("InstantAmperage"), kCFAllocatorDefault, 0);
            
            SInt32 current = 0, max = 0, amperage = 0;
            CFNumberGetValue(currentCapacity, kCFNumberSInt32Type, &current);
            CFNumberGetValue(maxCapacity, kCFNumberSInt32Type, &max);
            CFNumberGetValue(instantAmperage, kCFNumberSInt32Type, &amperage);
            
            CFRelease(currentCapacity);
            CFRelease(maxCapacity);
            
            double percent = 100.0*current/max;
            
            NSString *chargingInd = (amperage > 0) ? @"↑" : @"";
            return [NSString stringWithFormat:@"%@%d mAh  |  %.1f%%", chargingInd, amperage, percent];
        }
    }
    
    return %orig;
}

%end

%hook SBDashBoardViewController

- (NSInteger)statusBarStyle {
    // http://bensge.com/blog/blog/2014/06/22/uistatusbar-research/
    return 303;
}

%end
