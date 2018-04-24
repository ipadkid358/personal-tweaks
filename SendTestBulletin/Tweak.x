#import <Foundation/Foundation.h>
#import "SharedInfo.h"
#import <objc/runtime.h>
#import <dlfcn.h>

@interface BBAction : NSObject
+ (instancetype)action;
@end

@interface BBBulletin : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *bulletinID;
@property (nonatomic, copy) NSString *sectionID;
@property (nonatomic, copy) NSString *recordID;
@property (nonatomic, copy) NSString *publisherBulletinID;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate *lastInterruptDate;
@property (nonatomic, retain) NSDate *publicationDate;
@property (nonatomic, copy) BBAction *defaultAction;
@property (nonatomic, assign) BOOL clearable;
@property (nonatomic, assign) BOOL showsMessagePreview;
@end

@interface BBBulletinRequest : BBBulletin
@end

@interface BBServer : NSObject
- (void)publishBulletinRequest:(BBBulletinRequest *)bulletin destinations:(NSUInteger)dest alwaysToLockScreen:(BOOL)alwaysLS;
@end

@interface SBNotificationCenterController : NSObject
+ (instancetype)sharedInstance;
- (void)presentAnimated:(BOOL)animated;
@end

extern dispatch_queue_t __BBServerQueue;

static BBServer *bbServer = NULL;

// Thanks https://github.com/thomasfinch/PriorityHub/blob/master/tweak/Tweak.xm#L104
// and https://github.com/hbang/TypeStatus/blob/master/springboard/SpringBoard.x#L10
static void createUserNotificationFromRequest(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
    if ((size_t)size < sizeof(LMMessage)) {
        return;
    }
    
    const void *rawMessageData = LMMessageGetData(request);
    CFDataRef messageData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rawMessageData, LMMessageGetDataLength(request), kCFAllocatorNull);
    NSDictionary <NSString *, NSString *> *userInfo = LMPropertyListForData((__bridge NSData *)messageData);
    
    dispatch_async(__BBServerQueue, ^{
        static unsigned unqiueCounter = 0;
        unqiueCounter++;
        
        NSString *bulletinID = [NSString stringWithFormat:@"com.ipadkid.stb-%d", unqiueCounter];
        NSDate *date = [NSDate date];
        
        BBBulletinRequest *bulletin = [BBBulletinRequest new];
        bulletin.title = userInfo[kSTBTitleKey];
        bulletin.subtitle = userInfo[kSTBSubitleKey];
        bulletin.sectionID = userInfo[kSTBSectionKey];
        bulletin.message = userInfo[kSTBMessageKey];
        bulletin.recordID = bulletinID;
        bulletin.publisherBulletinID = bulletinID;
        bulletin.clearable = YES;
        bulletin.showsMessagePreview = YES;
        bulletin.date = date;
        bulletin.publicationDate = date;
        bulletin.lastInterruptDate = date;
        bulletin.defaultAction = [BBAction action];
        
        [bbServer publishBulletinRequest:bulletin destinations:15 alwaysToLockScreen:NO];
    });
}

%hook BBServer

- (id)init {
    bbServer = %orig;
    LMStartService(bulletinInfoVessel.serverName, CFRunLoopGetMain(), (CFMachPortCallBack)createUserNotificationFromRequest);
    return bbServer;
}

%end
