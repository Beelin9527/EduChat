//
//  DWDGrowUpCellCommentView.m
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDGrowUpCellCommentView.h"
#import "DWDGrowUpComments.h"
#import "TTTAttributedLabel.h"

#import <YYText.h>
#import <Masonry.h>

@interface DWDGrowUpCellCommentView ()

@property (nonatomic, weak) UIButton *expandCommentButton;
@property (nonatomic, assign) BOOL buttonExpand;

@property (nonatomic, weak) YYLabel *lastLabel;

@property (nonatomic, strong) NSDictionary *mapper;

@end

@implementation DWDGrowUpCellCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

#pragma mark - private method

- (void)setupCommentLabel:(YYLabel *)label withComment:(DWDGrowUpComments *)comment{
    //- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    DWDGrowUpRecordFrame *frameModel = self.records[indexPath.row];
    //
    //    return frameModel.cellHeight;
//            YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
//            parser.emoticonMapper = self.mapper;
//            label.textParser = parser;
//            label = self.comments[i];
            

            //解析表情
//            NSMutableDictionary *mapper = [NSMutableDictionary new];
//            NSString *facePlistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
//            NSArray *face = [NSArray arrayWithContentsOfFile:facePlistPath];
//            NSMutableArray *faceName = [NSMutableArray new];
//            for (NSDictionary *faceDic in face) {
//                [faceName addObject:faceDic[@"faceName"]];
//            }
//            for (int i = 0; i < 19; i ++) {
//                UIImage *image = [UIImage imageNamed:faceName[i]];
//                DWDMarkLog(@"%@", image);
//                mapper[faceName[i]] = image;
//            }
    label.numberOfLines = 0;
    label.preferredMaxLayoutWidth = DWDScreenW - pxToW(20) - pxToW(57);
    
    // 创建评论属性文字,拼接
    NSString *str1 = nil;
    NSString *nickName1 = comment.nickname;
    NSString *nickName2 = comment.forNickname;
    NSString *text = comment.commentTxt;
    NSMutableAttributedString *commentAttrStr;
    if ([nickName2 isEqualToString:@""]) {
        str1 = [NSString stringWithFormat:@"%@:%@",nickName1,text];
        commentAttrStr = [[NSMutableAttributedString alloc] initWithString:str1];
        NSRange range = NSMakeRange(0, nickName1.length);
        
        commentAttrStr.yy_font = DWDFontContent;
        [commentAttrStr yy_setColor:DWDRGBColor(90, 136, 231) range:range];
        
        YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor grayColor] cornerRadius:3];
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:[UIColor whiteColor]];
        [highlight setBackgroundBorder:border];
        
        [commentAttrStr yy_setTextHighlight:highlight range:range];
        
        WEAKSELF;
        label.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if ([weakSelf.delegate respondsToSelector:@selector(commentView:didClickCustId:)]) {
                [weakSelf.delegate commentView:self didClickCustId:comment.custId];
            }
        };
        label.attributedText = commentAttrStr;
    } else {
        str1 = [NSString stringWithFormat:@"%@ 回复 %@:%@", nickName1, nickName2, text];
        commentAttrStr = [[NSMutableAttributedString alloc] initWithString:str1];
        NSRange range1 = NSMakeRange(0, nickName1.length);
        NSUInteger replyStringLength = @" 回复 ".length;
        NSRange range2 = NSMakeRange(range1.length + replyStringLength,nickName2.length);
        
        commentAttrStr.yy_font = DWDFontContent;
        [commentAttrStr yy_setColor:DWDRGBColor(90, 136, 231) range:range1];
        [commentAttrStr yy_setColor:DWDRGBColor(90, 136, 231) range:range2];
        
        YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor grayColor] cornerRadius:3];
        YYTextHighlight *highlight = [YYTextHighlight new];
        [highlight setColor:DWDRGBColor(231, 231, 231)];
        [highlight setBackgroundBorder:border];
        
        [commentAttrStr yy_setTextHighlight:highlight range:range1];
        [commentAttrStr yy_setTextHighlight:highlight range:range2];
        
        WEAKSELF;
        label.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            if ([weakSelf.delegate respondsToSelector:@selector(commentView:didClickCustId:)]) {
                if (range.location == range1.location) {
                    [weakSelf.delegate commentView:self didClickCustId:comment.custId];
                } else if (range.location == range2.location){
                    [weakSelf.delegate commentView:self didClickCustId:comment.forCustId];
                }
            }
        };
        label.attributedText = commentAttrStr;
    }
    WEAKSELF;
    label.textTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect)
    {
        if ([weakSelf.delegate respondsToSelector:@selector(commentView:didClickLabelWithCustId:)]) {
            [weakSelf.delegate commentView:self didClickLabelWithCustId:comment.custId];
        }
    };
