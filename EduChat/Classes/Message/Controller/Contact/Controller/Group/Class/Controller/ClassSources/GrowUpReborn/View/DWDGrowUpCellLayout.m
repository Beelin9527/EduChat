//
//  DWDGrowUpCellLayout.m
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowUpCellLayout.h"
#import "DWDGrowUpModel.h"
#import "TTTAttributedLabel.h"
#import "NSDictionary+dwd_extend.h"

@implementation DWDGrowUpCellLayout

- (instancetype)initWithModel:(DWDGrowUpModel *)model {
    if (!model)
        return nil;
    self = [super init];
    _model = model;
    [self layout];
    return self;
}

//@property (nonatomic, assign) CGFloat headImageHeight;
//@property (nonatomic, assign) CGFloat nameHeight;
//@property (nonatomic, assign) CGFloat dateTimeHeight;
//@property (nonatomic, assign) CGFloat contentTextHeight;
//@property (nonatomic, assign) CGFloat contentButtonHeight;
//@property (nonatomic, assign) CGFloat picsViewHeight;
//@property (nonatomic, assign) CGFloat menuButtonHeight;
//@property (nonatomic, assign) CGFloat praisesHeight;
//@property (nonatomic, assign) CGFloat commentsHeight;
//@property (nonatomic, assign) CGFloat commentButtonHeight;
//@property (nonatomic, assign) CGFloat bottomPadding;
//@property (nonatomic, assign) CGFloat totalHeight;
- (void)layout {
    [self _layout];
}

- (void)_layout {
    _headImageHeight = kCellHeadImageWidth;
    _contentTextHeight = 0;
    _contentButtonHeight = 0;
    _picsViewHeight = 0;
    _menuButtonHeight = 0;
    _praisesHeight = 0;
    _commentsHeight = 0;
    _commentButtonHeight = 0;
    _bottomPadding = 0;
    _totalHeight = 0;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"展开"
                                                                  attributes:@{
                                                                               NSFontAttributeName: [UIFont                         systemFontOfSize:kCellNameFont]
                                                                               }];
    [button setAttributedTitle:attrStr forState:UIControlStateNormal];
    [button sizeToFit];
    _commentButtonHeight = button.size.height;
    _contentButtonHeight = button.size.height;
    _commentButtonWidth = button.size.width;
    _contentButtonWidth = button.size.width;
    
    
    [self _layoutContentView];
    /*
     计算 menuButton
     */
    _menuButtonHeight = kCellStartContentImageWidth;

    [self _layoutPraise];
    [self _layoutComments];
    
    _totalHeight += _headImageHeight + kCellPadding;
    _totalHeight += _contentTextHeight + kCellPadding;

    if (_haveExpandContentButton) {
        _totalHeight += _commentButtonHeight + kCellPadding;
    }
    if (_model.photos.count) {
        _totalHeight += _picsViewHeight + kCellPadding;
    }
    _totalHeight += kCellStartContentImageWidth + kCellMenuButtonTopPadding;
    //间隙距离
    if (_model.praises.count || _model.comments.count) {
        _totalHeight += kCellMenuButtonTopPadding + kCellFlowerTopPadding;
    }
    if (_model.praises.count) {
        _totalHeight += _praisesHeight;
    }
    if (_model.comments.count) {
        _totalHeight += _commentsHeight + kCellCommentLabelMargin;
        if (_model.comments.count > 9) {
            _totalHeight += _contentButtonHeight + kCellPadding;
        }
    }
    _totalHeight += kCellPadding;
}
//@property (nonatomic, strong) DWDGrowUpModelRecord *record; //内容信息
//@property (nonatomic, strong) NSArray<DWDGrowUpModelPhoto *> *photos; //图片信息
//@property (nonatomic, strong) NSArray<DWDGrowUpModelPraise *> *praises; //点赞信息
//@property (nonatomic, strong) NSArray<DWDGrowUpModelComment *> *comments; //评论信息

