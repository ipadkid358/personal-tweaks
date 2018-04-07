ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CleanNotifications
CleanNotifications_FILES = Tweak.x
CleanNotifications_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
