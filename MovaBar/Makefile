ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MovaBar
MovaBar_FILES = Tweak.xm
MovaBar_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
