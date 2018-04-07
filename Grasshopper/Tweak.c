#include <substrate.h>
#include <CoreFoundation/CoreFoundation.h>

BOOL MGGetBoolAnswer(CFStringRef key);

static BOOL (*originalMGGetBoolAnswer)(CFStringRef key);

static BOOL patchedMGGetBoolAnswer(CFStringRef key) {
    if (CFEqual(key, CFSTR("nVh/gwNpy7Jv1NOk00CMrw")) || CFEqual(key, CFSTR("ESA7FmyB3KbJFNBAsBejcg"))) {
        return YES;
    }
    
    return originalMGGetBoolAnswer(key);
}

static __attribute__((constructor)) void setupPegasusHooks() {
    MSHookFunction((void *)MGGetBoolAnswer, (void *)&patchedMGGetBoolAnswer, (void **)&originalMGGetBoolAnswer);
} 
