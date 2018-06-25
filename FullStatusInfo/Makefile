ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FullStatusInfo
FullStatusInfo_FILES = Tweak.x
FullStatusInfo_FRAMEWORKS = IOKit
FullStatusInfo_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
