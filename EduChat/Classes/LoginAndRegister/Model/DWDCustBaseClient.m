//
//  DWDLoginAndRegisterModel.m
//  EduChat
//
//  Created by apple on 15/12/3.
//  Copyright © 2015年 j. All rights reserved.
//

#import "DWDCustBaseClient.h"

#import "DWDProgressHUD.h"

#import "DWDKeyChainTool.h"
#import "DWDRSAHandler.h"
@interface DWDCustBaseClient ()
@end
@implementation DWDCustBaseClient

DWDSingletonM(CustBaseClient)


#pragma mark - Request
/**
 * 获取公钥
 */
+ (void)requestGetPublicKeyWithPhoneNum:(NSString *)phoneNum
                                success:(void(^)(NSString *publicKey))success
                                failure:(void(^)(NSError *error))failure{
   
    [[HttpClient sharedClient] getApi:@"token/getKey"
                               params:@{@"phoneNum":phoneNum}
                              success:^(NSURLSessionDataTask *task, id responseObject){
                                  
                                  NSString *publicKey = responseObject[DWDApiDataKey];
                                 success(publicKey);
                              }
                              failure:^(NSURLSessionDataTask *task, NSError *error){
                                  failure(error);
                              }];
}


-(void)getRequestPraram:(NSDictionary *)params success:(void(^)(void))success failure:(void (^)(NSError *))failure
{
#if TARGET_IPHONE_SIMULATOR
    //解决模拟器无极光注册ID，导致到dictionary崩溃问题
    [DWDCustInfo shared].registrationID = @"123456789";
#endif
    
    //request
    [[HttpClient sharedClient]
     postApi:@"UserRestService/register"
     params:params
     success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSDictionary *info = responseObject[DWDApiDataKey];
        [self cacheWithInfo:info];

         success();
    }
     failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        failure(error);
    }];
}

- (void)requestLoginPraramUserName:(NSString *)userName enctyptPassword:(NSString *)enctyptPassword success:(void(^)(NSDictionary *))success failure:(void (^)(NSError *))failure{
    
      [DWDCustInfo shared].custId = nil;
    [[HttpClient sharedClient]
     postApi:@"UserRestService/login2"
     params:@{@"userName":userName,
              @"pwd":enctyptPassword,
              @"platform":@"iOS",
              @"deviceid":[DWDCustInfo shared].registrationID ? [DWDCustInfo shared].registrationID : [NSNull null],//极光id 注册失败返回nil 导致插入字崩溃
              @"devinfos":[[[UIDevice currentDevice] identifierForVendor] UUIDString]}
     success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSDictionary *info = responseObject[DWDApiDataKey];
        success(info);
    }
     failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        failure(error);
        DWDLog(@" error : %@" , [error localizedFailureReason]);
    }];

}


- (void)requestAcctCustLogout:(NSNumber *)custId success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
{
     DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    [[HttpClient sharedClient] postApi:@"UserRestService/logout" params:@{DWDCustId:custId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [hud hide:YES];
        failure(error);
    }];
}

- (void)requestServerResetAcctPhoneNumCustId:(NSNumber *)custId newPhoneNum:(NSString *)newPhoneNum success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    [[HttpClient sharedClient] postApi:@"UserRestService/resetAcctPhoneNum" params:@{DWDCustId:custId,@"newPhoneNum":newPhoneNum} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"修改成功，快去重新登录吧!" afterDelay:DefaultTime];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
        
        failure(error);
        
    }];
}

- (void)requestServerResetAcctNumberPwdCustId:(NSNumber *)custId oldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [[NSUserDefaults standardUserDefaults] setObject:newPwd
                                              forKey:kDWDOrignPwdCache];
    oldPwd = [oldPwd md532BitLower];
    newPwd = [newPwd md532BitLower];
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    [[HttpClient sharedClient] postApi:@"UserRestService/resetAcctNumberPwd" params:@{DWDCustId:custId,@"oldPwd":oldPwd,@"newPwd":newPwd} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"修改成功，快去重新登录吧!" afterDelay:DefaultTime];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
       [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
        
        failure(error);
        
    }];
}

- (void)requestServerRestForgotAcctPwdUserName:(NSString *)userName newPwd:(NSString *)newPwd success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [[NSUserDefaults standardUserDefaults] setObject:newPwd
                                              forKey:kDWDOrignPwdCache];
    newPwd = [newPwd md532BitLower];
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];

    [[HttpClient sharedClient] postApi:@"UserRestService/forgotAcctPwd" params:@{@"userName":userName,@"newPwd":newPwd} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"修改成功，快去重新登录吧!" afterDelay:DefaultTime];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
        
        failure(error);
        
    }];
}

- (void)requestSendVerifyCodeWithPhoneNum:(NSString *)phoneNum dataType:(NSNumber *)dataType success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [[HttpClient sharedClient]
     postApi:@"SmsRestService/verifyCode"
     params:@{@"phoneNum":phoneNum,@"dataType":dataType}
     success:^(NSURLSessionDataTask *task, id responseObject){
         NSDictionary *dict = responseObject[DWDApiDataKey];
         success(dict[@"code"]);
     }
     failure:^(NSURLSessionDataTask *task, NSError *error){
         failure(error);
     }];
    
}


#pragma mark Private Method
/** 缓存信息 */
- (void)cacheWithInfo:(NSDictionary *)info
{
    //赋值用户身份
    [DWDCustInfo shared].custIdentity = info[@"custType"];
    //缓存custId
    [DWDCustInfo shared].custId = info[@"custId"];
    [[NSUserDefaults standardUserDefaults] setObject:[DWDCustInfo shared].custId forKey:DWDLoginCustIdCache];
    
    //获取accessToken 与存储
    NSString *token =  info[@"accessToken"];
    [[DWDKeyChainTool sharedManager] writeKey:token
                                     WithType:KeyChainTypeToken];
    DWDLog(@"token : %@",token);
    //获取refreshToken 与存储
    NSString *refreshToken =  info[@"refreshToken"];
    [[DWDKeyChainTool sharedManager] writeKey:refreshToken
                                     WithType:KeyChainTypeRefreshToken];
    
    DWDLog(@"refreshToken : %@",refreshToken);
    
    //token 加密
    NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encryptToken = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:tokenData];
    
    //缓存 加密token 与 uid
    NSDictionary *dictHeaderInfo = [NSDictionary dictionaryWithObjectsAndKeys:encryptToken, @"encryptToken", info[@"uid"],@"uid", nil];
    [[NSUserDefaults standardUserDefaults] setObject:dictHeaderInfo forKey:kDWDRequestHeaderInfoCache];
}
@end
