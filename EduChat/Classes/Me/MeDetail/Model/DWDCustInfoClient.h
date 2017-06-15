//
//  DWDRequestServerMeDetail.h
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//  请求 “我”模块 API

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"


@interface DWDCustInfoClient : NSObject

DWDSingletonH(CustInfoClient)


/** 修改昵称 */
- (void)requestUpdateWithNickname:(NSString *)nickname success:(void (^)(id responseObject))success;

/** 修改性别 */
- (void)requestUpdateWithGender:(NSNumber *)gender success:(void (^)(id responseObject))success;

/** 修改头像 */
- (void)requestUpdateWithPhotoKey:(NSString *)photoKey success:(void (^)(id responseObject))success;

/** 修改个性签名 */
- (void)requestUpdateWithSignature:(NSString *)signature success:(void (^)(id responseObject))success;

/** 修改多维度号 */
- (void)requestUpdateWithEduchatAccount:(NSString *)educhatAccount success:(void (^)(id responseObject))success;

/** 修改地区 */
- (void)requestUpdateWithRegionName:(NSString *)regionName success:(void (^)(id responseObject))success;

// get my class list
- (void)requestClassGetListCustId:(NSNumber *)custId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
