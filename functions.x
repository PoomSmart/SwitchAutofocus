#import <AVFoundation/AVFoundation.h>
#import "PSMBProgressHUD.h"
#import "Common.h"

CGFloat startupDelay = 1.0f;
CGFloat startupInterval = 1.6f;
CGFloat showInterval = 0.5f;

static int mode;
// mode = 0 - disable
// mode = 1 - just AF view
// mode = 2 - entire system

static NSString *hudStatus(){
    switch (mode) {
        case 0:
            return @"Default";
        case 1:
            return @"Hide";
        case 2:
            return @"Disable";
    }
    return nil;
}

static void showHUD(UIView *view, NSString *text, NSString *text2, double delay){
    PSMBProgressHUD *hud = [PSMBProgressHUD showHUDAddedTo:view animated:YES];
    hud.margin = 12.0f;
    hud.color = isiOS7Up ? [UIColor systemYellowColor] : [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    hud.labelColor = isiOS7Up ? [UIColor blackColor] : [UIColor whiteColor];
    hud.detailsLabelColor = isiOS7Up ? [UIColor blackColor] : [UIColor whiteColor];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.detailsLabelText = text2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [PSMBProgressHUD hideAllHUDsForView:view animated:YES];
    });
}

static void showStartupHUD(UIView *view){
    if (view == nil)
        return;
    BOOL startupEnabled = boolValueForKey(startupEnabledKey, YES);
    if (!startupEnabled)
        return;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, startupDelay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        showHUD(view, @"Autofocus mode", hudStatus(), startupInterval);
    });
}

static void createDoubleTapGestureRecognizer(UIView *view){
    UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(saf_handleDoubleTap:)] autorelease];
    doubleTapRecognizer.numberOfTouchesRequired = 2;
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.cancelsTouchesInView = NO;
    doubleTapRecognizer.delaysTouchesEnded = NO;
    doubleTapRecognizer.delegate = (id <UIGestureRecognizerDelegate>)view;
    //[MSHookIvar<UITapGestureRecognizer *>(self, "_doubleTapGestureRecognizer") requireGestureRecognizerToFail:doubleTapRecognizer];
    //[MSHookIvar<UITapGestureRecognizer *>(self, "_singleTapGestureRecognizer") requireGestureRecognizerToFail:doubleTapRecognizer];
    [view addGestureRecognizer:doubleTapRecognizer];
}

static void switchFocusMode(AVCaptureDevice *currentDevice, UIView *view){
    mode = integerValueForKey(autoFocusMode, 0);
    for (PSMBProgressHUD *hud in [PSMBProgressHUD allHUDsForView:view]) {
        if (hud.opacity != 0)
            return;
    }
    if (mode == 2)
        mode = 0;
    else
        mode++;
    BOOL failed = NO;
    [currentDevice lockForConfiguration:nil];
    if (mode == 2)
        currentDevice.focusMode = AVCaptureFocusModeLocked;
    else {
        if ([currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            currentDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        else if ([currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus])
            currentDevice.focusMode = AVCaptureFocusModeAutoFocus;
        else
            failed = YES;
    }
    [currentDevice unlockForConfiguration];
    if (failed)
        showHUD(view, @"Error", @"No such autofocus mode available", showInterval);
    else
        showHUD(view, hudStatus(), nil, showInterval);
}

static BOOL checkFocus(BOOL checker, UIView *view){
    if (checker) {
        showHUD(view, @"AE/AF LOCK", @"Cannot switch mode.", showInterval);
        return NO;
    }
    return YES;
}

static void saf_handleDoubleTap(AVCaptureDevice *currentDevice, UIView *view, int cameraDevice, BOOL checker){
    if (cameraDevice != 0)
        return;
    if (!checkFocus(checker, view))
        return;
    switchFocusMode(currentDevice, view);
    writeIntegerValueForKey(mode, autoFocusMode);
}