//    YYTextContainer *container = [YYTextContainer new];
//    container.size = CGSizeMake(DWDScreenW - DWDScreenW - pxToW(20) - pxToW(57), CGFLOAT_MAX);
//    container.maximumNumberOfRows = 0;
//    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:commentAttrStr];
//    [label updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo([TTTAttributedLabel sizeThatFitsAttributedString:commentAttrStr withConstraints:CGSizeMake(DWDScreenW - pxToW(20) - pxToW(57), MAXFLOAT) limitedToNumberOfLines:100].height + 2);
//    }];
    
//    DWDMarkLog(@"string:%@\nheight:%f",commentAttrStr.string, [TTTAttributedLabel sizeThatFitsAttributedString:commentAttrStr withConstraints:CGSizeMake(DWDScreenW - pxToW(20) - pxToW(57), MAXFLOAT) limitedToNumberOfLines:100].height);
    //
//    [super updateConstraints];
}

- (void)displayCommentList:(NSArray *)commentArray {
//    YYTextDebugOption *debugOptions = [YYTextDebugOption new];
//    debugOptions.baselineColor = [UIColor redColor];
//    debugOptions.CTFrameBorderColor = [UIColor redColor];
//    debugOptions.CTLineFillColor = [UIColor colorWithRed:0.000 green:0.463 blue:1.000 alpha:0.180];
//    debugOptions.CGGlyphBorderColor = [UIColor colorWithRed:1.000 green:0.524 blue:0.000 alpha:0.200];
//    [YYTextDebugOption setSharedDebugOption:debugOptions];

    for (int i = 0; i < commentArray.count; i ++) {
        //数据
        DWDGrowUpComments *comment = commentArray[i];
        YYLabel *label = [YYLabel new];
        label.backgroundColor = DWDRGBColor(231, 231, 231);
        label.font = DWDFontContent;
        
        YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
        parser.emoticonMapper = self.mapper;
        label.textParser = parser;
        
//        if ([comment.forNickname isEqualToString:@""]) {
            //            label.text = [NSString stringWithFormat:@"%@:", comment.nickname];
        
        //        } else {
//            label.text = [NSString stringWithFormat:@"%@回复%@:", comment.nickname, comment.forNickname];
//        }
//        label.text = [label.text stringByAppendingString:comment.commentTxt];
        
        
    
        [self addSubview:label];
        //页面
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self);
            make.right.mas_equalTo(self);
        }];
        //判断是否是第一条评论 进行布局
        if (i == 0) {
            [label updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self).offset(pxToW(20));
            }];
        } else {
            [label updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.lastLabel.bottom);
            }];
        }
        self.lastLabel = label;
        [self setupCommentLabel:label withComment:comment];
    }
}



#pragma mark - event response
- (void)expandCommentButtonClick {
    DWDMarkLog(@"expandCommentButtonClick");
    if (self.buttonExpand == NO) {
        [self.expandCommentButton setTitle:@"收起" forState:UIControlStateNormal];
        self.buttonExpand = YES;
    }
    else {
        [self.expandCommentButton setTitle:@"展开" forState:UIControlStateNormal];
        self.buttonExpand = NO;
    }
        [super updateConstraints];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GrowUpTableViewReloadData" object:nil];
    
}