- (void)_layoutContentView {
    DWDGrowUpModelRecord *record = _model.record;
    NSArray<DWDGrowUpModelPhoto *> *photosArray = _model.photos;
    //计算文本内容
    NSMutableAttributedString *contentStr = [self contentTextAttributedStringWithStr:record.content color:kCellNameColor fontSize:kCellContentFont];
    
    YYTextContainer *container = [YYTextContainer new];
//    container.size = CGSizeMake(DWDScreenW - (kCellPadding + kCellStartContentImageWidth + kCellStartContentImageLeftPadding + kCellContentLabelLeftPadding), HUGE);
    container.size = CGSizeMake(DWDScreenW - kCellPadding * 2, HUGE);
    
    _contentTextLayout = [YYTextLayout layoutWithContainer:container text:contentStr];
    if (!_contentTextLayout)
        return;
    if (_contentTextLayout.rowCount > 3) {
        _haveExpandContentButton = YES;
        if (!_expandingContent) {
            //未展开
            container.maximumNumberOfRows = 3;
        } else {
            //展开
            container.maximumNumberOfRows = 0;
        }
    } else {
        _haveExpandContentButton = NO;
    }
    _contentTextLayout = [YYTextLayout layoutWithContainer:container text:contentStr];
    _contentTextHeight = _contentTextLayout.textBoundingSize.height;
    
    //计算图片内容
    NSInteger count = photosArray.count;
    
    if (count == 0)
        return;
    
    CGFloat picsHeight = 0;
    
    if (count == 1) {
        picsHeight = kCellSinglePicWidth + kCellPadding;
    } else if (count == 2) {
        picsHeight = kCellDoublePicsWidth + kCellPadding;
    } else if (count == 3) {
        picsHeight = kCellThreePicsWidth + kCellPadding;
    } else if (count == 4) {
        picsHeight = (kCellDoublePicsWidth + kCellPadding) * 2;
    } else if (count <= 6) {
        picsHeight = (kCellThreePicsWidth + kCellPadding) * 2;
    } else if (count <= 9) {
        picsHeight = (kCellThreePicsWidth + kCellPadding) * 3;
    }
    _picsViewHeight = picsHeight;
}

- (void)_layoutPraise {
    NSArray<DWDGrowUpModelPraise *> *praisesArray = _model.praises;
    //计算点赞内容
    if (!praisesArray.count)
        return;
    NSMutableAttributedString *praiseStr = [self praisesTextAttributedStringWithPariseArray:praisesArray color:kCellButtonColor fontSize:kCellDateTimeFont];
    
    YYTextContainer *container = [YYTextContainer new];
    container.insets = UIEdgeInsetsMake(-pxToW(1), 0, kCellCommentLabelMargin - 1, 0);
    container.size = CGSizeMake(DWDScreenW - (kCellPadding * 2 + kCellPadding * 2 + kCellFlowerWidth), HUGE);
    
    _praisesTextLayout = [YYTextLayout layoutWithContainer:container text:praiseStr];
    if (!_contentTextLayout)
        return;
    _praisesHeight = _praisesTextLayout.textBoundingSize.height + 4;
}

- (void)_layoutComments {
    NSArray<DWDGrowUpModelComment *> *commentsArray = _model.comments;
    if (!commentsArray.count)
        return;
    //计算评论内容
    if (commentsArray.count > 9) {
        _haveExpandCommentsButton = YES;
    } else {
        _haveExpandCommentsButton = NO;
    }
    //根据count判断一共多长 传几个数组过去
    if (_haveExpandCommentsButton) {
        if (![self isExpandingComments]) {
            NSArray *array = [commentsArray subarrayWithRange:NSMakeRange(0, 9)];
            commentsArray = array;
        }
    }
    _commentsTextLayoutArray = [self calculateCommentTextLayoutsWithArray:commentsArray color:kCellNameColor highlightColor:kCellButtonColor fontSize:kCellDateTimeFont];
    
    CGFloat totalHeight = 0;
    for (YYTextLayout *layout in _commentsTextLayoutArray) {
        totalHeight += layout.textBoundingSize.height + 2;
    }

    _commentsHeight = totalHeight;
}

- (NSMutableAttributedString *)contentTextAttributedStringWithStr:(NSString *)content
                                                     color:(UIColor *)color
                                                      fontSize:(CGFloat)fontSize {
    //处理文本内容
    NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString:content];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    [attrContent setYy_font:font];
    [attrContent setYy_color:color];
    
    return attrContent;
}

