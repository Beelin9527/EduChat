//
//  DWDTeacherLeaveSchoolViewController.h
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDTeacherLeaveSchoolViewController : UIViewController

@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) NSNumber *index;

@property (nonatomic, strong) NSArray *totalStudentsArray;

//record if request
@property (nonatomic, assign) BOOL isFirstRequest;

- (void)reloadNotificationReceived;

@end
