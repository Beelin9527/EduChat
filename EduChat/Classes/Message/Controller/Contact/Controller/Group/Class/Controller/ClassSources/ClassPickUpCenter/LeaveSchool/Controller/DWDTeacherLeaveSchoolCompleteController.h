//
//  DWDTeacherLeaveSchoolCompleteController.h
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDTeacherLeaveSchoolCompleteController : UITableViewController

@property (nonatomic, strong) NSArray *dataArray;


@property (nonatomic, assign) BOOL requestFailed;
//record if request
@property (nonatomic, assign) BOOL isFirstRequest;

@end
