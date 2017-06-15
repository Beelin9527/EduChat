//
//  DWDSystemMessageDetailModel.h
//  EduChat
//
//  Created by apple on 2/28/16.
//  Copyright © 2016 dwd. All rights reserved.
//
//verifyInfo,custId, groupId, creatTime

#import <Foundation/Foundation.h>

@interface DWDSystemMessageDetailModel : NSObject

@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, copy) NSString *verifyInfo;
@property (nonatomic, copy) NSString *photoKey;
@property (nonatomic, copy) NSString *addTime;
@property (nonatomic, copy) NSString *verifyTime;
//0-待验证 1-通过 2-已拒绝
@property (nonatomic, assign) NSNumber *verifyState;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSNumber *memberChildId;

// 要改3个地方
/**
 验证id 还没给 XXXX
 2016年12月05日10:11:18
 时隔几个月 终于给了
 */
@property (nonatomic, strong) NSNumber *verifyId;


@end
