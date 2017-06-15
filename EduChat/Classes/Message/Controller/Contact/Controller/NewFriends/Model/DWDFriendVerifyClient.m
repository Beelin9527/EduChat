//
//  DWDFriendVerifyClient.m
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDFriendVerifyClient.h"
#import "HttpClient.h"

@implementation DWDFriendVerifyClient

DWDSingletonM(FriendVerifyClient)

- (void)postAddressBookAndGetFriendList:(NSNumber *)custId addressBook:(NSMutableDictionary *)dict
                    success:(void(^)(NSArray *invites))success
                    failure:(void(^)(NSError *error))failure {
    [dict setObject:custId forKey:DWDCustId];
    [[HttpClient sharedClient] postApi:@"AddressBookRestService/getAddressBuddyList"
                               params:dict
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  success(responseObject[@"data"]);
                                  
                              }
     
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  
                                  failure(error);
                                  
                              }];
}

- (void)getFriendInviteList:(NSNumber *)custId
                    success:(void(^)(NSMutableArray *invites))success
                    failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"FriendVerifyRestService/getList2"
                               params:@{DWDCustId:custId, @"source":@0}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  NSMutableArray *mutarray = [NSMutableArray arrayWithArray:responseObject[@"data"]];
                                  success(mutarray);
                                  
                              }
     
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  
                                  failure(error);
                                  
                              }];
}

- (void)sendFriendVerify:(NSNumber *)custId
                friendId:(NSNumber *)friendId
              verifyInfo:(NSString *)verifyInfo
                  source:(NSNumber *)source
                 success:(void(^)(NSArray *invites))success
                 failure:(void(^)(NSError *error))failure {
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[HttpClient sharedClient] postApi:@"FriendVerifyRestService/addEntity2"
                                params:@{DWDCustId:custId, DWDFriendId:friendId,@"verifyInfo":verifyInfo, @"source":source}
     
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                    [hud showText:@"发送成功" afterDelay:DefaultTime];
                                   success(responseObject[DWDApiDataKey]);
                               }
     
                               failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                                   [hud showText:@"发送失败" afterDelay:DefaultTime];
                                   failure(error);
                                   
                               }];
}

- (void)updateFirendVerifyState:(NSNumber *)custId
                       friendId:(NSNumber *)friendId
                          state:(NSNumber *)state
                        success:(void(^)(NSArray *info))success
                        failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] postApi:@"FriendVerifyRestService/updateState"
                                params:@{DWDCustId:custId, @"friendCustId":friendId, @"state":state}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   success(responseObject[DWDApiDataKey]);
                               }
     
                               failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                                   failure(error);
                               }];
}

-(void)requestGetVerifyInfos:(NSNumber *)custId friendId:(NSNumber*)friendId success:(void (^)(NSArray *info))success failure:(void (^)(NSError *error))failure
{
    [[HttpClient sharedClient] getApi:@"FriendVerifyRestService/getVerifyInfos"
                               params:@{DWDCustId:custId,DWDFriendId:friendId}
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  success(responseObject[DWDApiDataKey]);
                                  
                              }
     
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  
                                  failure(error);
                                  
                              }];

}

-(void)requestAddVerifyInfos:(NSNumber *)custId friendId:(NSNumber *)friendId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[HttpClient sharedClient] postApi:@"FriendVerifyRestService/addVerifyInfos"
                               params:@{DWDCustId:custId,DWDFriendId:friendId}
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  success(responseObject[DWDApiDataKey]);
                                  
                              }
     
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  
                                  failure(error);
                                  
                              }];
    

}
@end
