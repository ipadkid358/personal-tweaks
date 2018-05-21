ARCHS = arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ScreenRecordSwitch
ScreenRecordSwitch_FILES = ScreenRecordSwitch.m
ScreenRecordSwitch_CFLAGS = -fobjc-arc
ScreenRecordSwitch_PRIVATE_FRAMEWORKS = ControlCenterUI
ScreenRecordSwitch_LIBRARIES = flipswitch
ScreenRecordSwitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
