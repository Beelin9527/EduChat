//
//  DWDIntContactGroupMemberCell.h
//  EduChat
//
//  Created by KKK on 16/12/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntContactGroupMemberCell, DWDSchoolGroupMemberModel;
@protocol DWDIntContactGroupMemberCellDelegate <NSObject>

@optional
// 点击了临时单独聊天的回调
- (void)memberCellDidClickMessageButton:(DWDIntContactGroupMemberCell *)cell;

// 点击了打电话的回调
- (void)memberCellDidClickPhoneCallButton:(DWDIntContactGroupMemberCell *)cell;

@end

@interface DWDIntContactGroupMemberCell : UITableViewCell

// 事件代理
@property (nonatomic, weak) id<DWDIntContactGroupMemberCellDelegate> eventDelegate;

// 布局cell
- (void)layoutWithModel:(DWDSchoolGroupMemberModel *)model;

@end
