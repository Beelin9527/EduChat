//
//  DWDPickUpCenterChildCell.h
//  EduChat
//
//  Created by Superman on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDPickUpCenterDataBaseModel;
@interface DWDPickUpCenterChildCell : UITableViewCell
@property (nonatomic , strong) DWDPickUpCenterDataBaseModel *dataBaseModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView ID:(NSString *)ID;
@end
