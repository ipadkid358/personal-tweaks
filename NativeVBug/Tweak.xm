%hook UIWindow

- (BOOL)_shouldCreateContextAsSecure {
    return [self isKindOfClass:%c(UIDebuggingInformationOverlay)] ? YES : %orig;
}

%end
