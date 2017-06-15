//
//  DWDClassInnerGroupClient.m
//  EduChat
//
//  Created by apple on 12/31/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDClassInnerGroupClient.h"
#import "HttpClient.h"

@implementation DWDClassInnerGroupClient

- (void)postClassInnerGroupBy:(NSNumber *)custId
                      classId:(NSNumber *)classId
                      groupName:(NSString *)groupName
                     contacts:(NSArray *)contacts
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] postApi:@"ClassGroupRestService/addEntity"
                                params:@{@"custId":custId, @"classId":classId, @"groupName":groupName, @"friendCustIds":contacts}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
        
                                   success();
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
                                   failure(error);
                                   
                               }];
}

- (void)fetchClassInnerGroupBy:(NSNumber *)custId
                       classId:(NSNumber *)classId
                       success:(void(^)(NSArray *innerGroups))success
                       failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"ClassGroupRestService/getList"
    
                               params:@{@"custId":custId, @"classId":classId}
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  success(responseObject[@"data"]);
                                  
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  
                                  failure(error);
                                  
                              }];
}

- (void)deleteClassInnerGroupBy:(NSNumber *)custId
                        classId:(NSNumber *)classId
                        groupId:(NSNumber *)groupId
                        success:(void(^)())success
                        failure:(void(^)(NSError *error))failure {
    [[HttpClient sharedClient] postApi:@"ClassGroupRestService/deleteEntity"
                                params:@{@"custId":custId, @"classId":classId, @"groupId":groupId}
     
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   success();
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   failure(error);
                               }];
}

- (void)fetchClassInnerGroupMembersBy:(NSNumber *)custId
                              classId:(NSNumber *)classId
                              groupId:(NSNumber *)groupId
                              success:(void(^)(NSArray *members))success
                              failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"ClassGroupMemberRestService/getList"
                               params:@{@"custId":custId, @"classId":classId, @"groupId":groupId}
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  success(responseObject[@"data"]);
   
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
                                  failure(error);
                                  
                              }];
}

- (void)addMembersToClassInnerGroup:(NSNumber *)group
                           classId:(NSNumber *)classId
                            byUser:(NSNumber *)custId
                       addContacts:(NSArray *)contacts
                           success:(void(^)())success
                           failure:(void(^)(NSError *error))failure {
    [[HttpClient sharedClient] postApi:@"ClassGroupMemberRestService/addEntity"
                                params:@{@"custId":custId, @"classId":classId, @"groupId":group, @"friendCustIds": contacts}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
        
                                   success();
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
                                   failure(error);
                               }];
}

- (void)deleteMembersToClassInnerGroup:(NSNumber *)group
                               classId:(NSNumber *)classId
                                byUser:(NSNumber *)custId
                           addContacts:(NSArray *)contacts
                               success:(void(^)())success
                               failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] postApi:@"ClassGroupMemberRestService/deleteEntity"
                                params:@{@"custId":custId, @"classId":classId, @"groupId":group, @"friendCustIds": contacts}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   success();
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                                   failure(error);
                               }];
}

@end
