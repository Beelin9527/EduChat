//
//  DWDDetailToolCell.h
//  EduChat
//
//  Created by Gatlin on 16/8/15.
//  Copyright © 2016年 dwd. All rights reserved.
//  阅读、收藏条Cell

#import <UIKit/UIKit.h>
@class DWDVisitStat;
@interface DWDDetailToolCell : UITableViewCell
+ (instancetype)initDetailToolCellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DWDVisitStat *visitStat;
@end
