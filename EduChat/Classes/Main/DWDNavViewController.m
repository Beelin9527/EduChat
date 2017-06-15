//
//  DWDNavViewController.m
//  DWDSj
//
//  Created by apple  on 15/10/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNavViewController.h"
#import "DWDClassChatBottomView.h"
#import "DWDClassMenu.h"
#import "DWDClassSourceCheckScoreViewController.h"
#import "DWDClassSourceClassActivityViewController.h"
#import "DWDClassSourceClassMoneyViewController.h"
#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassSourceClassVoteViewController.h"
#import "DWDClassSourceGrowupRecordViewController.h"
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDClassSourceSourceBoxViewController.h"
#import "DWDMessageViewController.h"

@interface DWDNavViewController ()

@end

@implementation DWDNavViewController 
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNeedsStatusBarAppearanceUpdate];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ([viewController isKindOfClass:[DWDClassSourceCheckScoreViewController class]] || [viewController isKindOfClass:[DWDClassSourceClassActivityViewController class]] || [viewController isKindOfClass:[DWDClassSourceClassMoneyViewController class]] || [viewController isKindOfClass:[DWDClassSourceClassNotificationViewController class]] || [viewController isKindOfClass:[DWDClassSourceClassVoteViewController class]] || [viewController isKindOfClass:[DWDClassSourceGrowupRecordViewController class]] || [viewController isKindOfClass:[DWDClassSourceHomeWorkViewController class]] || [viewController isKindOfClass:[DWDClassSourceLeavePaperViewController class]] || [viewController isKindOfClass:[DWDClassSourceSourceBoxViewController class]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDClassInfoBottomViewAndMenuShouldHide object:nil];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStyleDone target:self action:nil];
    
    viewController.navigationItem.backBarButtonItem = item;
    
    [super pushViewController:viewController animated:animated];
    
}
//
//- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
//    
//    UIViewController *rootVc = self.viewControllers[0];
//    if ([rootVc isKindOfClass:[DWDMessageViewController class]]) { // 回到msgVc的操作
//        DWDMessageViewController *message = (DWDMessageViewController*)rootVc;
//        message.isNeedGlobleLoadData = YES;
//    }
//    return [super popViewControllerAnimated:animated];
//}
//
//- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
//    UIViewController *rootVc = self.viewControllers[0];
//    if ([rootVc isKindOfClass:[DWDMessageViewController class]]) { // 回到msgVc的操作
//        DWDMessageViewController *message = (DWDMessageViewController*)rootVc;
//        message.isNeedGlobleLoadData = YES;
//    }
//    return [super popToRootViewControllerAnimated:animated];
//    
//}

@end
