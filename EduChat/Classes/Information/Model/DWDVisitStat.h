//
//  DWDVisitStat.h
//  EduChat
//
//  Created by Gatlin on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDVisitStat : NSObject
@property (nonatomic, strong) NSNumber *readCnt;//阅读数
@property (nonatomic, strong) NSNumber *praiseCnt;//点赞数
@property (nonatomic, strong) NSNumber *collectCnt; //收藏数
@property (nonatomic, strong) NSNumber *commentCnt;//评论数
@property (nonatomic, strong) NSNumber *readSta;//是否已读
@property (nonatomic, strong) NSNumber *collectSta;//是否收藏
@property (nonatomic, strong) NSNumber *praiseSta;//是否点赞
@end
/*
 阅读数	readCnt	int
 点赞数	praiseCnt	int
 评论数	commentCnt	int
 收藏数	collectCnt	int
 是否已读	readSta	bool
 是否点赞	praiseSta	bool
 是否收藏	collectSta	bool
 */