#include <CoreFoundation/CoreFoundation.h>
#include <substrate.h>

// http://iphonedevwiki.net/index.php/LibMobileGestalt.dylib#MGGetBoolAnswer_.28iOS_7.2B.29
CFBooleanRef MGGetBoolAnswer(CFStringRef key);

static CFBooleanRef (*originalMGGetBoolAnswer)(CFStringRef);

// https://blog.timac.org/2017/0124-deobfuscating-libmobilegestalt-keys/
static CFBooleanRef patchedMGGetBoolAnswer(CFStringRef key) {
    // "nVh/gwNpy7Jv1NOk00CMrw" -> "MedusaPIPCapability"
    Boolean isMedusa = CFEqual(key, CFSTR("nVh/gwNpy7Jv1NOk00CMrw"));
    // "ESA7FmyB3KbJFNBAsBejcg" -> "ui-pip"
    Boolean isUI_PIP = CFEqual(key, CFSTR("ESA7FmyB3KbJFNBAsBejcg"));
    
    if (isMedusa || isUI_PIP) {
        return kCFBooleanTrue;
    }
    
    return originalMGGetBoolAnswer(key);
}

static __attribute__((constructor)) void setupPegasusHooks() {
    MSHookFunction(MGGetBoolAnswer, (void *)&patchedMGGetBoolAnswer, (void **)&originalMGGetBoolAnswer);
} 
