//
//  DWDTeacherGoSchoolViewController.h
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDTeacherGoSchoolViewController : UITableViewController

@property (nonatomic, strong) NSNumber *classId;

@property (nonatomic, strong) NSArray *totalStudentsArray;

@property (nonatomic, strong) NSNumber *index;

//record if request
@property (nonatomic, assign) BOOL isFirstRequest;

@property (nonatomic, assign) BOOL requestFailed;

@end
