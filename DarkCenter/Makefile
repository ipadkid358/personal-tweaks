ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkCenter
DarkCenter_FILES = Tweak.x
DarkCenter_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
