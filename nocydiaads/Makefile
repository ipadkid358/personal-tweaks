ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoCydiaAds
NoCydiaAds_FILES = Tweak.x
NoCydiaAds_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Cydia"
