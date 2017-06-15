//
//  DWDRequestClassSetting.m
//  EduChat
//
//  Created by Bharal on 15/12/31.
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
                                     className:(NSString *)className
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:@{DWDCustId:custId,@"classId":classId,@"className":className} success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
                                    introduce:(NSString *)introduce
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:@{DWDCustId:custId,@"classId":classId,@"introduce":introduce} success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/updateEntity" params:@{DWDCustId:custId,@"classId":classId,@"isTop":isTop,@"isClose":isClose,@"isShowNick":isShowNick} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];
    
}
@end
