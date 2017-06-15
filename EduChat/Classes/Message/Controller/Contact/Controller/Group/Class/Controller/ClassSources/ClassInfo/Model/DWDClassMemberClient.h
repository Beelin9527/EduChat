//
//  DWDClassMemberClient.h
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//  班级成员 Client

#import <Foundation/Foundation.h>

@interface DWDClassMemberClient : NSObject
+(instancetype)sharedClassMemberClient;
/** 获取班级成员 此接口是增量刷新 */
- (void)requestClassMemberGetListWithClassId:(NSNumber *)classId success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;
@end
