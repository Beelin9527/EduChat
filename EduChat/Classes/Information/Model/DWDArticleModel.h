//
//  DWDArticleModel.h
//  EduChat
//
//  Created by Gatlin on 16/8/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDVisitStat.h"

@interface DWDAuth : NSObject
@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *photoKey;

@end

@interface DWDVideo : NSObject
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *videoUrl;
@end

@interface DWDVoice : NSObject
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *fileName;
@end

@interface DWDArticleModel : NSObject
@property (nonatomic, strong) NSNumber *infoId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSNumber *contentType; //1.文字 2.图文 3.视频+文字 4.音频+文字
@property (nonatomic, strong) NSString *contentLink;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSNumber *unreadCnt;

@property (nonatomic, strong) DWDVisitStat *visitStat;
@property (nonatomic, strong) DWDAuth *auth;
@property (nonatomic, strong) DWDVideo *video;
@property (nonatomic, strong) DWDVoice *voice;

@property (nonatomic, assign) float height;
@end



