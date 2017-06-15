//
//  DWDIntNoticeDetailCell.h
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntNoticeDetailModel, DWDIntNoticeDetailCell;
@protocol DWDIntNoticeDetailCellDelegate <NSObject>

@optional
- (void)intNoticeDetailCell:(DWDIntNoticeDetailCell *)cell clickButton:(UIButton *)sender photos:(NSArray *)photos;

@required
- (void)intNoticeDetailCell:(DWDIntNoticeDetailCell *)cell didClickOKButtonWithItem:(NSNumber *)item;
- (void)intNoticeDetailCell:(DWDIntNoticeDetailCell *)cell didClickYesOrNoButtonWithItem:(NSNumber *)item;
@end

@interface DWDIntNoticeDetailCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) DWDIntNoticeDetailModel *model;
@property (nonatomic,weak) id<DWDIntNoticeDetailCellDelegate> delegate;
@end
