//
//  DWDAddNewClassCityViewController.h
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
// 区分个人信息更改地区与添加新班级的地区
typedef NS_OPTIONS(NSUInteger, DWDSelfClassPropertyType) {
    DWDSelfClassPropertyTypeNone,DWDSelfClassPropertyTypeSelectCityForChangeMeArea//个人信息更改地区的
};
@class DWDAddNewClassViewController;
@interface DWDAddNewClassCityViewController : UITableViewController

@property (nonatomic , strong) NSMutableArray *cityArray;
@property (nonatomic , copy) NSString *provinceName;
@property (nonatomic , strong) DWDAddNewClassViewController *addNewVc;

@property (assign, nonatomic) DWDSelfClassPropertyType type;
@end
