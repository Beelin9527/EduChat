//
//  DWDClassSourceLeavePaperViewController.h
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//  假条列表ViewController

#import <UIKit/UIKit.h>

@class DWDClassModel;
@interface DWDClassSourceLeavePaperViewController : UITableViewController
@property (strong, nonatomic) NSNumber *classId;  //班级Id
@property (nonatomic, strong) DWDClassModel *classModel;
@end
