//
//  DWDLoginDataHandler.h
//  EduChat
//
//  Created by Gatlin on 16/6/29.
//  Copyright © 2016年 dwd. All rights reserved.
//  登录 数据处理类

#import <Foundation/Foundation.h>

@interface DWDLoginDataHandler : NSObject
/**
 * 获取公钥
 * @param phoneNum 手机号
 * @param pasword  密码
 */
+ (void)requestGetPublicKeyWithPhoneNum:(NSString *)phoneNum
                               password:(NSString *)password
                                success:(void(^)(NSString *publicKey,NSString *password))success
                                failure:(void(^)(NSError *error))failure;

/**
 * 登录
 * @param userName 帐号
 * @param password 原始密码
 * @param encryptPassword  RSA加密密码
 */
+ (void)requestLoginWithUserName:(NSString *)userName
                               password:(NSString *)password
                        encryptPassword:(NSString *)encryptPassword
                                success:(void(^)(void))success
                                failure:(void(^)(NSError *error))failure;
@end
