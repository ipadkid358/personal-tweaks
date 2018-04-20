ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NativeVBug
NativeVBug_FILES = NativeVBugListener.m Tweak.xm
NativeVBug_CFLAGS = -fobjc-arc
NativeVBug_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
