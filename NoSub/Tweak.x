#import <Foundation/Foundation.h>

@interface FBBundleInfo : NSObject
@property (nonatomic, copy) NSString *bundleIdentifier;
@end

@interface FBApplicationInfo : FBBundleInfo
@end


static NSDictionary *blacklist = NULL;


%hook FBApplicationInfo

- (NSDictionary *)environmentVariables {
    NSDictionary *originalEnv = %orig;
    
    if ([[blacklist objectForKey:self.bundleIdentifier] boolValue]) {
        NSMutableDictionary *env = originalEnv ? [NSMutableDictionary dictionaryWithDictionary:originalEnv] : [NSMutableDictionary dictionary];
        
        [env removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
        [env setObject:@"1" forKey:@"_MSSafeMode"];
        originalEnv = [NSDictionary dictionaryWithDictionary:env];
    }
    
    return originalEnv;
}

%end


%ctor {
    blacklist = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ipadkid.nosub.plist"];
    %init;
}
