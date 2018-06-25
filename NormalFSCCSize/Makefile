ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NormalFSCCSize
NormalFSCCSize_FILES = Tweak.xm
NormalFSCCSize_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
