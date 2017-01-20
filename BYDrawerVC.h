//
//  BYDrawerVC.h
//
//
//  Created by Baleen.Y on 5/11/16.
//  Copyright © 2016 Baleen.Y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYDrawerVC : UIViewController

/**
 底部 View
 */
@property (nonatomic, weak, readonly) UIView *baseView;
/**
 主 View
 */
@property (nonatomic, weak, readonly) UIView *mainView;

/**
 关闭抽屉
 */
- (void)closeDrawer;
/**
 开打抽屉
 */
- (void)openDrawer;

@end
