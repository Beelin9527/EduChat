//
//  DWDClassInnerGroupDetailViewController.h
//  EduChat
//
//  Created by apple on 12/31/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DWDNeedUpdateClassInnerGroup @"need_update_class_inner_group"

@interface DWDClassInnerGroupDetailViewController : UITableViewController

@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) NSNumber *groupId;
@property (strong, nonatomic) NSMutableArray *contacts;
@property (copy, nonatomic) NSString *groupName;

@property (nonatomic) BOOL isForCreate;

@end
