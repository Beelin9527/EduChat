//
//  DWDGroupMemberSelectCell.h
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDSchoolGroupMemberModel, DWDGroupMemberSelectCell;

@protocol DWDGroupMemberSelectCellDelegate <NSObject>

@optional

/**
 cell点击了选择按钮
 */
- (void)groupMemberSelectCellDidClickCheckButton:(DWDGroupMemberSelectCell *)cell;

@end

@interface DWDGroupMemberSelectCell : UITableViewCell

@property (nonatomic, weak) id<DWDGroupMemberSelectCellDelegate> eventDelegate;

//在 cell for row 中设置数据
- (void)setCellData:(DWDSchoolGroupMemberModel *)model;


@end
