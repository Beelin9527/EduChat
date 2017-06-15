//
//  DWDGrowCommentListCell.h
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDGrowUpRecordCommentList.h"

@interface DWDGrowCommentListCell : UITableViewCell
@property (nonatomic , strong) DWDGrowUpRecordCommentList *commentList;

+ (instancetype)cellWithTableView:(UITableView *)tableview;
@end
