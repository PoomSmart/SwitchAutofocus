#import <substrate.h>
#import "../functions.x"

%hook CAMCameraView

- (void)cameraControllerFocusDidStart: (CAMCaptureController *)controller
{
    if (mode == 2) {
        if (controller.currentDevice.focusMode == 2)
            return;
    }
    %orig;
}

- (void)_createLivePreviewHierarchyIfNecessary {
    %orig;
    createDoubleTapGestureRecognizer(self);
}

- (id)initWithFrame:(CGRect)frame spec:(id)spec {
    self = %orig;
    showStartupHUD(self);
    return self;
}

%new
- (void)saf_handleDoubleTap: (UIGestureRecognizer *)tap
{
    CAMCaptureController *controller = MSHookIvar<CAMCaptureController *>(self, "_cameraController");
    saf_handleDoubleTap(controller.currentDevice, self, self.cameraDevice, MSHookIvar<BOOL>(controller, "_userLockedFocus"));
}

%end

%hook CAMCaptureController

- (void)_autofocusAfterCapture
{
    if (mode == 2)
        return;
    %orig;
}

- (void)_startContinuousAutoFocusAtCenter {
    if (mode == 2)
        return;
    %orig;
}

- (void)performAutofocusAfterCapture {
    if (mode == 2)
        return;
    %orig;
}

- (void)_subjectAreaDidChange:(id)arg1 {
    if (mode == 2)
        return;
}

%end

%hook CAMPreviewView

- (void)showContinuousAutoFocusView
{
    if (mode == 1)
        return;
    %orig;
}

- (void)removeContinuousAutoFocusView {
    if (mode == 1)
        return;
    %orig;
}

%end

%ctor
{
    mode = integerValueForKey(autoFocusMode, 0);
    openCamera8();
    %init;
}
