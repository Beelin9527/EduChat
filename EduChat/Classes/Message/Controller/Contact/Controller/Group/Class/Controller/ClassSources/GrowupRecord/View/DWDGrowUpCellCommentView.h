//
//  DWDGrowUpCellCommentView.h
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDGrowUpCellCommentView;

@protocol DWDGrowUpCellCommentViewDelegate<NSObject>

@optional
- (void)commentView:(DWDGrowUpCellCommentView *)commentView didClickCustId:(NSNumber *)custId;

- (void)commentView:(DWDGrowUpCellCommentView *)commentView didClickLabelWithCustId:(NSNumber *)custId;

@end

@interface DWDGrowUpCellCommentView : UIView

@property (nonatomic, strong) NSArray *commentsArray;

@property (nonatomic, assign) CGFloat commentHeight;

@property (nonatomic, weak) id<DWDGrowUpCellCommentViewDelegate> delegate;

@end
