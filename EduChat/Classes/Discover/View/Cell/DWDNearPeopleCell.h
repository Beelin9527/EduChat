//
//  DWDNearPeopleCell.h
//  EduChat
//
//  Created by Superman on 15/11/12.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDNearPeopleModel;
@interface DWDNearPeopleCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic , strong) DWDNearPeopleModel *nearPeople;


@end
