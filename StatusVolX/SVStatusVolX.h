#import <Foundation/Foundation.h>

@interface SVStatusVolX : NSObject

@property (nonatomic) BOOL showingVolume;

- (void)showVolume:(float)vol;
- (NSString *)volumeString;

@end
