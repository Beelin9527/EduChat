//
//  DWDHomeWorkClient.m
//  EduChat
//
//  Created by apple on 12/28/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDHomeWorkClient.h"
#import "HttpClient.h"

@implementation DWDHomeWorkClient

- (void)fetchHomeWorksBy:(NSNumber *)custId
                classId:(NSNumber *)classId
                   type:(NSNumber *)type
                   page:(NSNumber *)page
              pageCount:(NSNumber *)count
                success:(void(^)(NSArray *homeWorks, BOOL hasNextPage))success
                failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"HomeworkRestService/getList"
                               params:@{@"custId":custId, @"classId":classId, @"type":type, @"page":page, @"pageCount":count}
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  NSNumber *dataCount = responseObject[@"data"][@"count"];
                                  BOOL hasNextPage = [page intValue] * [count intValue] < [dataCount intValue];
                                  success(responseObject[@"data"][@"homeworks"], hasNextPage);

    
                              }
     
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
        
                              }];
}

- (void)postHomeWorkBy:(NSNumber *)custId
               calssId:(NSNumber *)classId
                 title:(NSString *)title
               content:(NSString *)content
               subject:(NSNumber *)subject
              deadline:(NSString *)deadline
              attachmentType:(NSNumber *)type
       attachmentPaths:(NSString *)paths
                  from:(NSNumber *)from
               success:(void(^)())success
               failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] postApi:@"HomeworkRestService/addEntity"
                                params:@{@"custId":custId, @"classId":classId,
                                         @"title":title, @"content":content,
                                         @"subject":subject, @"collectTime":deadline,
                                         @"filetype":type, @"homeworkKey":paths,
                                         @"fromHomework":from}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   success();
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
                                   failure(error);
                               }];
}


- (void)deleteHomeWorkBy:(NSNumber *)custId
                 classId:(NSNumber *)classId
             homeWorkIds:(NSArray *)deleteIds
                 success:(void(^)())success
                 failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] postApi:@"HomeworkRestService/deleteEntity"
                                params:@{@"custId":custId, @"classId":classId, @"homeworkId":deleteIds}
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   success();
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   failure(error);
                               }];
}

- (void)fetchHomeWorkBy:(NSNumber *)custId
                classId:(NSNumber *)classId
            homeWorkId:(NSNumber *)homeWorkId
                success:(void(^)(NSDictionary *homeWork))success
                failure:(void(^)(NSError *error))failure {
    [[HttpClient sharedClient] getApi:@"HomeworkRestService/getEntity"
                               params:@{@"custId":custId, @"classId":classId, @"homeworkId":homeWorkId}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  success(responseObject[@"data"]);
                                  
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  failure(error);
                              }];
}

@end
