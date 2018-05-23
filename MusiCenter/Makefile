ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MusiCenter
MusiCenter_FILES = Tweak.x BJMusiCenterView.m
MusiCenter_CFLAGS = -fobjc-arc
MusiCenter_PRIVATE_FRAMEWORKS = MediaRemote ControlCenterUIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
