//
//  DWDPickUpCenterChildTableViewController.h
//  EduChat
//
//  Created by Superman on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDClassModel;
@interface DWDPickUpCenterChildTableViewController : UITableViewController

@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) DWDClassModel *classModel;
@end
