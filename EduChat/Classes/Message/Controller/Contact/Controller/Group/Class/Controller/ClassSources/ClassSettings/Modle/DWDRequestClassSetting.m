//
//  DWDRequestClassSetting.m
//  EduChat
//
//  Created by Gatlin on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDRequestClassSetting.h"


@implementation DWDRequestClassSetting

DWDSingletonM(DWDRequestClassSetting);

- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] getApi:@"ClassRestService/getClassInfo" params:@{DWDCustId:custId,@"classId":classId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}

- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                     nickname:(NSString *)nickname
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:@{DWDCustId:custId,@"classId":classId,@"nickname":nickname} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];
    
}

/** 更改班级头像 */
- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                     photoKey:(NSString *)photoKey
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
   
    __block DWDProgressHUD *hud;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hud = [DWDProgressHUD showHUD];
        hud.labelText = @"正在上传";
    });
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:@{DWDCustId:custId,@"classId":classId,@"photoKey":photoKey} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud showText:@"上传失败，请稍候重试"];
        });
        
        failure(error);
        
    }];
    
}

- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                    introduce:(NSString *)introduce
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:@{DWDCustId:custId,@"classId":classId,@"introduce":introduce ? introduce : [NSNull null]} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];
    
}

- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                        isTop:(NSNumber *)isTop
                                      isClose:(NSNumber *)isClose
                                   isShowNick:(NSNumber *)isShowNick
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params setObject:custId forKey:DWDCustId];
    [params setObject:classId forKey:@"classId"];
    if (isTop) {
        [params setObject:isTop forKey:@"isTop"];
    }
    if (isClose) {
         [params setObject:isClose forKey:@"isClose"];
    }
    if (isShowNick) {
        [params setObject:isShowNick forKey:@"isShowNick"];
    }
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        
    }];
    
}
@end
