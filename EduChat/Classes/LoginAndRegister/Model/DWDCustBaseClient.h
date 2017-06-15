//
//  DWDLoginAndRegisterModel.h
//  EduChat
//
//  Created by apple on 15/12/3.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDSingleton.h"
@interface DWDCustBaseClient : NSObject

DWDSingletonH(CustBaseClient)

/**
 * 获取公钥
 * @param NSString phoneNum 手机号
 */
+ (void)requestGetPublicKeyWithPhoneNum:(NSString *)phoneNum
                                success:(void(^)(NSString *publicKey))success
                                failure:(void(^)(NSError *error))failure;
/** 注册 **/
-(void)getRequestPraram:(NSDictionary *)params
                success:(void(^)(void))success
                failure:(void (^)(NSError *error))failure;

/**
 * 登录
 * @param userName 帐号
 * @param enctyptPassword RSA加密密码
 */
- (void)requestLoginPraramUserName:(NSString*)userName
                   enctyptPassword:(NSString*)enctyptPassword
                           success:(void(^)(NSDictionary *info))success
                           failure:(void (^)(NSError *error))failure;

/** 退出登录 **/
- (void)requestAcctCustLogout:(NSNumber *)custId
                      success:(void(^)(void))success
                      failure:(void (^)(NSError *error))failure;

/** 修改手机号码 **/
- (void)requestServerResetAcctPhoneNumCustId:(NSNumber *)custId
                                 newPhoneNum:(NSString *)newPhoneNum
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure;

/** 修改密 **/
- (void)requestServerResetAcctNumberPwdCustId:(NSNumber *)custId
                                       oldPwd:(NSString *)oldPwd
                                       newPwd:(NSString *)newPwd
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure;

/** 忘记密码 **/
- (void)requestServerRestForgotAcctPwdUserName:(NSString *)userName
                                        newPwd:(NSString *)newPwd
                                       success:(void (^)(id responseObject))success
                                       failure:(void (^)(NSError *error))failure;

/** 短信验证  
 验证类型 dataType
 1-注册
 2-找回密码
 3-修改密码
 4-更换手机号 (往原来手机发送)
 5-更换手机号 (往新手机发送)
 11-微信注册 */
- (void)requestSendVerifyCodeWithPhoneNum:(NSString *)phoneNum
                                 dataType:(NSNumber *)dataType
                                  success:(void (^)(id responseObject))success
                                  failure:(void (^)(NSError *error))failure;
@end
