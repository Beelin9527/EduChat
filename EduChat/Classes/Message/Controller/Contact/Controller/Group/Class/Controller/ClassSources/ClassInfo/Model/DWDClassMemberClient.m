//
//  DWDClassMemberClient.m
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassMemberClient.h"
#import "HttpClient.h"

#import "DWDClassDataBaseTool.h"
#define lastRequest @"lastRequest"
@implementation DWDClassMemberClient
+(instancetype)sharedClassMemberClient
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

- (void)requestClassMemberGetListWithClassId:(NSNumber *)classId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    //是否缓存时间
    NSString *lastUpdateKey = [NSString stringWithFormat:@"%@-%@-%@", lastRequest, classId,[DWDCustInfo shared].custId];
    
    NSString *lastModifyDate =
    [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdateKey];
    
    if (!lastModifyDate) lastModifyDate = @"0";
    [[HttpClient sharedClient]
     getApi:@"ClassMemberRestService/getList"
     params:@{@"classId":classId, @"date":lastModifyDate}
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         if ([responseObject[@"data"][@"custInfo"] count] == 0)
         {
             success(nil);
             return;
         }
         else
         {
             
             [[DWDClassDataBaseTool sharedClassDataBase]
              insertClassMember:responseObject
              classId:classId myCustId:[DWDCustInfo shared].custId
              updateSuccess:^{
                 
                  //获取班级成员总人数
                  [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberCountWithClassId:classId success:^(NSUInteger memberCount) {
                      
                      //将人数更新到本地库班级信息
                      [[DWDClassDataBaseTool sharedClassDataBase] updateClassInfoWithMemberCount:@(memberCount) classId:classId];
                      
                      //发送通知、更新班级列表
                      [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                      
                        success(nil);
                  } failure:^{
                     failure(nil);
                  }];
              }
              updateFailure:^{
                  failure(nil);
              }];
             
         }
         
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(nil);
     }];

}
@end
