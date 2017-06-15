//
//  DWDClassNotificationAddViewController.h
//  EduChat
//
//  Created by Gatlin on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//  通知新增viewController

#import <UIKit/UIKit.h>
#import "DWDClassModel.h"

@interface DWDClassNotificationAddViewController : UITableViewController

@property (strong, nonatomic) NSNumber *originalId;
@property (nonatomic, strong) DWDClassModel *myClass;
@end
