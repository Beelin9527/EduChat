//
//  DWDArticleFrameModel.m
//  EduChat
//
//  Created by Beelin on 16/11/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDArticleFrameModel.h"

#import "DWDArticleModel.h"

#import "NSString+extend.h"
#import "NSNumber+Extension.h"
#import "NSDate+dwd_dateCategory.h"

static  CGFloat const kTitlePidding = 5.0f;
#define MaxX(class) class.origin.x + class.size.width
#define MaxY(class) class.origin.y + class.size.height
@implementation DWDArticleFrameModel

#pragma mark - Setter
- (void)setArticleModel:(DWDArticleModel *)articleModel{
    _articleModel = articleModel;

    //判断类型 1.文字 2.图文 3.视频+文字 4.音频+文字
    switch ([articleModel.contentType integerValue]) {
        case 1:
            [self calculateArticleFrame];
            break;
        case 2:
            //判断图片是否超过3张
#warning Beelin to do 目前接口还未有图片数组字段，先显示单张图片格式
            [self calculatePhotoFrame];
            break;
        case 3:
            [self calculateVideoFrame];
            break;
        case 4:
            [self calculateArticleFrame];
            break;
            
        default:
            break;
    }
}

#pragma mark - Calculate Frame
/** 计算文章与语音的控件frame */
- (void)calculateArticleFrame{
    //title
    CGSize  titleSize = [self.articleModel.title boundingRectWithfont:DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:17] sizeMakeWidth:DWDScreenW - 30];
    
    _titleFrame = ({
        CGRectMake(DWDPaddingMax,
                   DWDPaddingMax * DWDScreenW/375.0,
                   titleSize.width,
                   titleSize.height);
    });
    
    //nickname
    CGSize nicknameSize = [self.articleModel.auth.nickname boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _nicknameFrame = ({
        CGRectMake(DWDPaddingMax,
                   MaxY(_titleFrame) + 10,
                   nicknameSize.width,
                   nicknameSize.height);
    });
    
    //time
    NSString *timeStr = [NSString stringWithTimelineDate:[NSDate dateWithString:self.articleModel.time format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    timeStr = [NSString stringWithFormat:@"· %@",timeStr];
    CGSize timeSize = [timeStr boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _timeFrame = ({
        CGRectMake(MaxX(_nicknameFrame) + kTitlePidding,
                   _nicknameFrame.origin.y,
                   timeSize.width,
                   timeSize.height);
    });
  
    //readIcon
    _readIconFrame = ({
        CGRectMake(MaxX(_timeFrame) + 10,
                   _nicknameFrame.origin.y + _nicknameFrame.size.height/2 - 11/2,
                   15,
                   11);
    });

    //readcnt
    NSString *readStr = [self.articleModel.visitStat.readCnt calculateReadCount];
    CGSize readcntSize = [readStr boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _readcntFrame = ({
        CGRectMake(MaxX(_readIconFrame) + kTitlePidding,
                   _timeFrame.origin.y,
                   readcntSize.width,
                   readcntSize.height);
    });
    
    _cellHeight = MaxY(_readIconFrame) + DWDPaddingMax;

}

/** 计算单张图片的控件frame */
- (void)calculatePhotoFrame{
    //photo
    CGFloat photoW = 112 * DWDScreenW/375.0;
    CGFloat photoH = 71 * DWDScreenW/375.0;
    _photo1Frame = ({
        CGRectMake(DWDScreenW - DWDPaddingMax - photoW,
                   DWDPaddingMax,
                   photoW,
                   photoH);
    });
    
    //title
    CGSize titleSize = [self.articleModel.title boundingRectWithfont:DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:17]
                                                       sizeMakeWidth:DWDScreenW - 30 - photoW - DWDPaddingMax];

    NSInteger row = titleSize.height / [self.articleModel.title boundingRectWithfont:DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:17]].height;
    switch (row) {
        case 1://一行字
            _titleFrame = ({
                CGRectMake(DWDPaddingMax,
                           30 * DWDScreenW/375.0,
                           titleSize.width,
                           titleSize.height);
            });
            break;
        case 2: //两行字
            _titleFrame = ({
                CGRectMake(DWDPaddingMax,
                           18 * DWDScreenW/375.0,
                           titleSize.width,
                           titleSize.height);
            });
            break;
        case 3://三行字
            _titleFrame = ({
                CGRectMake(DWDPaddingMax,
                           18 * DWDScreenW/375.0,
                           titleSize.width,
                           titleSize.height);
            });
            break;
            
        default:
            break;
    }

    
    //nickname
    CGSize nicknameSize = [self.articleModel.auth.nickname boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _nicknameFrame = ({
        CGRectMake(DWDPaddingMax,
                   MaxY(_titleFrame) + 10,
                   nicknameSize.width,
                   nicknameSize.height);
    });
    
    //time
    NSString *timeStr = [NSString stringWithTimelineDate:[NSDate dateWithString:self.articleModel.time format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    timeStr = [NSString stringWithFormat:@"· %@",timeStr];
    CGSize timeSize = [timeStr boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _timeFrame = ({
        CGRectMake(MaxX(_nicknameFrame) + kTitlePidding,
                   _nicknameFrame.origin.y,
                   timeSize.width,
                   timeSize.height);
    });
    
    //readIcon
    _readIconFrame = ({
        CGRectMake(MaxX(_timeFrame) + 10,
                   _nicknameFrame.origin.y + _nicknameFrame.size.height/2 - 11/2,
                   15,
                   11);
    });
    
    //readcnt
    NSString *readStr = [self.articleModel.visitStat.readCnt calculateReadCount];
    CGSize readcntSize = [readStr boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _readcntFrame = ({
        CGRectMake(MaxX(_readIconFrame) + kTitlePidding,
                   _timeFrame.origin.y,
                   readcntSize.width,
                   readcntSize.height);
    });
    
    switch (row) {
        case 1://一行字
            _cellHeight = MaxY(_photo1Frame) + DWDPaddingMax;
            break;
        case 2: //两行字
             _cellHeight = MaxY(_photo1Frame) + DWDPaddingMax;
            break;
        case 3://三行字
             _cellHeight = MaxY(_readIconFrame) + DWDPaddingMax;
            break;
            
        default:
            break;
    }

}

/** 计算多张图片的控件frame */
- (void)calculateMorePhotoFrame{
    
}

/** 计算视频的控件frame */
- (void)calculateVideoFrame{
    //title
    CGSize titleSize = [self.articleModel.title boundingRectWithfont:DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:17]
                                                       sizeMakeWidth:DWDScreenW - 30];
    _titleFrame = ({
        CGRectMake(DWDPaddingMax,
                   DWDPaddingMax,
                   titleSize.width,
                   titleSize.height);
    });
    
    //photo
    _photo1Frame = ({
        CGRectMake(DWDPaddingMax,
                   MaxY(_titleFrame) + kTitlePidding,
                   DWDScreenW - DWDPaddingMax*2,
                   386/2 * (DWDScreenW/375.0));
    });

    //videoIcon
    _videoIconFrame = ({
        CGRectMake(DWDScreenW/2 - 50/2,
                   _photo1Frame.origin.y + (70* (DWDScreenW/375.0)),
                   50,
                   50);
    });
    //videoTimeFrame
    _videoTimeFrame = ({
        CGRectMake(DWDScreenW/2 - 100/2,
                   MaxY(_videoIconFrame) + 10,
                   100,
                   12);

    });
    
    
    //nickname
    CGSize nicknameSize = [self.articleModel.auth.nickname boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _nicknameFrame = ({
        CGRectMake(DWDPaddingMax,
                   MaxY(_photo1Frame) + 10,
                   nicknameSize.width,
                   nicknameSize.height);
    });
    
    //time
    NSString *timeStr = [NSString stringWithTimelineDate:[NSDate dateWithString:self.articleModel.time format:@"YYYYMMddHHmmss"]]; //YYYY-MM-dd HH:mm:ss]
    timeStr = [NSString stringWithFormat:@"· %@",timeStr];
    CGSize timeSize = [timeStr boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _timeFrame = ({
        CGRectMake(MaxX(_nicknameFrame) + kTitlePidding,
                   _nicknameFrame.origin.y,
                   timeSize.width,
                   timeSize.height);
    });
    
    //readIcon
    _readIconFrame = ({
        CGRectMake(MaxX(_timeFrame) + 10,
                   _nicknameFrame.origin.y + _nicknameFrame.size.height/2 - 11/2,
                   15,
                   11);
    });
    
    //readcnt
    NSString *readStr = [self.articleModel.visitStat.readCnt calculateReadCount];
    CGSize readcntSize = [readStr boundingRectWithfont:DWDScreenW > 320.0f ? DWDFontMin : [UIFont systemFontOfSize:11]];
    _readcntFrame = ({
        CGRectMake(MaxX(_readIconFrame) + kTitlePidding,
                   _timeFrame.origin.y,
                   readcntSize.width,
                   readcntSize.height);
    });
    
    _cellHeight = MaxY(_readIconFrame) + DWDPaddingMax;

}

@end
