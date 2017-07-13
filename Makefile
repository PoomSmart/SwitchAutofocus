GO_EASY_ON_ME = 1
DEBUG = 0
PACKAGE_VERSION = 1.3

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = SwitchAutofocusTweak
SUBPROJECTS = SAFiOS67 SAFiOS8 SAFiOS910

include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = SwitchAutofocus
SwitchAutofocus_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = SAFSettings
SAFSettings_FILES = SAFPreferenceController.m
SAFSettings_INSTALL_PATH = /Library/PreferenceBundles
SAFSettings_PRIVATE_FRAMEWORKS = Preferences
SAFSettings_FRAMEWORKS = CoreGraphics Social UIKit
SAFSettings_LIBRARIES = cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SAF.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
