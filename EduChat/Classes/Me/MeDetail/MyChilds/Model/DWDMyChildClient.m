//
//  DWDMyChildClient.m
//  EduChat
//
//  Created by Gatlin on 16/3/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyChildClient.h"
#import "HttpClient.h"
@implementation DWDMyChildClient
+(instancetype)sharedMyChildClient
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

- (void)requestGetMyChildrenListWithCustId:(NSNumber *)custId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
{
    [[HttpClient sharedClient]
     getApi:@"AcctRestService/getMyChildrenList"
     params:@{DWDCustId:custId}
     success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        
    }];
    
}


- (void)requestGetMyChildrenNameListWithCustId:(NSNumber *)custId
                                       classId:(NSNumber *)classId
                                       success:(void (^)(id))success
                                       failure:(void (^)(NSError *))failure
{
    [[HttpClient sharedClient]
     getApi:@"AcctRestService/getMyChildrenList"
     params:@{DWDCustId:custId,@"classId":classId}
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         success(responseObject[DWDApiDataKey]);
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         failure(error);
         
     }];
}

- (void)requestGetMyChildInfoWithCustId:(NSNumber *)custId
                            childCustId:(NSNumber *)childCustId
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSError *error))failure
{
    if (!childCustId){
        failure(nil);
    }
    [[HttpClient sharedClient] getApi:@"AcctRestService/getMyChildInfo"
                               params:@{DWDCustId:custId,@"childCustId":childCustId}
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  success(responseObject[DWDApiDataKey]);
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  failure(error);
                              }];
}

- (void)requestUpdateMyChildInfoWithCustId:(NSNumber *)custId
                               childCustId:(NSNumber *)childCustId
                                 childName:(NSString *)childName
                               childGender:(NSNumber *)childGender
                             childPhotoKey:(NSString *)childPhotoKey
                                   success:(void (^)(id responseObject))success
                                   failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:custId forKey:DWDCustId];
    [params setObject:childCustId forKey:@"childCustId"];
    if (childName) {
        [params setObject:childName forKey:@"childName"];
    }
    if (childGender) {
        [params setObject:childGender forKey:@"childGender"];
    }
    if (childPhotoKey) {
         [params setObject:childPhotoKey forKey:@"childPhotoKey"];
    }
    
    [[HttpClient sharedClient]
     postApi:@"AcctRestService/updateMyChildInfo"
     params:params
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         
         success(responseObject[DWDApiDataKey]);
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         
         failure(error);
         
     }];
}
@end
