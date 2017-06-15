//
//  DWDMenuController.h
//  EduChat
//
//  Created by Superman on 16/1/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDGrowUpRecordModel.h"
@class DWDGrowUpRecordModel,DWDClassGrowUpCell;
@interface DWDMenuController : UIMenuController
@property (nonatomic , strong) DWDGrowUpRecordModel *growupModel;
@property (nonatomic , strong) DWDClassGrowUpCell *cell;

@end
