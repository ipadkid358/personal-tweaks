ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StatusVolX StatusVolXKit

StatusVolX_FILES = StatusVolX.x SVStatusVolX.m
StatusVolX_CFLAGS = -fobjc-arc

StatusVolXKit_FILES = StatusVolXKit.x
StatusVolXKit_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
