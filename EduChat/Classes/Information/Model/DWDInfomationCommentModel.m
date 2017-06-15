//
//  DWDInfomationCommentModel.m
//  EduChat
//
//  Created by KKK on 16/5/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfomationCommentModel.h"
#import "NSDictionary+dwd_extend.h"

#import <YYLabel.h>

@implementation DWDInfomationCommentModel


- (CGFloat)cellHeight {
    CGFloat baseHeight = 34;// 10 * 2 + 5 + 9;
    CGFloat height = baseHeight + [self labelHeightWithString:@"dateTime" fontSize:12];
    YYLabel *heightLabel = [YYLabel new];
    
        static YYTextSimpleEmoticonParser *parser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //            YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
        parser = [YYTextSimpleEmoticonParser new];
        parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    });
    //计算评论内容高度
    NSMutableAttributedString *commentStr = [[NSMutableAttributedString alloc] initWithString:self.commentTxt attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    //设置行距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [commentStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.commentTxt length])];
    
    [parser parseText:commentStr selectedRange:nil];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(DWDScreenW - 60, MAXFLOAT)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:commentStr];
    heightLabel.textLayout = layout;
//    [heightLabel sizeToFit];
    height += layout.textBoundingSize.height;
    
    //计算头像高度
    //设置咨询名字显示
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.nickname attributes:@{NSForegroundColorAttributeName : DWDRGBColor(102, 102, 102),
                                                                                                                    NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    if ([self.forCustId isEqualToNumber:@0] || self.forCustId == nil || self.forNickname == nil || self.forNickname.length == 0) {
        //这些情况发生一种表示不是回复
    } else {
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" 回复 " attributes:@{
                                                                                                    NSForegroundColorAttributeName : DWDRGBColor(102, 102, 102),
                                                                                                    NSFontAttributeName : [UIFont systemFontOfSize:14]}]];
        //        NSUInteger length = str.length;
        //        NSRange range = NSMakeRange(length, _model.forNickname.length);
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:self.forNickname attributes:@{
                                                                                                               NSForegroundColorAttributeName : DWDRGBColor(80, 125, 175),
                                                                                                               NSFontAttributeName : [UIFont systemFontOfSize:14]
                                                                                                               }]];
    }
    [parser parseText:str selectedRange:nil];
    
    YYTextLayout *nameLayout = [YYTextLayout layoutWithContainer:container text:str];
    height += nameLayout.textBoundingSize.height;
    
    return height;
}

- (CGFloat)labelHeightWithString:(NSString *)str fontSize:(CGFloat)fontSize {
    
    CGSize size = CGSizeZero;
    if (str) {
        //        CGFloat blankCommentHeight = DWDScreenW - 60;// 10 * 3 - 30;
        CGRect frame = [str boundingRectWithSize:CGSizeMake(DWDScreenW - 60, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]}
                                         context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
    }
    return size.height;
}

@end
