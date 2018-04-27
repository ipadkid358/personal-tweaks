ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkNotifs
DarkNotifs_FILES = Tweak.x
DarkNotifs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
