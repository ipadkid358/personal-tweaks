ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkMessages
DarkMessages_FILES = Tweak.x
DarkMessages_PRIVATE_FRAMEWORKS = ChatKit
DarkMessages_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
