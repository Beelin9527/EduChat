//
//  DWDCollectDataHandler.m
//  EduChat
//
//  Created by Gatlin on 16/8/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDCollectDataHandler.h"

#import "DWDCollectModel.h"
@implementation DWDCollectDataHandler
+ (void)requestCollectListWithCustId:(NSNumber *)custId
                                 idx:(NSNumber *)idx
                                 cnt:(NSNumber *)cnt
                             success:(void(^)(NSArray *, BOOL))success
                             failure:(void(^)(NSError *))failure
{
    if (!custId) return;
    if (!cnt) cnt = @10;
    
    NSDictionary *dict = @{
                           @"custId":custId,
                           @"idx": idx ? idx : @1,
                           @"cnt": cnt};
    [[HttpClient sharedClient]
     getApi:@"short/collect/list"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *data = responseObject[@"data"];
         NSMutableArray *dataSource = [NSMutableArray arrayWithCapacity:data.count];
         for (NSDictionary *dict in data) {
             DWDCollectModel *model = [DWDCollectModel yy_modelWithDictionary:dict];
             [dataSource addObject:model];
         }
         //判断是否还有数据
         if ([cnt integerValue] > dataSource.count) {
             success(dataSource, NO);
         }else{
             success(dataSource, YES);
         }
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error);
     }];
}

+ (void)requestDeleteCollectWithCustId:(NSNumber *)custId
                             collectId:(NSArray *)collectId
                               success:(void(^)(NSNumber *))success
                               failure:(void(^)(NSError *))failure
{
    if (!custId || !collectId) return;
    
    NSDictionary *dict = @{
                           @"custId":custId,
                           @"collectId": collectId,
                         };
    [[HttpClient sharedClient]
    postApi:@"short/collect/del"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSNumber *collectId = responseObject[@"data"][@"collectId"];
         success(collectId);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error);
     }];
 
}
@end
