//
//  DWDLoginDataHandler.m
//  EduChat
//
//  Created by Gatlin on 16/6/29.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLoginDataHandler.h"
#import "DWDCustBaseClient.h"

#import "DWDKeyChainTool.h"
#import "DWDRSAHandler.h"
#import <YYModel.h>

#import "DWDChatClient.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"
#import "DWDPickUpCenterDatabaseTool.h"

@implementation DWDLoginDataHandler
+ (void)requestGetPublicKeyWithPhoneNum:(NSString *)phoneNum
                               password:(NSString *)password
                                success:(void (^)(NSString *,NSString *))success
                                failure:(void (^)(NSError *error))failure{
    
    [DWDCustBaseClient requestGetPublicKeyWithPhoneNum:phoneNum
                                               success:^(NSString *publicKey) {
                                                   
                                                   //1、将公钥保存
                                                   BOOL isSave = [[DWDRSAHandler sharedHandler] savePublicKey:publicKey];
                                                   if (isSave){
                                                       //2、对密码、用户名进行加密 与 储存
                                                       
                                                       
                                                       NSString *pwd = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoString:password];
                                                       [DWDCustInfo shared].custEncryptPwd = pwd;
                                                       [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:kDWDEncryptPwdCache];
                                                       success(publicKey,pwd);
                                                   }
                                                   else{
                                                       NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: @"登录失败，请稍候重试"};
                                                       NSError *error = [NSError errorWithDomain:kDWDErrorDomain code:1 userInfo:userInfo];
                                                       failure(error);
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                  failure(error);
                                               }];
    
}


+ (void)requestLoginWithUserName:(NSString *)userName
                               password:(NSString *)password
                        encryptPassword:(NSString *)encryptPassword
                                success:(void (^)(void))success
                                failure:(void (^)(NSError *))failure{
    
    DWDCustBaseClient *client = [[DWDCustBaseClient alloc] init];
    [client requestLoginPraramUserName:userName
                       enctyptPassword:encryptPassword
                               success:^(NSDictionary *info){
                                   
                                   //缓存custId
                                   [DWDCustInfo shared].custId = info[@"custId"];
                                   [[NSUserDefaults standardUserDefaults] setObject:[DWDCustInfo shared].custId
                                                                             forKey:DWDLoginCustIdCache];
                                   //获取accessToken 与存储
                                   NSString *token =  info[@"accessToken"];
                                   [[DWDKeyChainTool sharedManager] writeKey:token
                                                                    WithType:KeyChainTypeToken];
                                   //获取refreshToken 与存储
                                   NSString *refreshToken =  info[@"refreshToken"];
                                   //refreshToken 加密 目前暂时不加密
//                                   NSData *refreshTokenData = [refreshToken ];
//                                   NSString *encryptRefreshToken = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:bData];
                                   [[DWDKeyChainTool sharedManager] writeKey:refreshToken
                                                                    WithType:KeyChainTypeRefreshToken];
                                   //token 加密
                                   NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
                                   NSString *encryptToken = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:tokenData];
                                   //缓存 加密token 与 uid
                                   NSDictionary *dictHeaderInfo = [NSDictionary dictionaryWithObjectsAndKeys:encryptToken, @"encryptToken", info[@"uid"],@"uid", nil];
                                   [[NSUserDefaults standardUserDefaults] setObject:dictHeaderInfo forKey:kDWDRequestHeaderInfoCache];
                                   
                                   //缓存登录帐号
                                   [DWDCustInfo shared].custUserName = userName;
                                   [[NSUserDefaults standardUserDefaults] setObject:userName
                                                                             forKey:DWDUserNameCache];
                                   
                                   //缓存密码
                                    [[NSUserDefaults standardUserDefaults] setObject:password
                                                                              forKey:kDWDOrignPwdCache];
                                   [DWDCustInfo shared].custMD5Pwd = [password md532BitLower];
                                   [[NSUserDefaults standardUserDefaults] setObject:[password md532BitLower]
                                                                             forKey:kDWDMD5PwdCache];
                                   
                                   //获取用户个人信息
                                   NSDictionary *userInfo = info[@"userInfo"];
                                   //赋值用户身份
                                   [DWDCustInfo shared].custIdentity = userInfo[@"custType"];
                                   
                                   //切换账号时 更改db本地路径
                                   [[DWDDataBaseHelper sharedManager] resetDB];
                                   // 先把数据表格建好
                                   [[DWDContactsDatabaseTool sharedContactsClient] reCreateTables];
                                   //往群组表增加isSave字段
                                   [[DWDContactsDatabaseTool sharedContactsClient] groupTableAddElement:@"isSave"];
                                  
                                   
                                   [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] reCreateTables];
                                   
                                   
                                   [DWDPickUpCenterDatabaseTool sharedManager];
                                   
                                   //获取联系人
                                   [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                                       //4. 发通知 刷新班级列表
                                       [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                                   } failure:^(NSError *error) {
                                       
                                   }];
                                   
                                   //发送通知、是否刷新 会话列表
                                   [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
                                   
                                   //建立链接
                                   [[DWDChatClient sharedDWDChatClient] reconnection];
                                   
                                   //存储用户信息
                                   NSMutableDictionary *dict = [userInfo mutableCopy];
                                   
                                   [[NSUserDefaults standardUserDefaults] setObject:dict forKey:DWDCustInfoData];
                                   //本地加载数据
                                   [[DWDCustInfo shared] loadUserInfoData];
                                   
                                   //callback
                                   success();
                               } failure:^(NSError *error) {
                                   failure(error);
                               }];
}



@end
