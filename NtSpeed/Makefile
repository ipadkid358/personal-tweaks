TARGET = iphone:clang:11.2:11.2
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NtSpeed
NtSpeed_FILES = Tweak.mm
NtSpeed_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
