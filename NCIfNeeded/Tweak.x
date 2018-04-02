@interface NCNotificationChronologicalList : NSObject
- (unsigned long long)sectionCount;
@end

@interface NCNotificationSectionListViewController
- (NCNotificationChronologicalList *)sectionList;
@end

@interface SBPagedScrollView
- (BOOL)scrollToPageAtIndex:(unsigned long long)index animated:(BOOL)animated;
@end

@interface SBNotificationCenterWithSearchViewController
- (NCNotificationSectionListViewController *)notificationListViewController;
- (SBPagedScrollView *)notificationAndTodayContainerView;
@end


%hook SBNotificationCenterWithSearchViewController

- (void)willActivateHosting {
    %orig;
    
    // using bool forces into one byte
    BOOL index = self.notificationListViewController.sectionList.sectionCount;
    [self.notificationAndTodayContainerView scrollToPageAtIndex:index animated:0];
}

%end
