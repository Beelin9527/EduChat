//
//  DWDGrowUpRecordFrame.m
//  EduChat
//
//  Created by Superman on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowUpRecordFrame.h"
#import "NSString+Extension.h"

#import "DWDGrowUpRecordModel.h"
#import "DWDGrowUpComments.h"
#import "TTTAttributedLabel.h"
#import <YYText.h>

@implementation DWDGrowUpRecordFrame

- (NSMutableArray *)picturesFrames{
    if (!_picturesFrames) {
        _picturesFrames = [NSMutableArray array];
    }
    return _picturesFrames;
}

- (void)setGrowupModel:(DWDGrowUpRecordModel *)growupModel{
    _growupModel = growupModel;
    
    _iconViewF = CGRectMake(pxToW(20), pxToH(20), pxToW(60), pxToH(60));
    
    CGSize nameLabelsize = [growupModel.author.name realSizeWithfont:DWDFontContent];
    _nameLabelF = CGRectMake(CGRectGetMaxX(_iconViewF) + pxToW(20), CGRectGetMidY(_iconViewF) - nameLabelsize.height * 0.5, nameLabelsize.width, nameLabelsize.height);
    
    CGSize dateLabelsize = [growupModel.author.addtime realSizeWithfont:DWDFontContent];
    _dateLabelF = CGRectMake(DWDScreenW - pxToW(20) - dateLabelsize.width, CGRectGetMidY(_iconViewF) - dateLabelsize.height * 0.5, dateLabelsize.width, dateLabelsize.height);
    
    _midLittleImageF = CGRectMake(pxToW(5), CGRectGetMaxY(_iconViewF) + pxToH(15), pxToW(44), pxToH(44));
    
    NSDictionary *attr = @{NSFontAttributeName : DWDFontContent};
    CGSize bodySize = [growupModel.record.content boundingRectWithSize:CGSizeMake(DWDScreenW - pxToW(20) - pxToW(57), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    _bodyLabelF = CGRectMake(CGRectGetMaxX(_midLittleImageF) + pxToW(8), CGRectGetMaxY(_iconViewF) + pxToH(20), bodySize.width, bodySize.height);
    
    CGSize allBtnSize = [@"全文" realSizeWithfont:DWDFontContent];
    _allBodyBtnF = CGRectMake(DWDScreenW - pxToW(20) - allBtnSize.width, CGRectGetMaxY(_bodyLabelF) + pxToH(20), allBtnSize.width, allBtnSize.height);
    
    CGFloat maxPictureY = 0;
// 111111111111
    CGFloat imgX;
    CGFloat imgY;
    CGFloat imgW;
    CGFloat imgH;
    int col;
    int row;
    for (int i = 0; i < growupModel.photos.count; i ++) {
        if (growupModel.photos.count == 1) {
            CGRect pictureF = CGRectMake(pxToW(20), CGRectGetMaxY(_allBodyBtnF) + pxToH(20), pxToW(300), pxToH(300));
            maxPictureY = CGRectGetMaxY(pictureF);
            [self.picturesFrames addObject:[NSValue valueWithCGRect:pictureF]];
            
        }else if (growupModel.photos.count == 2 || growupModel.photos.count == 4){
            row = i / 2;
            col = i % 2;
            imgW = pxToW(260);
            imgH = pxToH(260);
            imgX = pxToW(20) + col * (pxToW(20) + imgW);
            imgY = CGRectGetMaxY(_allBodyBtnF) + pxToH(20) + row * (pxToH(20) + imgH);
            CGRect pictureF = CGRectMake(imgX, imgY, imgW, imgH);
            maxPictureY = CGRectGetMaxY(pictureF);
            [self.picturesFrames addObject:[NSValue valueWithCGRect:pictureF]];
        }else{
            row = i / 3;
            col = i % 3;
            imgW = pxToW(230);
            imgH = pxToH(230);
            imgX = pxToW(20) + col * (pxToW(10) + imgW);
            imgY = CGRectGetMaxY(_allBodyBtnF) + pxToH(20) + row * (pxToH(10) + imgH);
            CGRect pictureF = CGRectMake(imgX, imgY, imgW, imgH);
            maxPictureY = CGRectGetMaxY(pictureF);
            [self.picturesFrames addObject:[NSValue valueWithCGRect:pictureF]];
        }
    }
    

    _commentBtnF = CGRectMake(DWDScreenW - pxToW(58), maxPictureY + pxToH(14), pxToW(44), pxToH(44));
    _flowerViewF = CGRectMake(pxToW(11), pxToH(3), pxToW(44), pxToH(44));
    _zanPeopleF = CGRectMake(pxToW(66), pxToH(3), DWDScreenW - pxToW(86) - pxToW(40), pxToH(50));
    
    __weak typeof(self) weakSelf = self;
    CGRect weakZanF = _zanPeopleF;
    self.reCountFrames = ^void(NSArray *arr){ // 点击展开按钮,遍历实际评论数次数
        [weakSelf.commentsFrames removeAllObjects];
        
        for (int i = 0; i < arr.count; i++) {
            if (i == 0) {
                DWDGrowUpComments *comment = growupModel.comments[i];
                CGSize commentSize1 = [weakSelf sizeWithFont:DWDFontContent name:comment.nickname text:comment.commentTxt];
                CGRect commentFrame = CGRectMake(pxToW(11), CGRectGetMaxY(weakZanF), commentSize1.width, commentSize1.height);
                [weakSelf.commentsFrames addObject:[NSValue valueWithCGRect:commentFrame]];
            }else{
                DWDGrowUpComments *comment = growupModel.comments[i];
                CGSize commentSize = [weakSelf sizeWithFont:DWDFontContent name:comment.nickname text:comment.commentTxt];
                CGRect lastCommentFrame = [weakSelf.commentsFrames[i - 1] CGRectValue];
                CGRect commentFrame = CGRectMake(pxToW(11), CGRectGetMaxY(lastCommentFrame), commentSize.width, commentSize.height);
                [weakSelf.commentsFrames addObject:[NSValue valueWithCGRect:commentFrame]];
            }
        }
        
        CGSize btnSize = [@"收起" realSizeWithfont:(DWDFontContent)];
        _extendBtnF = CGRectMake(DWDScreenW - pxToW(60) - btnSize.width, CGRectGetMaxY([[self.commentsFrames lastObject] CGRectValue]) + pxToH(20), btnSize.width, btnSize.height);
        _commentContainerF = CGRectMake(pxToW(20), CGRectGetMaxY(_commentBtnF) + pxToH(14), DWDScreenW - pxToW(40), CGRectGetMaxY(_extendBtnF) + pxToH(20));
        _cellHeight = CGRectGetMaxY(_commentContainerF) + pxToH(20);
    };  //    block
    
    for (int i = 0; i < growupModel.comments.count; i++) {
        
        if (growupModel.comments.count >= 10){
            for (int i = 0; i < 10; i++) { // 大于10条  遍历10次就可以
                if (i == 0) {
                    DWDGrowUpComments *comment = growupModel.comments[i];
                    CGSize commentSize1 = [self sizeWithFont:DWDFontContent name:comment.nickname text:comment.commentTxt];
                    CGRect commentFrame = CGRectMake(pxToW(11), CGRectGetMaxY(_zanPeopleF), commentSize1.width, commentSize1.height);
                    [self.commentsFrames addObject:[NSValue valueWithCGRect:commentFrame]];
                }else{
                    DWDGrowUpComments *comment = growupModel.comments[i];
                    CGSize commentSize = [self sizeWithFont:DWDFontContent name:comment.nickname text:comment.commentTxt];
                    CGRect lastCommentFrame = [self.commentsFrames[i - 1] CGRectValue];
                    CGRect commentFrame = CGRectMake(pxToW(11), CGRectGetMaxY(lastCommentFrame), commentSize.width, commentSize.height);
                    [self.commentsFrames addObject:[NSValue valueWithCGRect:commentFrame]];
                }
            }
            
            CGSize btnSize = [@"展开" realSizeWithfont:(DWDFontContent)];
            
            // 取第十个label的frame
            _extendBtnF = CGRectMake(DWDScreenW - pxToW(60) - btnSize.width, CGRectGetMaxY([[self.commentsFrames lastObject] CGRectValue]) + pxToH(20), btnSize.width, btnSize.height);
            
            _commentContainerF = CGRectMake(pxToW(20), CGRectGetMaxY(_commentBtnF) + pxToH(14), DWDScreenW - pxToW(40), CGRectGetMaxY(_extendBtnF) + pxToH(20));
            _cellHeight = CGRectGetMaxY(_commentContainerF) + pxToH(20);
            
        }else{
            if (i == 0) {
                DWDGrowUpComments *comment = growupModel.comments[i];
                CGSize commentSize = [self sizeWithFont:DWDFontContent name:comment.nickname text:comment.commentTxt];
                CGRect commentFrame = CGRectMake(pxToW(11), CGRectGetMaxY(_zanPeopleF), commentSize.width, commentSize.height);
                [self.commentsFrames addObject:[NSValue valueWithCGRect:commentFrame]];
            }else{
                DWDGrowUpComments *comment = growupModel.comments[i];
                CGSize commentSize = [self sizeWithFont:DWDFontContent name:comment.nickname text:comment.commentTxt];
                CGRect lastCommentFrame = [self.commentsFrames[i - 1] CGRectValue];
                CGRect commentFrame = CGRectMake(pxToW(11), CGRectGetMaxY(lastCommentFrame), commentSize.width, commentSize.height);
                [self.commentsFrames addObject:[NSValue valueWithCGRect:commentFrame]];
            }
            
            _extendBtnF = CGRectZero;
            
            _commentContainerF = CGRectMake(pxToW(20), CGRectGetMaxY(_commentBtnF) + pxToH(14), DWDScreenW - pxToW(40), CGRectGetMaxY([[self.commentsFrames lastObject] CGRectValue]) + pxToH(20));
            _cellHeight = CGRectGetMaxY(_commentContainerF) + pxToH(20);
        }
        
    }
    
    if (growupModel.comments.count == 0) {
        _commentContainerF = CGRectZero;
        
        _cellHeight = CGRectGetMaxY(_commentBtnF) + pxToH(20);
    }
    
}

- (NSMutableArray *)commentsFrames{
    if (_commentsFrames == nil) {
        _commentsFrames = [NSMutableArray array];
    }
    return _commentsFrames;
}

- (CGSize)sizeWithFont:(UIFont *)font name:(NSString *)name text:(NSString *)text{
    
    NSString *str1 = [NSString stringWithFormat:@"%@:%@",name,text];
    
    NSMutableAttributedString *commentAttrStr = [[NSMutableAttributedString alloc] initWithString:str1];
    NSRange range = NSMakeRange(0, name.length);
    
    commentAttrStr.yy_font = DWDFontContent;
    [commentAttrStr yy_setColor:DWDRGBColor(90, 136, 231) range:range];
    
    YYTextBorder *border = [YYTextBorder borderWithFillColor:[UIColor grayColor] cornerRadius:3];
    YYTextHighlight *highlight = [YYTextHighlight new];
    [highlight setColor:[UIColor whiteColor]];
    [highlight setBackgroundBorder:border];
    
    [commentAttrStr yy_setTextHighlight:highlight range:range];
    
    CGSize commentSize = [TTTAttributedLabel sizeThatFitsAttributedString:commentAttrStr withConstraints:CGSizeMake(DWDScreenW - pxToW(31) - pxToW(40), MAXFLOAT) limitedToNumberOfLines:0];
    
    return commentSize;
}

@end
