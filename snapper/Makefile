ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Snapper
Snapper_FILES = SBSnapperWindow.m
Snapper_CFLAGS = -fobjc-arc
Snapper_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
