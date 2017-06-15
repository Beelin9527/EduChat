//
//  DWDRequestServerLocation.m
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDRequestLocation.h"
#import "DWDLocationEntity.h"

@implementation DWDRequestLocation

DWDSingletonM(DWDRequestServerLocation)

- (void)requestServerLocationgetListCustId:(NSNumber *)custId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    [[HttpClient sharedClient] getApi:@"LocationRestService/getList" params:@{DWDCustId:custId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *result = [DWDLocationEntity initWithArray: responseObject[DWDApiDataKey]];
        success(result);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        
    }];

}
@end
