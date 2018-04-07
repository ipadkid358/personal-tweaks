%hook PUOneUpSettings

- (void)setDefaultMaximumZoomFactor:(double)factor {
    %orig(INFINITY);
}

%end
