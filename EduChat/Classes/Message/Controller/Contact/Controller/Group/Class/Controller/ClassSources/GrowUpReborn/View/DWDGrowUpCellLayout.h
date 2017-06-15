//
//  DWDGrowUpCellLayout.h
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <YYText.h>

/*
 间距
 */
#define kCellPadding pxToW(20)  //间距
#define kCellStartContentImageTopPadding pxToW(15) //开始图片上间距
#define kCellStartContentImageLeftPadding pxToW(6) //开始图片左间距
#define kCellContentLabelLeftPadding pxToW(8) //内容文本距离左图片间距
#define kCellMenuButtonTopPadding pxToW(14)    //面板按钮上间距
#define kCellCommentLabelMargin pxToW(10)   //行距
#define kCellCommentLabelLeftPadding pxToW(31)  //

#define kCellFlowerTopPadding pxToW(24)
#define kCellPraiseTopPadding pxToW(25)

/*
 长宽
 */
#define kCellHeadImageWidth pxToW(80)
#define kCellStartContentImageWidth 22
#define kCellFlowerHeight 12
#define kCellFlowerWidth 13
#define kCellSinglePicWidth pxToW(300)
#define kCellDoublePicsWidth pxToW(260)
#define kCellThreePicsWidth pxToW(230)
/*
 字体
 */
#define kCellNameFont 14    //名字字体大小
#define kCellContentFont 16 //内容字体大小
#define kCellDateTimeFont 12    //时间字体大小
/*
 颜色
 */
#define kCellNameColor DWDRGBColor(51, 51, 51)  //姓名颜色
#define kCellDateTimeColor DWDRGBColor(153, 153, 153) //时间颜色
#define kCellButtonColor DWDRGBColor(90, 136, 231)  //按钮颜色
#define kCellCommentBackgroundColor DWDRGBColor(241, 241, 241)  //背景颜色
#define kCellCommentSelectedColor DWDRGBColor(231, 231, 231)    //点击颜色


@class DWDGrowUpModel;
@interface DWDGrowUpCellLayout : NSObject

- (instancetype)initWithModel:(DWDGrowUpModel *)model;
- (void)layout;

/************* 以下高度均包括上方留白 不包括下方留白 *************/
/*
 固定部分
 */
@property (nonatomic, assign) CGFloat headImageHeight; //图片高度
/*
 内容部分
 */
@property (nonatomic, assign) CGFloat contentTextHeight; //文本内容高度 带 按钮
@property (nonatomic, strong) YYTextLayout *contentTextLayout; //文本内容布局
@property (nonatomic, assign, getter=isHaveExpandContentButton) BOOL haveExpandContentButton; //是否有按钮
@property (nonatomic, assign, getter=isExpandingContent) BOOL expandingContent; //是否展开状态
@property (nonatomic, assign) CGFloat contentButtonHeight; //内容按钮高度
@property (nonatomic, assign) CGFloat contentButtonWidth; //内容按钮高度
@property (nonatomic, assign) CGFloat picsViewHeight; //图片高度

/*
 赞部分
 */
@property (nonatomic, assign) CGFloat menuButtonHeight; //menu按钮高度
@property (nonatomic, assign) CGFloat praisesHeight; //点赞文本高度
@property (nonatomic, strong) YYTextLayout *praisesTextLayout; //点赞文本布局

/*
 评论部分
 */
@property (nonatomic, assign) CGFloat commentsHeight; //评论高度
//@property (nonatomic, strong) YYTextLayout *commentsTextLayout;
@property (nonatomic, strong) NSArray *commentsTextLayoutArray; //评论布局
@property (nonatomic, assign, getter=isHaveExpandCommentsButton) BOOL haveExpandCommentsButton; //是否有评论展开按钮
@property (nonatomic, assign, getter=isExpandingComments) BOOL expandingComments; //是否展开状态
@property (nonatomic, assign) CGFloat commentButtonHeight; //评论按钮高度
@property (nonatomic, assign) CGFloat commentButtonWidth; //评论按钮高度

/*
 总高度
 */
@property (nonatomic, assign) CGFloat bottomPadding;
@property (nonatomic, assign) CGFloat totalHeight;

/***********    存储数据    ***********/
@property (nonatomic, strong) DWDGrowUpModel *model;

@end
