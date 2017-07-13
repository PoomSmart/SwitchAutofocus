#import <substrate.h>
#import "../functions.x"

%group preiOS7

%hook PLCameraView

- (id)initWithFrame: (CGRect)frame
{
    self = %orig;
    showStartupHUD(self);
    return self;
}

%end

%end

%group iOS7

%hook PLCameraView

- (id)initWithFrame: (CGRect)frame spec: (id)spec
{
    self = %orig;
    showStartupHUD(self);
    return self;
}

%end

%hook PLCameraController

- (void)smoothFocusAtCenter
{
    if (mode == 2)
        return;
    %orig;
}

%end

%end

%hook PLCameraView

- (void)cameraControllerFocusDidStart: (PLCameraController *)controller
{
    if (mode == 2) {
        if (controller.currentDevice.focusMode == 2)
            return;
    }
    %orig;
}

- (void)_createPreviewViewAndContainerView {
    %orig;
    createDoubleTapGestureRecognizer(self);
}

%new
- (void)saf_handleDoubleTap: (UIGestureRecognizer *)tap
{
    PLCameraController *controller = MSHookIvar<PLCameraController *>(self, "_cameraController");
    saf_handleDoubleTap(controller.currentDevice, self, self.cameraDevice, MSHookIvar<BOOL>(self, "_focusIsLocked"));
}

%end

%hook PLCameraController

- (void)autofocus
{
    if (mode == 2)
        return;
    %orig;
}

- (void)performAutofocusAfterCapture {
    if (mode == 2)
        return;
    %orig;
}

%end

%hook PLCameraPreviewView

- (void)showAutofocusView
{
    if (mode == 1)
        return;
    %orig;
}

- (void)removeAutofocusView {
    if (mode == 1)
        return;
    %orig;
}

%end

%ctor
{
    mode = integerValueForKey(autoFocusMode, 0);
    openCamera7();
    if (isiOS7) {
        %init(iOS7);
    } else {
        %init(preiOS7);
    }
    %init;
}
