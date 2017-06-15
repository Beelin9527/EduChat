//
//  DWDGrowUpCell.h
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DWDGrowUpModel.h"

#import <YYText.h>


/*
 1.固定部分:头像 名称 时间
 */

@class DWDGrowUpCell;
@class DWDGrowUpCellLayout;
@class DWDMenuButton;

@interface DWDUserStatusView : UIView

@property (nonatomic, strong) UIImageView *headImageView; //头像
@property (nonatomic, strong) YYLabel *nameLabel; //名字
@property (nonatomic, strong) UILabel *dateTimeLabel; //时间
@property (nonatomic, weak) DWDGrowUpCell *cell;
@end

/*
 2.内容部分:文本,展开按钮,图片
 */
@interface DWDGrowUpContentView : UIView

@property (nonatomic, strong) UIImageView *contentStartImageView; //文本起始图片
@property (nonatomic, strong) YYLabel *contentTextLabel;    //文本内容
@property (nonatomic, strong) UIButton *contentExpandButton;  //文本展开按钮
@property (nonatomic, strong) UIView *picContainerView;   //图片容器
@property (nonatomic, weak) DWDGrowUpCell *cell;
@end

/*
 3.评论按钮,赞,评论
 */
@interface DWDGrowUpCommentView : UIView
@property (nonatomic, strong) UIImageView *flowerImageView; //红花图片
@property (nonatomic, strong) YYLabel *praiseLabel;   //点赞label
@property (nonatomic, strong) UIView *lineView;   //评论顶头线
@property (nonatomic, strong) UIView *commentsContainerView;  //评论容器view
@property (nonatomic, strong) UIButton *commentExpandButton;  //评论展开按钮
@property (nonatomic, weak) DWDGrowUpCell *cell;
@end



/*
 成长记录cell
 */
@protocol DWDGrowUpCellDelegate;

@interface DWDGrowUpCell : UITableViewCell
- (void)setLayout:(DWDGrowUpCellLayout *)layout;

@property (nonatomic, strong) DWDUserStatusView *statusView; //固定部分
@property (nonatomic, strong) DWDGrowUpContentView *growUpContentView; //内容部分
@property (nonatomic, strong) DWDMenuButton *menuButton;   //选项按钮
@property (nonatomic, strong) DWDGrowUpCommentView *commentView; //评论点赞部分

@property (nonatomic, weak) id<DWDGrowUpCellDelegate> delegate;
@end

@protocol DWDGrowUpCellDelegate <NSObject>
@optional

/**
 *  点击了赞按钮
 */
- (void)growCellDidClickPraise:(DWDGrowUpCell *)cell;

/**
 *  点击了评论按钮
 */
- (void)growCellDidClickComment:(DWDGrowUpCell *)cell;

/**
 *  点击了label进行回复
 */
- (void)growCell:(DWDGrowUpCell *)cell didClickLabel:(YYLabel *)label replyWithCustId:(NSNumber *)custId nickname:(NSString *)nickname;

/**
 *  点击了姓名查看详细信息
 */
- (void)growCell:(DWDGrowUpCell *)cell didClickUserToViewDetail:(NSNumber *)custId;

/**
 *  点击了图片
 */
- (void)growCell:(DWDGrowUpCell *)cell didClickImageView:(UIImageView *)imgView withIndex:(NSInteger)index;

/**
 *  点击了评论展开
 */
- (void)growCellDidClickContentExpandButton:(DWDGrowUpCell *)cell;

/**
 *  点击了评论展开
 */
- (void)growCellDidClickCommentExpandButton:(DWDGrowUpCell *)cell;


@end
