//
//  DWDAddressEditViewController.h
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//  编辑地址 viewController

#import <UIKit/UIKit.h>
#import "DWDLocationEntity.h"
@interface DWDAddressEditViewController : UITableViewController
@property (strong, nonatomic) DWDLocationEntity *entity;
@end
