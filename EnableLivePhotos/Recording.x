%hook AVCaptureDeviceFormat

- (bool)isIrisSupported {
	return 1;
} 

%end

%hook CAMCaptureCapabilities

- (bool)isBackIrisSupported {
	return 1;
} 

- (bool)isFrontIrisSupported {
	return 1;
} 

%end

%hook CAMUserPreferences

- (bool)isIrisCaptureEnabled {
	return 1;
} 

%end
