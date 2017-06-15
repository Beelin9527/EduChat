//
//  DWDClassNotificationDetailViewController.h
//  EduChat
//
//  Created by Mantis on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//  通知详情ViewController

#import <UIKit/UIKit.h>
#import "DWDClassModel.h"

@class DWDClassNotificatoinListEntity;
@interface DWDClassNotificationDetailViewController : UITableViewController

@property (strong, nonatomic) NSNumber *noticeId;
@property (copy, nonatomic) NSString *noticeTitle;
@property (copy, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *readed;

@property (nonatomic, strong) DWDClassModel *myClass;
@end
