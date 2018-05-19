ARCHS = arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ScreenRecordSwitch
ScreenRecordSwitch_FILES = Switch.mm
ScreenRecordSwitch_CFLAGS = -fobjc-arc
ScreenRecordSwitch_LIBRARIES = flipswitch substrate
ScreenRecordSwitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
