//
//  DWDClassNotificationDetailController.h
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDClassModel;
@interface DWDClassNotificationDetailController : UITableViewController

@property (nonatomic, strong) NSNumber *readed;
@property (nonatomic, strong) NSNumber *noticeId;
@property (nonatomic, strong) DWDClassModel *myClass;

@end
