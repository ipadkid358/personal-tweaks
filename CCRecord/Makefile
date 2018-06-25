ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ScreenRecordSwitch
ScreenRecordSwitch_FILES = ScreenRecordSwitch.m
ScreenRecordSwitch_CFLAGS = -fobjc-arc
ScreenRecordSwitch_PRIVATE_FRAMEWORKS = ControlCenterUI
ScreenRecordSwitch_LIBRARIES = flipswitch
ScreenRecordSwitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk
