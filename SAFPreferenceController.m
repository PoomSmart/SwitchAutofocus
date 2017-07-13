#import <UIKit/UIKit.h>
#import <Cephei/HBListController.h>
#import <Cephei/HBAppearanceSettings.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Social/Social.h>
#import <dlfcn.h>
#define PREF
#define KILL_PROCESS
#undef MAIN
#import "Common.h"

NSString *const updateFooterNotification = @"com.PS.SwitchAutofocus.prefs.footerUpdate";

@interface SAFPreferenceController : HBListController
@property (nonatomic, retain) PSSpecifier *footerSpec;
@end

@interface SAFModesCell : PSTableCell
@end

@implementation SAFModesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    if (self == [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier]) {
        UISegmentedControl *modes = [[[UISegmentedControl alloc] initWithItems:@[@"Default", @"Hide", @"Disable"]] autorelease];
        [modes addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventValueChanged];
        if (!isiOS7Up) {
            CGRect frame = modes.frame;
            modes.frame = CGRectMake(frame.origin.x, frame.origin.y, 220.0f, 30.0f);
        }
        modes.selectedSegmentIndex = integerValueForKey(autoFocusMode, 0);
        self.accessoryView = modes;
    }
    return self;
}

- (void)modeAction:(UISegmentedControl *)segment {
    writeIntegerValueForKey(segment.selectedSegmentIndex, autoFocusMode);
    DoPostNotification();
    [NSNotificationCenter.defaultCenter postNotificationName:updateFooterNotification object:nil userInfo:nil];
}

- (SEL)action {
    return nil;
}

- (id)target {
    return nil;
}

- (SEL)cellAction {
    return nil;
}

- (id)cellTarget {
    return nil;
}

- (void)dealloc {
    [super dealloc];
}

@end

@implementation SAFPreferenceController

HavePrefs()

- (void)masterSwitch:(id)value specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:value specifier:spec];
    killProcess("Camera");
}

HaveBanner(@"SwitchAutofocus", isiOS7Up ? UIColor.systemYellowColor : UIColor.blackColor, 38.0, @"Don't let autofocus annoy you", UIColor.blackColor, 14.0)

- (id)init {
    if (self == [super init]) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = isiOS7Up ? UIColor.systemYellowColor : UIColor.blackColor;
        appearanceSettings.tableViewCellTextColor = appearanceSettings.tintColor;
        self.hb_appearanceSettings = appearanceSettings;
        UIButton *heart = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        [heart setImage:[UIImage imageNamed:@"Heart" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SAFSettings.bundle"]] forState:UIControlStateNormal];
        [heart sizeToFit];
        [heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:heart] autorelease];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateFooter:) name:updateFooterNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [super dealloc];
}

- (void)love {
    SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
    twitter.initialText = @"#SwitchAutofocus by @PoomSmart is really awesome!";
    [self.navigationController presentViewController:twitter animated:YES completion:nil];
    [twitter release];
}

- (NSString *)footerText {
    int mode = integerValueForKey(autoFocusMode, 0);
    switch (mode) {
        case 0:
            return @"Leave system default.";
        case 1:
            return @"Let camera performs autofocusing item, but without the autofocus squared crop at the center.";
        case 2:
            return @"Disable entire camera autofocusing system.";
    }
    return nil;
}

- (void)updateFooter:(NSNotification *)notification {
    [self.footerSpec setProperty:[self footerText] forKey:@"footerText"];
    [self reloadSpecifier:self.footerSpec animated:YES];
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"SAF" target:self]];
        for (PSSpecifier *spec in specs) {
            NSString *Id = [spec identifier];
            if ([Id isEqualToString:@"footer"]) {
                self.footerSpec = spec;
                break;
            }
        }
        [self updateFooter:nil];
        _specifiers = [specs copy];
    }
    return _specifiers;
}

@end
