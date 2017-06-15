//
//  DWDClassNotificationDetailLayout.m
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassNotificationDetailLayout.h"
#import "DWDClassNotificationDetailModel.h"
#import <YYText.h>

@implementation DWDClassNotificationDetailLayout

- (instancetype)initWithModel:(DWDClassNotificationDetailModel *)model {
    _model = model;
    [self layout];
    return self;
}

- (void)layout {
    _contentHeight = 0;
    _completeHeight = 0;
    _uncompleteHeight = 0;
    
    /**
     *
     * 内容总高度
     *
     */
    //头部高度
    _contentHeight += pxToW(120);
    //文本高度
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(DWDScreenW - kContentCellPadding * 2, MAXFLOAT)];
    NSMutableAttributedString *attributedString = [self contentAttributedStringWithString:_model.notice.content];
    attributedString.yy_lineSpacing = 5;
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:attributedString];
    _contentLayout = textLayout;
    _contentHeight += textLayout.textBoundingSize.height + kContentCellContentTopPadding;
    //图片高度
    if (_model.notice.photos.count) {
        NSUInteger count = _model.notice.photos.count;
        CGFloat picsHeight = 0;
        if (count == 1) {
            picsHeight = kContentCellSinglePicWidth;
        } else if (count == 2) {
            picsHeight = kContentCellDoublePicsWidth;
        } else if (count == 3) {
            picsHeight = kContentCellThreePicsWidth;
        } else if (count == 4) {
            picsHeight = (kContentCellDoublePicsWidth) * 2 + kContentCellPadding;
        } else if (count <= 6) {
            picsHeight = (kContentCellThreePicsWidth) * 2 + kContentCellPadding;
        } else if (count <= 9) {
            picsHeight = (kContentCellThreePicsWidth) * 3 + kContentCellPadding * 2;
        } else {
            NSInteger rowsCount = (count % 3 == 0 ? count / 3 : (count / 3 + 1));
            picsHeight =  + kContentCellThreePicsWidth * rowsCount + kContentCellPadding * (rowsCount - 1);
        }
        _contentHeight += picsHeight + kContentCellContentTopPadding;
        _imagesHeight = picsHeight;
    }
    //按钮高度
    _contentHeight += kContentCellSingleButtonHeight + kContentCellContentTopPadding + kContentCellPadding + kContentCellContentTopPadding;
    /**
     *
     * 回复总高度
     *
     */
    
    //segmentControl高度
    _completeHeight = 0;
    _uncompleteHeight = 0;
    
    //根据type拿出已完成和未完成的数组
    NSArray *completeArray = [NSArray array];
    NSArray *unCompleteArray = [NSArray array];
    if ([_model.notice.type isEqualToNumber:@2]) {
        completeArray = _model.replys.joins;
        unCompleteArray = _model.replys.unjoins;
    } else {
        completeArray = _model.replys.readeds;
        unCompleteArray = _model.replys.unreads;
    }
    //完成高度
    CGFloat viewWidth = (DWDScreenW - kReplyCellLeftPadding * 2 - kReplyCellOtherPadding * 4) / 5.0f;
//    CGFloat margin = (DWDScreenW - 250) / 6.0f;
    CGFloat viewHeight = viewWidth + 22 + kContentCellContentTopPadding;
    
    if (completeArray.count) {
        _completeHeight = [self rowOfReply:completeArray.count] * (viewHeight + kContentCellContentTopPadding);
        _completeBlank = NO;
    } else {
        //显示空白页
        _completeHeight = pxToH(477);
        _completeBlank = YES;
    }
    //未完成高度
    if (unCompleteArray.count) {
        _uncompleteHeight = [self rowOfReply:unCompleteArray.count] * (viewHeight + kContentCellContentTopPadding);
        _unCompleteBlank = NO;
    } else {
        //显示空白页
        _uncompleteHeight = pxToH(477);
        _unCompleteBlank = YES;
    }
}

//计算有几行

- (NSInteger)rowOfReply:(NSUInteger)memberCount {
    return ((memberCount % 5) ? (memberCount / 5 + 1) : (memberCount / 5));
}

//内容label的富文本文字
- (NSMutableAttributedString *)contentAttributedStringWithString:(NSString *)string {
    return [[NSMutableAttributedString alloc] initWithString:string
                                                  attributes:@{
                                                               NSFontAttributeName : kCellTitleFont,
                                                               NSForegroundColorAttributeName : kCellTitleColor
                                                               }];
}

#pragma mark - Setter / Getter

- (void)setCompleteSelected:(BOOL)completeSelected {
    _completeSelected = completeSelected;
}

@end
