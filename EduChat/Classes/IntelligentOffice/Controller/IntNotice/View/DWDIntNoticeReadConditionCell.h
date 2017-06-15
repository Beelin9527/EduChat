//
//  DWDIntNoticeReadConditionCell.h
//  EduChat
//
//  Created by Beelin on 17/1/12.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntNoticeReadConditionCell,DWDIntNoticeDetailModel;
@protocol DWDIntNoticeReadConditionCellDelegate <NSObject>

@optional

- (void)intNoticeReadConditionCell:(DWDIntNoticeReadConditionCell *)cell didClickButtonWithTag:(NSInteger)tag;

/** 点击头像*/
- (void)intNoticeReadConditionCell:(DWDIntNoticeReadConditionCell *)cell didClickPhotoHeadWithCustId:(NSNumber *)custId;


@end


@interface DWDIntNoticeReadConditionCell : UITableViewCell
@property (nonatomic, strong) DWDIntNoticeDetailModel *model;
@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic,weak) id<DWDIntNoticeReadConditionCellDelegate> delegate;

@end
