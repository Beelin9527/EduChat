//
//  DWDContactsInviteCell.h
//  EduChat
//
//  Created by KKK on 16/11/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDContactsInviteCell, DWDContactInviteModel;
@protocol DWDContactsInviteCellDelegate <NSObject>

@optional
- (void)inviteCell:(DWDContactsInviteCell *)cell didClickInviteButtonWithModel:(DWDContactInviteModel *)model;

@end

@interface DWDContactsInviteCell : UITableViewCell
@property (nonatomic, weak) id<DWDContactsInviteCellDelegate> delegate;

- (void)setDataWithModel:(DWDContactInviteModel *)model;
@end
