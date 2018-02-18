#include <substrate.h>

static BOOL audioOnlyAlways(id self, SEL _cmd) {
    return YES;
}

__attribute__((constructor)) void startHook() {
    MSHookMessageEx(objc_getClass("YTMSettings"), @selector(audioOnly), (IMP)&audioOnlyAlways, NULL);
}
