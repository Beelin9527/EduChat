//
//  DWDInformationCommentCell.h
//  EduChat
//
//  Created by KKK on 16/5/26.
//  Copyright © 2016年 dwd. All rights reserved.
//  评论Cell

#import <UIKit/UIKit.h>

@class DWDInfomationCommentModel;
@class DWDInformationCommentCell;

@protocol DWDInformationCommentCellDelegate <NSObject>

@optional
- (void)commentCellLongPressToDeleteComment:(DWDInformationCommentCell *)cell;

@end

@interface DWDInformationCommentCell : UITableViewCell

@property (nonatomic, weak) id<DWDInformationCommentCellDelegate> delegate;

- (void)layout:(DWDInfomationCommentModel *)model;
@end

