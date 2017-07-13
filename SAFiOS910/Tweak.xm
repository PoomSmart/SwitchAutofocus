#import <substrate.h>
#import "../functions.x"

static CAMViewfinderViewController *vc = nil;

%hook CAMViewfinderViewController

- (void)viewDidLoad
{
    %orig;
    showStartupHUD(self.view);
}

- (void)_createCommonGestureRecognizersIfNecessary {
    %orig;
    createDoubleTapGestureRecognizer(self.view);
    vc = [self retain];
}

%end

%hook CAMViewfinderView

%new
- (void)saf_handleDoubleTap: (UIGestureRecognizer *)tap
{
    BOOL userLockedFocus = [vc._previewViewController _userLockedFocusAndExposure];
    AVCaptureDevice *currentDevice = vc._captureController._captureEngine.cameraDevice;
    saf_handleDoubleTap(currentDevice, self, vc._currentDevice, userLockedFocus);
    [vc._previewViewController updateIndicatorVisibilityAnimated:YES];
}

%end

%hook CAMPreviewViewController

- (BOOL)_allowUserToChangeFocusAndExposure
{
    return mode == 2 ? NO : %orig;
}

- (BOOL)_shouldDisableFocusUI {
    return mode > 0 ? YES : %orig;
}

- (BOOL)_shouldHideFocusIndicators {
    return mode > 0 ? YES : %orig;
}

%end

%ctor
{
    mode = integerValueForKey(autoFocusMode, 0);
    openCamera9();
    %init;
}
