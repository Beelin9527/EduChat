//
//  DWDClassMembersViewController.h
//  EduChat
//
//  Created by Gatlin on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//  班级成员 ViewController

#import "BaseViewController.h"
@class DWDClassMembersViewController,DWDClassModel;

@protocol DWDClassMembersViewControllerDelegate <NSObject>

- (void)classMembersViewControllerNeedReload:(DWDClassMembersViewController *)classMembersViewController;

@end
@interface DWDClassMembersViewController : BaseViewController
@property (strong, nonatomic) DWDClassModel *classModel;
@property (nonatomic,weak) id <DWDClassMembersViewControllerDelegate> delegate;
@end
