//
//  DWDMyChildClient.h
//  EduChat
//
//  Created by Gatlin on 16/3/17.
//  Copyright © 2016年 dwd. All rights reserved.
//  我的孩子 网络请求Biz

#import <Foundation/Foundation.h>

@interface DWDMyChildClient : NSObject
+(instancetype)sharedMyChildClient;
/** 列表 */
- (void)requestGetMyChildrenListWithCustId:(NSNumber *)custId
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSError *error))failure;
/** 获取我的孩子姓名 */
- (void)requestGetMyChildrenNameListWithCustId:(NSNumber *)custId
                                       classId:(NSNumber *)classId
                                       success:(void (^)(id responseObject))success
                                       failure:(void (^)(NSError *error))failure;
/** 详情 */
- (void)requestGetMyChildInfoWithCustId:(NSNumber *)custId
                            childCustId:(NSNumber *)childCustId
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSError *error))failure;
/** 更改信息 */
- (void)requestUpdateMyChildInfoWithCustId:(NSNumber *)custId
                               childCustId:(NSNumber *)childCustId
                                 childName:(NSString *)childName
                               childGender:(NSNumber *)childGender
                             childPhotoKey:(NSString *)childPhotoKey
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSError *error))failure;
@end
