//
//  DWDGrowingTextView.h
//  EduChat
//
//  Created by apple on 11/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDInteractiveChatCell;

@protocol DWDGrowingTextViewDelegate <NSObject>
@required
- (void)interactiveChatCellDidCopyWithCell:(DWDInteractiveChatCell *)cell; // 复制
- (void)interactiveChatCellDidRelayWithCell:(DWDInteractiveChatCell *)cell; // 转发
- (void)interactiveChatCellDidCollectWithCell:(DWDInteractiveChatCell *)cell; // 收藏
- (void)interactiveChatCellDidDeleteWithCell:(DWDInteractiveChatCell *)cell; // 删除
- (void)interactiveChatCellDidRevokeWithCell:(DWDInteractiveChatCell *)cell; // 撤销
- (void)interactiveChatCellDidClickMoreWithCell:(DWDInteractiveChatCell *)cell; // 更多
@end

@interface DWDGrowingTextView : UITextView

@property (nonatomic , weak) id<DWDGrowingTextViewDelegate> growingTextViewDelegate;

- (void)setLineNumberToStopGrowing:(NSInteger)number;

- (CGFloat)getHeightConstraint;

- (CGFloat)getMaxHeight;

- (void)showMenuWithTitles:(NSArray *)titles rect:(CGRect)rect tableView:(UITableView *)tableView cell:(DWDInteractiveChatCell *)cell;

@end
