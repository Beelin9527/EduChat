//
//  DWDAddressListCell.h
//  EduChat
//
//  Created by Gatlin on 15/12/23.
//  Copyright © 2015年 dwd. All rights reserved.
//  我的地址列表 cell

#import <UIKit/UIKit.h>
@class DWDLocationEntity;
@interface DWDAddressListCell : UITableViewCell
@property (strong, nonatomic) DWDLocationEntity *entity;
@end
