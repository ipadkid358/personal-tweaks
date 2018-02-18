ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StatusVolX StatusVolXKit

StatusVolX_FILES = StatusVolX.xm
StatusVolX_CFLAGS = -fobjc-arc

StatusVolXKit_FILES = StatusVolXKit.xm
StatusVolXKit_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
