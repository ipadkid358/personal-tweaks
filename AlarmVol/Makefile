ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AlarmVol
AlarmVol_FILES = Tweak.x
AlarmVol_CFLAGS = -fobjc-arc
AlarmVol_PRIVATE_FRAMEWORKS = Celestial

include $(THEOS_MAKE_PATH)/tweak.mk
