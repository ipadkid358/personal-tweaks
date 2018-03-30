#import <objc/runtime.h>
#import <ifaddrs.h>
#import <net/if.h>

@interface SBStatusBarStateAggregator : NSObject
+ (instancetype)sharedInstance;
- (void)setUserNameOverride:(NSString *)name;
@end

@interface SpringBoard
- (BOOL)hasFinishedLaunching;
@end

static const long kilobytes = 1 << 10;
static const long megabytes = 1 << 20;

NSString *bytesFormat(long bytes) {
    @autoreleasepool {
        if (bytes < 0) {
            return @"0B/s";
        }
        if (bytes < kilobytes) {
            return [NSString stringWithFormat:@"%ldB/s", bytes];
        }
        if (bytes < megabytes) {
            return [NSString stringWithFormat:@"%.1fK/s", (double)bytes / kilobytes];
        }
        return [NSString stringWithFormat:@"%.2fM/s", (double)bytes / megabytes];
    }
}

long getBytesTotal() {
    @autoreleasepool {
        struct ifaddrs *ifa_list = 0, *ifa;
        if (getifaddrs(&ifa_list) == -1) {
            return 0;
        }
        
        uint32_t iBytes = 0;
        uint32_t oBytes = 0;
        for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
            if (AF_LINK != ifa->ifa_addr->sa_family) {
                continue;
            }
            if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) {
                continue;
            }
            if (ifa->ifa_data == 0) {
                continue;
            }
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
        
        freeifaddrs(ifa_list);
        return iBytes + oBytes;
    }
}

static long oldSpeed;

static __attribute__((constructor)) void setupSpringBoardTimer() {
    oldSpeed = getBytesTotal();
    
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
        long nowData = getBytesTotal();
        long dataDiff = nowData-oldSpeed;
        oldSpeed = nowData;
        
        SpringBoard *springboard = (SpringBoard *)UIApplication.sharedApplication;
        if (springboard.hasFinishedLaunching) {
            SBStatusBarStateAggregator *statusBarStateAggregator = [objc_getClass("SBStatusBarStateAggregator") sharedInstance];
            
            // The only ivar that setting seems to do anything at all
            [statusBarStateAggregator setUserNameOverride:bytesFormat(dataDiff)];
        }
    }];
}
