//
//  DWDRequestServerClassNotification.m
//  EduChat
//
//  Created by Gatlin on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDRequestServerClassNotification.h"
#import "DWDClassNotificatoinListEntity.h"
@implementation DWDRequestServerClassNotification

DWDSingletonM(DWDRequestServerClassNotification);

- (void)requestServerClassGetListCustId:(NSNumber *)custId
                                classId:(NSNumber *)classId
                                   type:(NSNumber *)type
                              pageIndex:(NSNumber *)pageIndex
                              pageCount:(NSNumber *)pageCount
                                success:(void (^)(id))success
                                failure:(void (^)(NSError *))failure
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] getApi:@"NoticeRestService/getList" params:@{DWDCustId:custId,@"classId":classId,@"pageIndex":pageIndex,@"pageCount":pageCount} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        NSArray *arr = responseObject[DWDApiDataKey][@"notices"];
        NSArray *arrResult = [DWDClassNotificatoinListEntity initWithArray:arr];
        
        success(arrResult);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}



/*
 data =     {
    author = {
        addtime = "2015-12-28 20:09:14";
        authorId = 4010000005409;
        name = "";
        photokey = "";
    };
    notice = {
        content = "";
        title = "";
        type = 2;
    };
    replys = {
        joins =             (
        );
    };
 };
*/
- (void)requestServerClassGetEntityCustId:(NSNumber *)custId
                                  classId:(NSNumber *)classId
                                 noticeId:(NSNumber *)noticeId
                                  success:(void (^)(id))success
                                  failure:(void (^)(NSError *))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] getApi:@"NoticeRestService/getEntity" params:@{DWDCustId:custId,@"classId":classId,@"noticeId":noticeId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];
}


- (void)requestServerClassDeleteEntityCustId:(NSNumber *)custId
                                     classId:(NSNumber *)classId
                                    noticeId:(NSArray *)noticeId
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] postApi:@"NoticeRestService/deleteEntity" params:@{DWDCustId:custId,@"classId":classId,@"noticeId":noticeId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}


- (void)requestServerClassAddEntityDictParams:(NSMutableDictionary *)dictParams
                                  success:(void (^)(id responseObject))success
                                  failure:(void (^)(NSError *error))failure
{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    hud.labelText = NSLocalizedString(@"loading", nil);
//    hud.labelColor = [UIColor whiteColor];

    [[HttpClient sharedClient] postApi:@"NoticeRestService/addEntity" params:dictParams success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
//        hud.labelText = error.localizedFailureReason;
//        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];
    
}


- (void)requestServerClassReplyNoticeCustId:(NSNumber *)custId
                                    classId:(NSNumber *)classId
                                   noticeId:(NSNumber *)noticeId
                                       item:(NSNumber *)item
                                    success:(void (^)(id responseObject))success
                                    failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    if (!item) item = @2;//default 2
    
    [[HttpClient sharedClient] postApi:@"NoticeRestService/replyNotice" params:@{DWDCustId:custId,@"classId":classId,@"noticeId":noticeId,@"item":item} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}
@end
