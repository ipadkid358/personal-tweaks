ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Gestic
Gestic_FILES = Tweak.x
Gestic_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
