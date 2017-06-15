//
//  DWDCurrentDistrictViewController.h
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDAddNewClassCityViewController.h"
@class DWDAddNewClassViewController;
@interface DWDCurrentDistrictViewController : UITableViewController
@property (nonatomic , strong) DWDAddNewClassViewController *addNewVc;
@property (nonatomic , copy) NSString *currentLocationName;

@property (assign, nonatomic) DWDSelfClassPropertyType type;
@end
