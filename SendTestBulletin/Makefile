ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SendTestBulletin
SendTestBulletin_FILES = Tweak.x
SendTestBulletin_CFLAGS = -fobjc-arc
SendTestBulletin_PRIVATE_FRAMEWORKS = BulletinBoard

TOOL_NAME = stb
stb_FILES = main.m
stb_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/tool.mk
