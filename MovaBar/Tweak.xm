#import <UIKit/UIKit.h>

@interface UIStatusBarItem : NSObject

@property (nonatomic, readonly) int type;
@property (nonatomic, readonly) int priority;
@property (nonatomic, readonly) int leftOrder;
@property (nonatomic, readonly) int rightOrder;

- (BOOL)appearsOnLeft;
- (BOOL)appearsOnRight;
- (BOOL)appearsInRegion:(int)region;

- (int)leftOrder;
- (int)rightOrder;
- (int)centerOrder;

@end

@interface UIStatusBarItemView : UIView
@end

@interface UIStatusBarDataNetworkItemView : UIStatusBarItemView
@end

@interface UIStatusBarSignalStrengthItemView : UIStatusBarItemView
@end


/* types according to Tatue (Moveable9)
 * note: I have not personally confirmed
 most of these, however I trust tatue
 
 0: time
 1: Do Not Disturb
 2: airplane
 3: cellular signal strength
 4: carrier name
 5: person name
 6: data type (together)
 8: battery icon
 9: battery percent
 10: not charging
 11: bluetooth battery
 12: bluetooth indicator
 13: tty
 14: alarm
 15: "Plus"
 17: location indicator
 18: orientation lock
 20: AirPlay
 21: Siri
 22: CarPlay
 23: student
 24: VPN
 25: call forwarding
 26: activity
 27: thermal color
 28: radar
 29: electronic toll
 30: "return to last app"
 31: lock indicator
 32: liquid detection
 33: bluetooth headphones
 34: home
 39: breadcrumb
 40: "Open in Safari"
 56: data type (split)
 */

static const unsigned leftItemCount = 8;
static const unsigned rightItemCount = 6;
static const int leftItems[leftItemCount] = { 2, 3, 12, 33, 11, 6, 5, 24 };
static const int rightItems[rightItemCount] = { 8, 9, 10, 0, 18, 20 };

// what concerns me the most about this method, is that if any icon
// besides one of the ones listed above show up, it'll be completely removed
%hook UIStatusBarItem

- (int)leftOrder {
    int itemType = self.type;
    int *ptr = (int *)leftItems;
    for (int order = 0; order < leftItemCount; order++) {
        if (*ptr == itemType) {
            return order;
        }
        ptr++;
    }
    return 0;
}

- (int)rightOrder {
    int itemType = self.type;
    int *ptr = (int *)rightItems;
    for (int order = 0; order < rightItemCount; order++) {
        if (*ptr == itemType) {
            return order;
        }
        ptr++;
    }
    return 0;
}

/* regions
 0: left
 1: right
 2: center
 */
- (BOOL)appearsInRegion:(int)region {
    if (region > 1 || region < 0) {
        return NO;
    }
    
    return region ? [self appearsOnRight] : [self appearsOnLeft];
}

- (BOOL)appearsOnLeft {
    return [self leftOrder];
}

- (BOOL)appearsOnRight {
    return [self rightOrder];
}

%end

// Side effect: Remove status bar item limit
%hook UIStatusBarLayoutManager

- (CGFloat)sizeNeededForItems:(id)items {
    return 0;
}

- (CGFloat)sizeNeededForItem:(id)item {
    return 0;
}

%end

// show numbers instead of graphic for wifi
%hook UIStatusBarDataNetworkItemView

- (id)contentsImage {
    int wifiStrength = MSHookIvar<int>(self, "_wifiStrengthRaw");
    MSHookIvar<BOOL>(self, "_showRSSI") = wifiStrength;
    return %orig;
}

%end

// show numbers instead of graphic for cellular
%hook UIStatusBarSignalStrengthItemView

- (id)contentsImage {
    MSHookIvar<BOOL>(self, "_showRSSI") = YES;
    return %orig;
}

%end
