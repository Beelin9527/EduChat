//
//  DWDCollectDataHandler.h
//  EduChat
//
//  Created by Gatlin on 16/8/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDCollectDataHandler : NSObject

/**
 * 收藏列表
 * @param custId long 操作客户号 √
 * @param idx int 页码
 * @param cnt int 页数
 */
+ (void)requestCollectListWithCustId:(NSNumber *)custId
                                 idx:(NSNumber *)idx
                                 cnt:(NSNumber *)cnt
                             success:(void(^)(NSArray *dataSource, BOOL isHaveData))success
                             failure:(void(^)(NSError *error))failure;

/**
 * 删除收藏
 * @param custId long 操作客户号 √
 * @param collectId int collectId √
 */
+ (void)requestDeleteCollectWithCustId:(NSNumber *)custId
                             collectId:(NSArray *)collectId
                               success:(void(^)(NSNumber *collectId))success
                               failure:(void(^)(NSError *error))failure;

@end