#pragma mark - setter / getter
- (void)setCommentsArray:(NSArray *)commentsArray {
    _commentsArray = commentsArray;
//    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (id view in self.subviews) {
        if ([view isKindOfClass:[YYLabel class]]) {
            [view removeFromSuperview];
        }
    }
    NSArray *commentArray = [NSArray new];
    if (commentsArray.count > 10) {
        //设置数据
        [self.expandCommentButton setNeedsDisplay];
        if (self.buttonExpand) {
            commentArray = commentsArray;
        } else {
            NSRange range = NSMakeRange(0, 10);
            commentArray = [commentsArray subarrayWithRange:range];
        }
        //放置数据
        [self displayCommentList:commentArray];
        [self.expandCommentButton updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lastLabel.bottom).offset(pxToW(20));
        }];
    } else {
        [self.expandCommentButton removeFromSuperview];
        //放置数据
        [self displayCommentList:commentsArray];
        if (commentsArray.count > 0) {
            [self.lastLabel updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
            }];
        }
    }
    
    [super updateConstraints];
    
    /*
     评论大于10 和评论小于10一样,但是增加一个按钮
     判断按钮状态 确认显示多少
     
     评论小于10
     */
}

- (UIButton *)expandCommentButton {
    if (!_expandCommentButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (self.buttonExpand == NO) {
        [button setTitle:@"展开" forState:UIControlStateNormal];
        }
        else {
        [button setTitle:@"收起" forState:UIControlStateNormal];
        }
        [button setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(expandCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(-pxToW(20));
            make.right.mas_equalTo(self).offset(-pxToW(20));
        }];
        _expandCommentButton = button;
    }
    return _expandCommentButton;
}


- (NSDictionary *)mapper {
    if (!_mapper) {
//        NSMutableDictionary *mapper = [NSMutableDictionary new];
//        mapper[@"[anger]"] = [UIImage imageNamed:@"[anger]"];
//        mapper[@"[awkward]"] = [UIImage imageNamed:@"[awkward]"];
//        mapper[@"[cold]"] = [UIImage imageNamed:@"[cold]"];
//        mapper[@"[like]"] = [UIImage imageNamed:@"[like]"];
//        mapper[@"[cool]"] = [UIImage imageNamed:@"[cool]"];
//        mapper[@"[crazy]"] = [UIImage imageNamed:@"[crazy]"];
//        mapper[@"[curled]"] = [UIImage imageNamed:@"[curled]"];
//        mapper[@"[naughty]"] = [UIImage imageNamed:@"[naughty]"];
//        mapper[@"[proud]"] = [UIImage imageNamed:@"[proud]"];
//        mapper[@"[sad]"] = [UIImage imageNamed:@"[sad]"];
//        mapper[@"[shutup]"] = [UIImage imageNamed:@"[shutup]"];
//        mapper[@"[shy]"] = [UIImage imageNamed:@"[shy]"];
//        mapper[@"[sleep]"] = [UIImage imageNamed:@"[sleep]"];
//        mapper[@"[smile]"] = [UIImage imageNamed:@"[smile]"];
//        mapper[@"[spit]"] = [UIImage imageNamed:@"[spit]"];
//        mapper[@"[stunned]"] = [UIImage imageNamed:@"[stunned]"];
//        mapper[@"[surprised]"] = [UIImage imageNamed:@"[surprised]"];
//        mapper[@"[tears]"] = [UIImage imageNamed:@"[tears]"];
//        mapper[@"[toothy]"] = [UIImage imageNamed:@"[toothy]"];
//        mapper[@"[weep]"] = [UIImage imageNamed:@"[weep]"];
        
        //解析表情
        NSMutableDictionary *mapper = [NSMutableDictionary new];
        NSString *facePlistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
        NSArray *face = [NSArray arrayWithContentsOfFile:facePlistPath];
        NSMutableArray *faceName = [NSMutableArray new];
        for (NSDictionary *faceDic in face) {
            [faceName addObject:faceDic[@"faceName"]];
        }
        for (int i = 0; i < 19; i ++) {
            UIImage *image = [UIImage imageNamed:faceName[i]];
            mapper[faceName[i]] = image;
        }
        
        _mapper = mapper;
    }
    return _mapper;
}

@end
