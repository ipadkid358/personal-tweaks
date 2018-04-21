ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FullStatusTime
FullStatusTime_FILES = Tweak.x
FullStatusTime_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
