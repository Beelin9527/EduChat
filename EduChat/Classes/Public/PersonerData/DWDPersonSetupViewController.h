//
//  DWDPersonSetupViewController.h
//  EduChat
//
//  Created by Gatlin on 16/2/20.
//  Copyright © 2016年 dwd. All rights reserved.
//  好友设置权限 ViewController

#import "BaseViewController.h"
#import "DWDCustomUserInfoEntity.h"
@interface DWDPersonSetupViewController : UITableViewController
@property (strong, nonatomic) DWDCustomUserInfoEntity *entity;      //设置权限实体类
@property (strong, nonatomic) NSNumber *friendCustId;               //好友Id

@end
