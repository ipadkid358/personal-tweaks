//
//  SBSnapperWindow.h
//  SnapperRemake
//
//  Created by ipad_kid on 3/30/18.
//  Copyright © 2018 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

@interface SBSnapperWindow : UIWindow <LAListener>

- (void)show;
- (void)dismiss;

@end
