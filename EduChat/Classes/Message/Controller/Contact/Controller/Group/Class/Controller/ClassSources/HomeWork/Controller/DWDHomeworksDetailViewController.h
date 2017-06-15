//
//  DWDHomeworksDetailViewController.h
//  EduChat
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDClassModel;

@interface DWDHomeworksDetailViewController : UIViewController

@property (strong, nonatomic) NSNumber *homeWorkId;
@property (strong, nonatomic) NSNumber *classId;
@property (strong, nonatomic) NSNumber *subject;
@property (strong, nonatomic) DWDClassModel *classModel;
@property (copy,   nonatomic) void(^popBlock)(void);

@end
