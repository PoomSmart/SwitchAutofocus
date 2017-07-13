#import "../PS.h"
#import "../PSPrefs.x"

NSString *const tweakIdentifier = @"com.PS.SwitchAutofocus";
NSString *const autoFocusMode = @"autoFocusMode";
NSString *const tweakEnabledKey = @"tweakEnabled";
NSString *const startupEnabledKey = @"startupEnabled";

DeclarePrefsTools()

#ifndef MAIN

static void writeIntegerValueForKey(int value, NSString *key){
    setIntForKey(value, key);
}

static int integerValueForKey(NSString *key, int defaultValue){
    return intForKey(key, defaultValue);
}

#endif

#ifndef PREF

static BOOL boolValueForKey(NSString *key, int defaultValue){
    return boolForKey(key, defaultValue);
}

#endif
