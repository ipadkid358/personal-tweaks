ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoClose
NoClose_FILES = Tweak.xm
NoClose_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
