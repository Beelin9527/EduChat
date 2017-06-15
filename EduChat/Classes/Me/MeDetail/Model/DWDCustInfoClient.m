//
//  DWDRequestServerMeDetail.m
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDCustInfoClient.h"

#import <YYModel.h>
@implementation DWDCustInfoClient

DWDSingletonM(CustInfoClient)

/** 修改昵称 */
- (void)requestUpdateWithNickname:(NSString *)nickname success:(void (^)(id responseObject))success
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    hud.labelText = nil;
    
    [[HttpClient sharedClient] postApi:@"AcctRestService/updateUserInfo" params:@{DWDCustId:[DWDCustInfo shared].custId, @"nickname":nickname} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
       
        [DWDCustInfo shared].custNickname = nickname;
        
        //获取缓存用户信息并修改nickname
        NSMutableDictionary *custInfoData = [[[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData] mutableCopy];
        [custInfoData setValue:nickname forKey:@"nickname"];
        [[NSUserDefaults standardUserDefaults] setObject:custInfoData forKey:DWDCustInfoData];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [hud showText:@"修改失败"];
        
    }];
 
}

/** 修改性别 */
- (void)requestUpdateWithGender:(NSNumber *)gender success:(void (^)(id responseObject))success
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
     hud.labelText = nil;
    
    [[HttpClient sharedClient]
     postApi:@"AcctRestService/updateUserInfo"
     params:@{DWDCustId:[DWDCustInfo shared].custId, @"gender":gender}
     success:^(NSURLSessionDataTask *task, id responseObject)
    {
        [hud hide:YES];
        
        [DWDCustInfo shared].custGender = [gender isEqualToNumber:@1] ? @"男" : @"女";

        //获取缓存用户信息并修改gender
        NSMutableDictionary *custInfoData = [[[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData] mutableCopy];
        [custInfoData setValue:gender forKey:@"gender"];
        [[NSUserDefaults standardUserDefaults] setObject:custInfoData forKey:DWDCustInfoData];
        success(responseObject[DWDApiDataKey]);
    }
     failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        [hud showText:@"修改失败"];
    }];
    
}

/** 修改头像 */
- (void)requestUpdateWithPhotoKey:(NSString *)photoKey success:(void (^)(id responseObject))success
{
    __block DWDProgressHUD *hud;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hud = [DWDProgressHUD showHUD];
        hud.labelText = nil;
    });
    
    [[HttpClient sharedClient] postApi:@"AcctRestService/updateUserInfo" params:@{DWDCustId:[DWDCustInfo shared].custId, @"photoKey":photoKey} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        //获取缩略图
        [DWDCustInfo shared].photoMetaModel = [DWDPhotoMetaModel yy_modelWithJSON:responseObject[DWDApiDataKey][@"photohead"]];
        
        [DWDCustInfo shared].custThumbPhotoKey = [[DWDCustInfo shared].photoMetaModel thumbPhotoKey];
        
        [DWDCustInfo shared].custOrignPhotoKey = [[DWDCustInfo shared].photoMetaModel originKey];
        
        //获取缓存用户信息并修改photoKey
        NSMutableDictionary *custInfoData = [[[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData] mutableCopy];
        [custInfoData setValue:responseObject[DWDApiDataKey][@"photohead"] forKey:@"photohead"];
        [[NSUserDefaults standardUserDefaults] setObject:custInfoData forKey:DWDCustInfoData];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [hud showText:@"修改失败"];
        
    }];
 
}

/** 修改个性签名 */
- (void)requestUpdateWithSignature:(NSString *)signature success:(void (^)(id responseObject))success
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    hud.labelText = nil;
    
    [[HttpClient sharedClient]
     postApi:@"AcctRestService/updateUserInfo"
     params:@{DWDCustId:[DWDCustInfo shared].custId, @"signature":signature}
     success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [hud hide:YES];
         
         [DWDCustInfo shared].custSignature = signature;
         
         //获取缓存用户信息并修改signature
         NSMutableDictionary *custInfoData = [[[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData] mutableCopy];
         [custInfoData setValue:signature forKey:@"signature"];
         [[NSUserDefaults standardUserDefaults] setObject:custInfoData forKey:DWDCustInfoData];
         success(responseObject[DWDApiDataKey]);
     }
     failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [hud showText:@"修改失败"];
     }];
 
}


/** 修改多维度号 */
- (void)requestUpdateWithEduchatAccount:(NSString *)educhatAccount success:(void (^)(id responseObject))success
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    hud.labelText = nil;
    
    [[HttpClient sharedClient]
     postApi:@"AcctRestService/updateUserInfo"
     params:@{DWDCustId:[DWDCustInfo shared].custId, @"educhatAccount":educhatAccount}
     success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [hud hide:YES];
         
         [DWDCustInfo shared].custEduchatAccount = educhatAccount;
         
         //获取缓存用户信息并修改educhatAccount
         NSMutableDictionary *custInfoData = [[[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData] mutableCopy];
         [custInfoData setValue:educhatAccount forKey:@"educhatAccount"];
         [[NSUserDefaults standardUserDefaults] setObject:custInfoData forKey:DWDCustInfoData];
         success(responseObject[DWDApiDataKey]);
     }
     failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [hud showText:@"修改失败"];
     }];
 
}

/** 修改地区 */
- (void)requestUpdateWithRegionName:(NSString *)regionName success:(void (^)(id responseObject))success
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    hud.labelText = nil;
    
    [[HttpClient sharedClient]
     postApi:@"AcctRestService/updateUserInfo"
     params:@{DWDCustId:[DWDCustInfo shared].custId, @"districtCode":regionName}
     success:^(NSURLSessionDataTask *task, id responseObject)
     {
         [hud hide:YES];
         
         [DWDCustInfo shared].custRegionName = responseObject[DWDApiDataKey][@"regionName"];
         
         //获取缓存用户信息并修改regionName
         NSMutableDictionary *custInfoData = [[[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData] mutableCopy];
         [custInfoData setValue:regionName forKey:@"regionName"];
         [[NSUserDefaults standardUserDefaults] setObject:custInfoData forKey:DWDCustInfoData];
         success(responseObject[DWDApiDataKey]);
     }
     failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [hud showText:@"修改失败"];
     }];
 
}
// get my class list
- (void)requestClassGetListCustId:(NSNumber *)custId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:custId forKey:DWDCustId];
    
    
    [[HttpClient sharedClient] getApi:@"ClassRestService/getList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedDescription;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];
}
@end
