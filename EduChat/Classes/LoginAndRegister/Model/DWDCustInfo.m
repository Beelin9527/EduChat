//
//  DWDUser.m
//  EduChat
//
//  Created by Gatlin on 15/12/7.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDCustInfo.h"

#import "DWDPhotoMetaModel.h"

#import "DWDDatabaseDeleteTool.h"

#import <FMDB.h>
#import <YYModel.h>

@implementation DWDCustInfo
+(instancetype)shared
{
    static DWDCustInfo *cust = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cust = [[DWDCustInfo alloc]init];
        [cust setValue:@1000 forKey:@"systemCustId"];
    });
    return cust;
}


- (BOOL)isLogin
{
    self.custId = [[NSUserDefaults standardUserDefaults] objectForKey:DWDLoginCustIdCache];
    
    return self.custId ? YES : NO;
}

- (BOOL)isTeacher
{
    //判断是否为老师身份
    if ([self.custIdentity isEqualToNumber:@4]) {
         return YES;
    }else{
        return NO;
    }
}
//加载
- (void)loadUserInfoData
{
    //从缓存获取custId
   self.custId = [[NSUserDefaults standardUserDefaults] objectForKey:DWDLoginCustIdCache];
    
    //从缓存登录帐号 与 密码
    self.custMD5Pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kDWDMD5PwdCache];
    self.custUserName = [[NSUserDefaults standardUserDefaults] objectForKey:DWDUserNameCache];

    self.custEncryptPwd = [[NSUserDefaults standardUserDefaults] objectForKey:kDWDEncryptPwdCache];

    
    //获取用户信息
   NSDictionary *custInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:DWDCustInfoData];
    
    [self parse:custInfoData];
}

//清除数据
- (void)clearUserInfoData
{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDCustInfoData];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDLoginCustIdCache];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kDWDMD5PwdCache];
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kDWDEncryptPwdCache];
    
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kDWDRequestHeaderInfoCache];
    
    self.custId = nil;
    
    //加入班级，缓存家长的第一个孩子的信息，退出清除
    NSString *childInfoCache = [NSString stringWithFormat:@"childInfo-%@",[DWDCustInfo shared].custId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:childInfoCache];
    
}

//解析数据
- (void)parse:(id)responseObject {
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DWDDatabasePath];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdateWithFormat:@"UPDATE tb_contacts SET myCustId = %@ WHERE custId = %@",[DWDCustInfo shared].custId, [DWDCustInfo shared].systemCustId];
        success = [db executeUpdateWithFormat:@"UPDATE tb_contacts SET myCustId = %@ WHERE custId = %@",[DWDCustInfo shared].custId, @1001];
        if (success) {
            DWDMarkLog(@"YES!success");
        }
    }];
    [queue close];

    self.custName = responseObject[@"name"];
    self.custNickname = responseObject[@"nickname"];
    self.custMobile = responseObject[@"mobile"];
    
    self.photoMetaModel = [DWDPhotoMetaModel yy_modelWithDictionary: responseObject[@"photohead"]];
    self.custThumbPhotoKey = self.photoMetaModel.thumbPhotoKey;
    self.custOrignPhotoKey = responseObject[@"photoKey"];
    
    self.custBirthday = responseObject[@"birthday"];
    self.custIdentity = responseObject[@"custType"];
    
    self.custEduchatAccount = [self colationNullString:responseObject[@"educhatAccount"]];
    self.custRegionName = [self colationNullString:responseObject[@"regionName"]];
     self.custSignature = [self colationNullString:responseObject[@"signature"]];
    self.custMyChildName = [self colationNullString:responseObject[@"myChildName"]];
    
    if([responseObject[@"gender"] isEqual: @0]){//接口返回是数据类型
        self.custGender = @"未设置";
    }else if([responseObject[@"gender"] isEqual: @1]){
        self.custGender = @"男";
    }else{
        self.custGender = @"女";
    }
    
    //删除数据库冗余的聊天记录的<时间>类型 行
//    [DWDDatabaseDeleteTool deleteChatRecordTimeRows]; 
}

/** 过滤空字符 返回nil */
- (NSString *)colationNullString:(NSString *)string
{
    if (!string || [string isEqualToString:@""]) {
        return nil;
    }else{
        return string;
    }
}

/*
 friendCustId | √ | long | 要查询的好友id
 custId | | long | 用户id
 extensions | | String | 返回信息说明.
 | | | 默认值：base，返回基本信息
 | | | 取值：all，返回所有信息 -----------------------------------------------------
 结果数据
 */
- (void)requestUserInfoExWithCustId:(NSNumber *)custId success:(void(^)(void))succes failure:(void(^)(void))failure
{
    [[HttpClient sharedClient] getApi:@"AcctRestService/getUserInfoEx" params:@{DWDCustId:custId,DWDFriendId:custId,@"extensions":@"base"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
       // [self parse:responseObject[DWDApiDataKey]];
        
        NSMutableDictionary *dict = [responseObject[DWDApiDataKey] mutableCopy];
       
        //存储用户信息
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:DWDCustInfoData];
        succes();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure();
    }];
}
@end
