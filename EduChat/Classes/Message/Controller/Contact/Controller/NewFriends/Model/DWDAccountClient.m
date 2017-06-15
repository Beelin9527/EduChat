//
//  DWDAccountClient.m
//  EduChat
//
//  Created by apple on 12/10/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAccountClient.h"
#import "HttpClient.h"

@implementation DWDAccountClient

DWDSingletonM(AccountClient)

- (void)getCustomUserInfo:(NSNumber *)custId
                 friendId:(NSNumber *)friendId
                  success:(void(^)(NSDictionary *info))success
                  failure:(void(^)(NSError *error))failure{
    
    [[HttpClient sharedClient] getApi:@"AcctRestService/getCustomUserInfo" params:@{DWDCustId:custId, DWDFriendId:friendId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject[DWDApiDataKey]);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        
    }];
    
}

- (void)getUserInfo:(NSNumber *)custId
          accountNo:(NSString *)accountNo
            success:(void(^)(NSDictionary *info))success
            failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"AcctRestService/getUserInfo" params:@{DWDCustId:custId, DWDAccountNo:accountNo} success:^(NSURLSessionDataTask *task, id responseObject) {

        success(responseObject[DWDApiDataKey]);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
    }];

}


-(void)getUserInfoEx:(NSNumber *)custId
            friendId:(NSNumber *)friendId
          extensions:(NSString *)extensions
             success:(void (^)(NSDictionary *))success
             failure:(void (^)(NSError *))failure
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    [[HttpClient sharedClient] getApi:@"AcctRestService/getUserInfoEx" params:@{DWDCustId:custId,DWDFriendId:friendId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
         failure(error);
    }];
}


- (void)requestGetEduChatAccount:(NSString *)account success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
{
    
    [[HttpClient sharedClient] getApi:@"AcctRestService/getEduChatAccount" params:@{@"account":account} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //成功表示可以设置
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        //失败表示存在了，不可以设置
        failure(error);
    }];

}

- (void)updateCustomUserInfo:(NSNumber *)custId
                    friendId:(NSNumber *)friendId
                    friendRemarkName:(NSString *)friendRemarkName
                   lookPhoto:(NSNumber *)lookPhoto
                   blackList:(NSNumber *)blackList
                     success:(void(^)(NSDictionary *info))success
                     failure:(void(^)(NSError *error))failure {
    
    NSMutableDictionary *dictParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:custId,DWDCustId,friendId,DWDFriendId, nil];
  
    if (friendRemarkName) {
        [dictParams setObject:friendRemarkName forKey:@"friendRemarkName"];
    }
    if (lookPhoto) {
        [dictParams setObject:lookPhoto forKey:@"lookPhoto"];
    }
    if (blackList) {
        [dictParams setObject:blackList forKey:@"blackList"];
    }
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[HttpClient sharedClient] postApi:@"AcctRestService/updateCustomUserInfo" params:dictParams success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"修改成功" afterDelay:DefaultTime];
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud showText:@"修改失败" afterDelay:DefaultTime];
        failure(error);
    }];

}

- (void)updateUserInfo:(NSNumber *)custId
              nickname:(NSString *)nickname
             education:(NSNumber *)education
              property:(NSNumber *)property
          enterpriseId:(NSNumber *)enterpriseId
              photokey:(NSString *)photokey
             signature:(NSString *)signature
               success:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] postApi:@"AcctRestService/updateUserInfo"
     
                            params:@{DWDCustId:custId, DWDNickname:nickname,
                                     DWDProperty:property, DWDEnterpriseId:enterpriseId,
                                     DWDPhotoKey:photokey, DWDSignature:signature}
     
                           success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

}

@end
