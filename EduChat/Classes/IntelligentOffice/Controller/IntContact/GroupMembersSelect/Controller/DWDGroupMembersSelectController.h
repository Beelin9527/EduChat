//
//  DWDGroupMembersSelectController.h
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDSchoolGroupModel;
@interface DWDGroupMembersSelectController : UIViewController

// 从外部直接传入
@property (nonatomic, strong) NSArray<DWDSchoolGroupModel *> *dataArray;

@end
