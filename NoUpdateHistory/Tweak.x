%hook ASUpdatesPage

- (void)_renderSectionsWithClientContext:(id)context timezoneOffset:(double)offset availableUpdates:(id)available installedByDate:(id)updated {
    updated = NULL;
    %orig;
}

%end
