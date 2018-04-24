#define LIGHTMESSAGING_USE_ROCKETBOOTSTRAP 0

#import <LightMessaging/LightMessaging.h>

static LMConnection bulletinInfoVessel = {
    MACH_PORT_NULL,
    "com.ipadkid.stb.messaging"
};

#define kSTBTitleKey @"title"
#define kSTBSubitleKey @"subtitle"
#define kSTBSectionKey @"section"
#define kSTBMessageKey @"message"
