//
//  DWDClassNotificationDetailViewController.h
//  EduChat
//
//  Created by doublewood on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//  通知详情ViewController

#import <UIKit/UIKit.h>

@interface DWDClassNotificationDetailViewController : UITableViewController

@property (strong, nonatomic) NSNumber *noticeId;
@property (copy, nonatomic) NSString *noticeTitle;
@end
