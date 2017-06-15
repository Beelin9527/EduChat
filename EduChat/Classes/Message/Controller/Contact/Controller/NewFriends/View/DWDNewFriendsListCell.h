//
//  DWDNewFriendsListCell.h
//  EduChat
//
//  Created by Gatlin on 16/3/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDFriendApplyEntity,DWDNewFriendsListCell;
@protocol DWDNewFriendsListCellDelegate <NSObject>

@optional
- (void)newfriendsListCell:(DWDNewFriendsListCell *)newfriendsListCell didSelectAcceptButtonOfFriendEntity:(DWDFriendApplyEntity *)entity;

@end
@interface DWDNewFriendsListCell : UITableViewCell
@property (strong, nonatomic) DWDFriendApplyEntity *entity;
@property (nonatomic,weak) id <DWDNewFriendsListCellDelegate> delegate;
@end
