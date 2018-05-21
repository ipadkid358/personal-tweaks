ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkFolders
DarkFolders_FILES = Tweak.x
DarkFolders_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
