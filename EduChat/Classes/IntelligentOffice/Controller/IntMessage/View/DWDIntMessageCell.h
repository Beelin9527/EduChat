//
//  DWDIntMessageCell.h
//  EduChat
//
//  Created by Beelin on 17/1/9.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 基类Cell
@class DWDIntMessageModel, DWDIntMessageCell;
@protocol DWDIntMessageCellDelegate <NSObject>

@optional
- (void)intMessageCell:(DWDIntMessageCell *)cell didClickItemWithIntMessageModel:(DWDIntMessageModel *)model;

@end


@interface DWDIntMessageCell : UITableViewCell

/** avatar imageView*/
@property (nonatomic, strong) UIImageView *avatar;

/** background imageView */
@property (nonatomic, strong) UIImageView *backgroundImv;

/** 类型 */
@property (nonatomic, strong) UILabel *typeLab;

/** 标题 */
@property (nonatomic, strong) UILabel *titleLab;

/** 华丽分隔线 */
@property (nonatomic, strong) UIView *line;

/** 时间label */
@property (nonatomic, strong) UILabel *dateLab;

/** 是否显示时间 */
@property (nonatomic, assign, getter=isHiddenDate) BOOL hiddenDate;


@property (nonatomic, strong) DWDIntMessageModel *intMessageModel;

@property (nonatomic,weak) id<DWDIntMessageCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end


