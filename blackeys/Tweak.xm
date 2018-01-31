%hook UIKBRenderConfig
- (void)setLightKeyboard:(BOOL)light {
	%orig(NO);
} 
%end

%hook UIDevice
- (long long)_keyboardGraphicsQuality {
	return 10;
} 
%end
