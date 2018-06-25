ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NativeVBug
NativeVBug_FILES = NativeVBugListener.m Tweak.x
NativeVBug_CFLAGS = -fobjc-arc
NativeVBug_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk
