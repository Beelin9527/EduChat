//
//  DWDClassIntroduceViewController.h
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//  班级介绍

#import <UIKit/UIKit.h>
@class DWDClassModel,DWDClassIntroduceViewController;
@protocol DWDClassIntroduceViewControllerDelegate <NSObject>
@optional
- (void)classIntroduceViewController:(DWDClassIntroduceViewController *)classIntroduceViewController introduce:(NSString *)introduce;

@end

@interface DWDClassIntroduceViewController : UIViewController
@property (strong, nonatomic) DWDClassModel *classModel;
@property (nonatomic,weak) id<DWDClassIntroduceViewControllerDelegate> delegate;
@end
