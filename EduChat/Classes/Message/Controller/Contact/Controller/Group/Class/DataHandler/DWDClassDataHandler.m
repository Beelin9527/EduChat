//
//  DWDClassDataHandler.m
//  EduChat
//
//  Created by apple on 16/6/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassDataHandler.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDNoteChatMsg.h"
#import "DWDDistrictModel.h"
#import "DWDNearbySchoolModel.h"
#import "DWDNearBySelectedSchoolClassModel.h"

#import <YYModel.h>


@implementation DWDClassDataHandler


#pragma mark - 创建班级

+ (void)createClassWithSchoolId:(NSNumber *)schoolId className:(NSString *)className introduce:(NSString *)introduce standardId:(NSNumber *)standardId success:(void (^)(DWDClassModel *))success failure:(void (^)(NSError *))failure
{
     if (!schoolId || [schoolId isEqualToNumber:@0]) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"正在创建班级,请稍候...";
    [hud show:YES];
    
    NSDictionary *params;
    if (standardId) {
        params = @{@"custId" : [DWDCustInfo shared].custId,
                   @"schoolId" : schoolId,
                   @"introduce" : introduce,
                   @"standardId" : standardId};
    }else{
        params = @{@"custId" : [DWDCustInfo shared].custId,
                   @"schoolId" : schoolId ,
                   @"className" : className,
                   @"introduce" : introduce};
    }
    
    [[HttpClient sharedClient] postApi:@"ClassRestService/addGradeClass" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DWDLog(@"创建班级成功的返回值 : %@" , responseObject[@"data"]);
        hud.labelText = @"创建班级成功!";
        [hud hide:YES afterDelay:1.0];
        
        // 先增量更新
        [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
            
             // 构造模型
             NSString *lastContent = @"你已成功创建该班级";
             DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:responseObject[@"data"][@"classId"] chatType:DWDChatTypeClass];
             
             // 保存历史消息
             [self saveSystemMessage:noteChatMsg];
             
             // 根据 ClassId 从本地库获取班级信息
             DWDClassModel *model = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:responseObject[@"data"][@"classId"] myCustId:[DWDCustInfo shared].custId];
            
             if (success) {
                 success(model);
             }
             
         } failure:^(NSError *error) {
             
             //增量刷新失败，手动插入班级
             DWDClassModel *classModel = [DWDClassModel yy_modelWithJSON: responseObject[@"data"]];
             
             //插入班级本地库
             [[DWDClassDataBaseTool sharedClassDataBase]
              insertClassWithClassModel:classModel
              insertSuccess:^{
                  
                  //.构造模型
                  NSString *lastContent = @"你已成功创建该班级";
                  DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:responseObject[@"data"][@"classId"] chatType:DWDChatTypeClass];
                  
                  //2.保存历史消息
                  [self saveSystemMessage:noteChatMsg];
                  
                  //3. 发通知 刷新班级列表
                  [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                  
                  //根据ClassId 从本地库获取班级信息
                  DWDClassModel *model = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:responseObject[@"data"][@"classId"] myCustId:[DWDCustInfo shared].custId];
                  
                  if (success) {
                      success(model);
                  }
                  
              } insertFailure:^{
                  
              }];
         }];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = [error localizedFailureReason];
        [hud hide:YES afterDelay:2.0];
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)createSchoolWithFullName:(NSString *)fullName type:(NSNumber *)type districtCode:(NSString *)districtCode success:(void (^)(NSNumber *))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"type" : type,
                             @"fullName" : fullName,
                             @"districtCode" : districtCode};
    
    [[HttpClient sharedClient] postApi:@"EnterpriseRestService/addEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSNumber *schoolId = responseObject[@"data"][@"custId"];
        if (success) {
            success(schoolId);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 获取区域数据

+ (void)getDistrictWithDistrictCode:(NSString *)districtCode subdistrict:(NSNumber *)subdistrict success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = @{@"districtCode" : districtCode,
                             @"subdistrict" : subdistrict};
    
    [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arr = responseObject[DWDApiDataKey][@"districtList"];
        
        NSMutableArray *districts = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < arr.count; i++) {
            DWDDistrictModel *district = [DWDDistrictModel yy_modelWithJSON:arr[i]];
            [districts addObject:district];
        }
        if (success) {
            success(districts);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"%@",error);
        if (failure) {
            failure(error);
        }
    }];

}

+ (void)getAroundSchoolWithDistrictCode:(NSString *)districtCode type:(NSNumber *)type fuzzyName:(NSString *)fuzzyName success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure
{
    NSString *code = districtCode != nil ? districtCode : @"000000";
    NSDictionary *params = @{@"districtCode" : code,
                             @"type" : type,
                             @"fuzzyName" : fuzzyName};
    
    [[HttpClient sharedClient] getApi:@"EnterpriseRestService/getList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *arr = responseObject[@"data"][@"enterprises"];
        
        NSMutableArray *nearbySchools = [NSMutableArray arrayWithCapacity:64];
        for (int i = 0; i < arr.count; i++) {
            DWDNearbySchoolModel *schoolModel = [DWDNearbySchoolModel yy_modelWithJSON:arr[i]];
            [nearbySchools addObject:schoolModel];
        }
        if (success) {
            success(nearbySchools);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getClassListWithSchoolId:(NSNumber *)schoolId fuzzyName:(NSString *)fuzzyName success:(void (^)(NSMutableArray *))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = @{@"schoolId" : schoolId,
                             @"fuzzyName" : fuzzyName};
    
    [[HttpClient sharedClient] getApi:@"ClassRestService/getClassNameList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *classes = responseObject[@"data"];
        
        NSMutableArray *schoolClasses = [NSMutableArray arrayWithCapacity:64];
        for (int i = 0; i < classes.count; i++) {
            DWDNearBySelectedSchoolClassModel *selectedSchoolClassModel = [DWDNearBySelectedSchoolClassModel yy_modelWithJSON:classes[i]];
            [schoolClasses addObject:selectedSchoolClassModel];
        }
        if (success) {
            success(schoolClasses);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
        if (failure) {
            failure(error);
        }
    }];

}

/** 构造 系统消息 谁加入、移除班级 */
+ (DWDNoteChatMsg *)createNoteMsgWithString:(NSString *)str toUserId:(NSNumber *)toUserId chatType:(DWDChatType)chatType{
    DWDNoteChatMsg *noteMsg = [[DWDNoteChatMsg alloc] init];
    noteMsg.noteString = str;
    noteMsg.fromUser = [DWDCustInfo shared].custId;
    noteMsg.toUser = toUserId;
    noteMsg.createTime = [NSNumber numberWithLongLong:([NSDate date].timeIntervalSince1970 * 1000)];
    noteMsg.msgType = kDWDMsgTypeNote;
    noteMsg.chatType = chatType;
    return noteMsg;
}

/** 存消息模型到本地 */
+ (void)saveSystemMessage:(DWDBaseChatMsg *)msg
{
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        
        //0. 发通知 ，刷新聊天控制器
        NSDictionary *dict = @{@"msg":msg};
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationSystemMessageReload object:nil userInfo:dict];
        
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}



/**
 获取班级功能列表
 
 @param custId  用户Id
 @param success
 @param failure
 */
+ (void)getClassFunctionItemListWithCustId:(NSNumber *)custId
                                   classId:(NSNumber *)classId
                                   success:(void(^)(NSMutableArray *data))success
                                   failure:(void(^)(NSError *error))failure
{
    
}

@end
