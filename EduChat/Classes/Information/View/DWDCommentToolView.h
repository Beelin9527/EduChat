//
//  DWDCommentToolView.h
//  EduChat
//
//  Created by Gatlin on 16/8/15.
//  Copyright © 2016年 dwd. All rights reserved.
//  评论工具条

#import <UIKit/UIKit.h>
#import <YYTextView.h>
@class DWDInfomationCommentModel;
@interface DWDCommentToolView : UIView
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) YYTextView *textView;
@property (nonatomic, strong) NSString *content; //textView 编辑内容

@property (nonatomic, assign, getter=isPraiseSta) BOOL praiseSta;
@property (nonatomic, copy) void(^praiseActionBlock)(UIButton *praiseBtn);
@property (nonatomic, copy) void(^beginEnditingActionBlock)();
@property (nonatomic, copy) void(^sendTextActionBlock)(NSString *content, DWDInfomationCommentModel *commentModel);

@property (nonatomic, strong) DWDInfomationCommentModel *commentModel;
@end
