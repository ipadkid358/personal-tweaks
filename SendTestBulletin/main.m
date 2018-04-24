#import <Foundation/Foundation.h>
#import "SharedInfo.h"

int main(int argc, char *argv[]) {
    NSString *title = @"Notification Title";
    NSString *subtitle = @"Notification Subtitle";
    NSString *section = @"com.apple.MobileSMS";
    NSString *message = @"This is the notification message.";
    {
        int c;
        while ((c = getopt(argc, argv, ":t:s:b:m:")) != -1) {
            switch (c) {
                case 't':
                    title = [NSString stringWithUTF8String:optarg];
                    break;
                case 's':
                    subtitle = [NSString stringWithUTF8String:optarg];
                    break;
                case 'b':
                    section = [NSString stringWithUTF8String:optarg];
                    break;
                case 'm':
                    message = [NSString stringWithUTF8String:optarg];
                    break;
                case '?': {
                    printf("Usage: %s [options]\n"
                           " -t    Title\n"
                           " -s    Subtitle\n"
                           " -b    BundleID\n"
                           " -m    Message\n", argv[0]);
                    return 1;
                }
            }
        }
    }
    
    NSDictionary *data = @{
                           kSTBTitleKey : title,
                           kSTBSubitleKey : subtitle,
                           kSTBSectionKey : section,
                           kSTBMessageKey : message,
                           };
    LMConnectionSendOneWayData(&bulletinInfoVessel, 0, (__bridge CFDataRef)LMDataForPropertyList(data));
}
