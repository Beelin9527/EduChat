//
//  DWDGrowUpRecordCommentList.m
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowUpRecordCommentList.h"
#import "TTTAttributedLabel.h"

@implementation DWDGrowUpRecordCommentList


- (CGFloat)cellHeight{
    if (!_cellHeight) {
        _iconViewF = CGRectMake(10, 10, 50, 50);
        NSString *name;
        if (_forNickname.length > 0) {
            name = [NSString stringWithFormat:@"%@回复%@",_nickname,_forNickname];
        }else{
            name = _nickname;
        }
        
        CGSize nameSize = [self getRealSizeWithString:name constaintsSize:CGSizeMake(MAXFLOAT, MAXFLOAT) numberofLines:1 font:DWDFontBody];
        
        _nameLabelF = CGRectMake(CGRectGetMaxX(_iconViewF) + 10 , 10, nameSize.width, nameSize.height);
        
        _pictureF = CGRectMake(DWDScreenW - 70, 10, 60, 60);
        
        CGSize bodySize = [self getRealSizeWithString:_commentTxt constaintsSize:CGSizeMake(DWDScreenW - 150, MAXFLOAT) numberofLines:0 font:DWDFontContent];
        
        _bodyLabelF = CGRectMake(CGRectGetMaxX(_iconViewF) + 10 , CGRectGetMaxY(_nameLabelF) + 10, bodySize.width, bodySize.height);
        
        CGSize dateSize = [self getRealSizeWithString:_addtime constaintsSize:CGSizeMake(MAXFLOAT, MAXFLOAT) numberofLines:1 font:DWDFontMin];
        _dateLabelF = CGRectMake(CGRectGetMaxX(_iconViewF) + 10 , CGRectGetMaxY(_bodyLabelF) + 10, dateSize.width, dateSize.height);
        
        _cellHeight = CGRectGetMaxY(_dateLabelF) + 10;
    }
    return _cellHeight;
}

- (CGSize)getRealSizeWithString:(NSString *)str constaintsSize:(CGSize)size numberofLines:(NSUInteger)lines font:(UIFont *)font{
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName : font}];
    return [TTTAttributedLabel sizeThatFitsAttributedString:attrStr withConstraints:size limitedToNumberOfLines:lines];
}

@end