- (NSMutableAttributedString *)praisesTextAttributedStringWithPariseArray:(NSArray *)praiseArray
                                                                    color:(UIColor *)color
                                                                 fontSize:(CGFloat)fontSize {
    NSMutableAttributedString *attrPraises = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < praiseArray.count; i ++) {
        DWDGrowUpModelPraise *praise = praiseArray[i];
        NSString *nameStr = @"";
        if (i == 0)
            nameStr = praise.nickname;
        else
            nameStr = [NSString stringWithFormat:@",%@", praise.nickname];
        NSAttributedString *attrName = [[NSAttributedString alloc] initWithString:nameStr];
        [attrPraises appendAttributedString:attrName];
        YYTextHighlight *highlight = [YYTextHighlight new];
        YYTextBorder *border = [YYTextBorder new];
        border.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
        border.fillColor = kCellCommentSelectedColor;
        border.cornerRadius = 1;
        [highlight setBackgroundBorder:border];
        highlight.userInfo = @{
                               @"custId" : praise.custId,
                               };
        [attrPraises yy_setTextHighlight:highlight range:NSMakeRange(attrPraises.length - praise.nickname.length, praise.nickname.length)];
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    [attrPraises setYy_font:font];
    [attrPraises setYy_color:color];
    
    return attrPraises;
}

- (NSArray *)calculateCommentTextLayoutsWithArray:(NSArray *)comments color:(UIColor *)color highlightColor:(UIColor *)highLightColor fontSize:(CGFloat)fontSize {
    NSMutableArray *layoutArray = [NSMutableArray new];
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    for (DWDGrowUpModelComment *comment in comments) {
        NSString *nickName1 = comment.nickname;
        NSString *nickName2 = comment.forNickname;
        NSString *text = comment.commentTxt;
        
        NSString *str1;
        NSMutableAttributedString *commentAttrStr;
        [commentAttrStr setYy_color:color];
        if ([nickName2 isEqualToString:@""] || nickName2 == nil) {
            str1 = [NSString stringWithFormat:@"%@：%@",nickName1,text];
            commentAttrStr = [[NSMutableAttributedString alloc] initWithString:str1];
            NSRange range = NSMakeRange(0, nickName1.length);
            [commentAttrStr yy_setColor:highLightColor range:range];
            YYTextHighlight *highlight = [YYTextHighlight new];
            highlight.userInfo = @{
                                    @"custId" : comment.custId
                                    };
            [commentAttrStr yy_setTextHighlight:highlight range:range];
        } else {
            str1 = [NSString stringWithFormat:@"%@ 回复 %@", nickName1, nickName2];
            NSRange range1 = NSMakeRange(0, nickName1.length);
            NSRange range2 = NSMakeRange(str1.length - nickName2.length,nickName2.length);
            str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"：%@", text]];
            commentAttrStr = [[NSMutableAttributedString alloc] initWithString:str1];
            
            commentAttrStr.yy_font = font;
            [commentAttrStr yy_setColor:highLightColor range:range1];
            [commentAttrStr yy_setColor:highLightColor range:range2];
            
            YYTextHighlight *highlight1 = [YYTextHighlight new];
            highlight1.userInfo = @{
                                    @"custId" : comment.custId
                                    };
            YYTextBorder *border1 = [YYTextBorder new];
            border1.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
            border1.fillColor = kCellCommentSelectedColor;
            border1.cornerRadius = 1;
            [highlight1 setBackgroundBorder:border1];
            
            YYTextHighlight *highlight2 = [YYTextHighlight new];
            highlight2.userInfo = @{
                                    @"custId" : comment.forCustId
                                    };
            YYTextBorder *border2 = [YYTextBorder new];
            border2.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
            border2.fillColor = kCellCommentSelectedColor;
            border2.cornerRadius = 1;
            [highlight2 setBackgroundBorder:border2];
            
            [commentAttrStr yy_setTextHighlight:highlight1 range:range1];
            [commentAttrStr yy_setTextHighlight:highlight2 range:range2];
        }
        
        static YYTextSimpleEmoticonParser *parser;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
            parser = [YYTextSimpleEmoticonParser new];
            parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
        });
        [parser parseText:commentAttrStr selectedRange:nil];
        YYTextContainer *container = [YYTextContainer new];
        container.insets = UIEdgeInsetsMake(kCellCommentLabelMargin, 0, kCellCommentLabelMargin, 0);
        container.size = CGSizeMake(DWDScreenW - (kCellCommentLabelLeftPadding + kCellPadding * 2), HUGE);
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:commentAttrStr];
//        if (!layoutArray)
//            return nil;
        [layoutArray addObject:layout];
    }
    return layoutArray;
}

@end
