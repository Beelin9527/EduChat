//
//  DWDGrowUpRecordCell.h
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDGrowUpRecordModel;
@class DWDGrowUpRecordCell;
@class DWDGrowUpCellCommentView;

@protocol DWDGrowUpRecordCellDelegate <NSObject>

@optional

/**
 *  点击评论列表的名称按钮
 *
 *  @param cell
 *  @param custId 用户名称的custid
 */
- (void)recordCell:(DWDGrowUpRecordCell *)cell didClickCommentViewWithCustId:(NSNumber *)custId;

/**
 *  点击评论列表的label,回复对话
 *
 *  @param cell
 *  @param custId 回复用户的custid
 */
- (void)recordCell:(DWDGrowUpRecordCell *)cell didClickCommentViewContentLabelWithCustId:(NSNumber *)custId;

- (void)recordCell:(DWDGrowUpRecordCell *)cell didClickContentLabelWithContent:(NSString *)contentString;

@end

@interface DWDGrowUpRecordCell : UITableViewCell

@property(nonatomic, strong) DWDGrowUpRecordModel *dataModel;

@property(nonatomic, weak) id<DWDGrowUpRecordCellDelegate> delegate;

@end
