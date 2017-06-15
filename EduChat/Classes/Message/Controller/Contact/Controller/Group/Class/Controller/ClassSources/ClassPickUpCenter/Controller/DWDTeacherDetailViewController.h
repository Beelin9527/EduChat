//
//  DWDTeacherDetailViewController.h
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDClassModel;
@interface DWDTeacherDetailViewController : UIViewController

@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) DWDClassModel *classModel;
@end
