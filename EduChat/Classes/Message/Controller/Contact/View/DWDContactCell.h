//
//  DWDContactCell.h
//  EduChat
//
//  Created by apple on 12/8/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DWDContactCellStatus) {
    
    DWDContactCellStatusDefault = -1, //display normal
    
    DWDContactCellStatusMyVerifing = 0, //display "接受"
    DWDContactCellStatusMyVerified = 1, //display "已添加"
    
    DWDContactCellStatusInvite = 2, //display "要求"
    DWDContactCellStatusInviting = 3, // display "等待验证"
    DWDContactCellStatusReject = 4, //display "已拒绝"
    
    DWDContactCellStatusAdd = 5, //display "添加"
};

@class DWDContactCell;

@protocol DWDContactCellDelegate <NSObject>

@optional
- (void)contactCellDidMutlEditingSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)contactCellDidMutlEditingDisselectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)contactCellDidAccpetVerify:(DWDContactCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)contactCellDidAddFriend:(DWDContactCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)contactCellDidInviteFriend:(DWDContactCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@interface DWDContactCell : UITableViewCell

@property (weak, nonatomic) id<DWDContactCellDelegate> actionDelegate;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) BOOL isMultEditingSelected;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nicknameLable;
@property (strong, nonatomic) UILabel *subInfoLable;
@property (strong, nonatomic) UILabel *desLabel;
@property (strong, nonatomic) UILabel *identityLabel;
@property (nonatomic) DWDContactCellStatus status;

@end
