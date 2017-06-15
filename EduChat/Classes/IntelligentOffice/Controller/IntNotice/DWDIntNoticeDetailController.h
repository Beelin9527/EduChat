//
//  DWDIntNoticeDetailController.h
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "BaseViewController.h"

@class DWDIntNoticeListModel;
@interface DWDIntNoticeDetailController : BaseViewController
@property (nonatomic, strong) NSNumber *schoolId;
@property (nonatomic, strong) DWDIntNoticeListModel *model;
@end
