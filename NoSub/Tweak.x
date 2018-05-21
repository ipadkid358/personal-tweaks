#import <Foundation/Foundation.h>

@interface FBBundleInfo : NSObject
@property (nonatomic, copy) NSString *bundleIdentifier;
@end

@interface FBApplicationInfo : FBBundleInfo
@end

// list of apps (by bundleID) that should not have substrate loaded into them
static NSDictionary<NSString *, id> *blacklist = NULL;

%hook FBApplicationInfo

- (NSDictionary *)environmentVariables {
    NSDictionary *originalEnv = %orig;
    
    if ([blacklist[self.bundleIdentifier] boolValue]) {
        NSMutableDictionary *env = originalEnv ? [NSMutableDictionary dictionaryWithDictionary:originalEnv] : [NSMutableDictionary dictionary];
        
        [env removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
        env[@"_MSSafeMode"] = @"1";
        originalEnv = [NSDictionary dictionaryWithDictionary:env];
    }
    
    return originalEnv;
}

%end

%ctor {
    blacklist = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ipadkid.nosub.plist"];
    %init;
}
