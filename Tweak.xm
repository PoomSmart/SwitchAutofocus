#define MAIN
#import "Common.h"
#import <dlfcn.h>

%ctor
{
    BOOL isSpringBoard = [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"];
    if (isSpringBoard && isiOS7Up)
        return;
    BOOL tweakEnabled = boolValueForKey(tweakEnabledKey, YES);
    if (tweakEnabled) {
        if (isiOS9Up)
            dlopen("/Library/Application Support/SAF/SAFiOS910.dylib", RTLD_LAZY);
        else if (isiOS8)
            dlopen("/Library/Application Support/SAF/SAFiOS8.dylib", RTLD_LAZY);
        else
            dlopen("/Library/Application Support/SAF/SAFiOS67.dylib", RTLD_LAZY);
    }
}
