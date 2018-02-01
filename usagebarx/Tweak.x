%hook UIStatusBarNewUIDoubleHeightStyleAttributes

- (double)heightForMetrics:(long long)metrics {
    return 20;
}

%end
