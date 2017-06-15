//
//  DWDClassNotificationDetailCell.h
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDClassNotificationDetailLayout;

@class DWDClassNotificationDetailCell;
@class DWDClassNotificationReplyCell;
@class DWDClassNotificationSegmentControl;


@protocol DWDClassNotificationSegmentControlDelegate <NSObject>
@optional
- (void)segmentControlDidClickCompleteButton;
- (void)segmentControlDidClickUnCompleteButton;
@end
@interface DWDClassNotificationSegmentControl : UIView
@property (nonatomic, weak) id<DWDClassNotificationSegmentControlDelegate> delegate;

- (void)setButtonTitleWithComplete:(NSString *)completeTitle
                        unComplete:(NSString *)unCompleteTitle;
@end




@protocol DWDClassNotificationReplyCellDelegate <NSObject>
@optional
- (void)replyCellDidClickCompleteButton:(DWDClassNotificationReplyCell *)cell;
- (void)replyCellDidClickUnCompleteButton:(DWDClassNotificationReplyCell *)cell;
- (void)replyCell:(DWDClassNotificationReplyCell *)cell didClickMember:(NSNumber *)custId;
@end

@interface DWDClassNotificationReplyCell : UITableViewCell
@property (nonatomic, weak) DWDClassNotificationSegmentControl *segmentControl;
@property (nonatomic, weak) id<DWDClassNotificationReplyCellDelegate> delegate;

- (void)setLayout:(DWDClassNotificationDetailLayout *)layout;
@end





@protocol DWDClassNotificationDetailCellDelegate <NSObject>
@optional
- (void)detailCell:(DWDClassNotificationDetailCell *)cell didCLickImgView:(UIImageView *)imgView atIndex:(NSInteger)index;

/**
 *  点击按钮成功
 *
 *  @param type 0:我知道了
                1:YES
                2:NO
 */
- (void)detailCell:(DWDClassNotificationDetailCell *)cell didClickButtonWithType:(NSInteger)type;
@end

@interface DWDClassNotificationDetailCell : UITableViewCell
@property (nonatomic, strong) NSNumber *readed;
@property (nonatomic, weak) id<DWDClassNotificationDetailCellDelegate> delegate;
- (void)setLayout:(DWDClassNotificationDetailLayout *)layout;
@end

