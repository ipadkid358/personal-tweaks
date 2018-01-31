ARCHS = arm64
TARGET = iphone:clang::10.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkMessages

DarkMessages_FILES = DarkMessages.xm
DarkMessages_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
