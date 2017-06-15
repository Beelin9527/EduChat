//
//  DWDOfflineChatMsg.h
//  EduChat
//
//  Created by Superman on 16/2/29.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDOfflineChatMsg : NSObject

@property (nonatomic , copy) NSString *content;
@property (nonatomic , strong) NSNumber *contentType; // 0文本  1图片 2语音 3-视频4-小视频/语音文件5-文件6-链接(含网页)
@property (nonatomic , copy) NSString *createTime;
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , copy) NSString *fileKey;
@property (nonatomic , copy) NSString *fileName;
@property (nonatomic , copy) NSString *filePxf;
@property (nonatomic , strong) NSNumber *infoId;

@end
