//
//  DWDInformationClient.m
//  EduChat
//
//  Created by apple on 12/21/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDInformationClient.h"
#import "HttpClient.h"

@implementation DWDInformationClient

- (void)fetchInformationByDistrictCode:(NSString *)code
                                  page:(NSNumber *)page
                             pageCount:(NSNumber *)count
                               success:(void(^)(NSArray *headers, NSArray *infos, BOOL hasNextPage))success
                               failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"EduInformationRestService/getList"
                               params:@{@"districtCode":code, @"pageIndex":page, @"pageCount":count}
     
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  NSArray *headers = responseObject[@"data"][@"advertCarousels"];
                                  NSArray *infos = responseObject[@"data"][@"infos"];
                                  NSNumber *dataCount = responseObject[@"data"][@"count"];
                                  
                                  BOOL hasNextPage = [page intValue] * [count intValue] < [dataCount intValue];
                                  
                                  success(headers, infos, hasNextPage);
                              }
     
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  failure(error);
                              }];
}


- (void)fetchInformationCommentsByInfoId:(NSNumber *)infoId
                                    page:(NSNumber *)page
                               pageCount:(NSNumber *)count
                                 success:(void(^)(NSArray *comments, BOOL hasNextPage))success
                                 failure:(void(^)(NSError *error))failure {
    
    [[HttpClient sharedClient] getApi:@"EduInformationRestService/getCommentList"
                               params:@{@"infoId":infoId, @"pageIndex":page, @"pageCount":count}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  NSNumber *dataCount = responseObject[@"data"][@"count"];
                                  BOOL hasNextPage = [page intValue] * [count intValue] < [dataCount intValue];
                                  success(responseObject[@"data"][@"comments"], hasNextPage);
                              }
                              failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  failure(error);
                              }];
}

- (void)postCommentForInfo:(NSNumber *)infoId
                        by:(NSNumber *)custId
                       for:(NSNumber *)forCustId
                   comment:(NSString *)comment
                   success:(void(^)())success
                   failure:(void(^)(NSError *error))failure {
    
    NSDictionary *params;
    if (forCustId) {
        params = @{@"infoId":infoId, @"custId":custId, @"forCustId":forCustId, @"commentTxt":comment};
    } else {
        params = @{@"infoId":infoId, @"custId":custId, @"commentTxt":comment};
    }
    
    [[HttpClient sharedClient] postApi:@"EduInformationRestService/addComment"
                                params:params
     
                               success:^(NSURLSessionDataTask *task, id responseObject) {
        
                                   success();
                               }
     
                               failure:^(NSURLSessionDataTask *task, NSError *error) {
        
                                   failure(error);
                               }];
    
}

- (void)postPraiseForInfo:(NSNumber *)infoId
                       by:(NSNumber *)custId
                  success:(void(^)())success
                  failure:(void(^)(NSError *error))failure {
    [[HttpClient sharedClient] postApi:@"EduInformationRestService/addPraise"
                                params:@{@"infoId":infoId, @"custId":custId}
     
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
                                   success();
                               }
     
                               failure:^(NSURLSessionDataTask *task, NSError *error) {
        
                                   failure(error);
                               }];
}


@end
