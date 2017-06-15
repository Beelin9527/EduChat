//
//  DWDGroupRestService.m
//  EduChat
//
//  Created by Gatlin on 15/12/12.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGroupClient.h"
#import "HttpClient.h"
@interface DWDGroupClient ()
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation DWDGroupClient
+(instancetype)sharedRequestGroup
{
    static id  model;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[self alloc]init];
    });
    return  model;
}



- (void)addMBProgressHUD
{
    _hud = [DWDProgressHUD showHUD];
}


-(void)getGroupRestAddGroup:(NSString *)groupName duration:(NSNumber *)duration friendCustId:(NSArray *)friendCustId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [[HttpClient sharedClient]postApi:@"GroupRestService/addGroup" params:@{@"custId":[DWDCustInfo shared].custId,@"groupName":groupName, @"duration":duration,@"friendCustId":friendCustId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject[DWDApiDataKey]);
       
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        failure(error);
    }];

}


- (void)requestAddEntityGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSArray*)friendCustId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure

{
    DWDProgressHUD *hud =[DWDProgressHUD showHUD];
    
    [[HttpClient sharedClient]postApi:@"GroupRestService/addEntity" params:@{DWDCustId:custId,@"groupId":groupId,DWDFriendId:friendCustId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"加入成功"];
        success(responseObject);
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [hud showText:@"加入失败，请尝试重新加入" afterDelay:DefaultTime];
        failure(error);
    }];
}

-(void)requestDeleteEntityGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSArray*)friendCustId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure

{
    
    
    [[HttpClient sharedClient]postApi:@"GroupRestService/deleteEntity" params:@{DWDCustId:custId,@"groupId":groupId,DWDFriendId:friendCustId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
      
        success(responseObject);
   
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
            }];
}
-(void)getGroupRestgetGroupGroupId:(NSNumber *)groupId custId:(NSNumber *)custId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [[HttpClient sharedClient]getApi:@"GroupRestService/getGroup" params:@{DWDCustId:custId,DWDGroupId:groupId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject[DWDApiDataKey]);
        DWDLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        DWDLog(@"%@",error);
        
    }];

}


-(void)getGroupRestGetListGroupId:(NSNumber*)groupId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [[HttpClient sharedClient]getApi:@"GroupRestService/getList" params:@{@"groupId":groupId ? groupId : [NSNull null]} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(responseObject[DWDApiDataKey]);
        DWDLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        DWDLog(@"%@",error);
        
    }];

}

-(void)getGroupRestGetEntityGroupId:(NSNumber *)groupId custId:(NSNumber *)custId friendCustId:(NSNumber *)friendCustId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [[HttpClient sharedClient]getApi:@"GroupRestService/getEntity" params:@{@"groupId":groupId,DWDCustId:custId,DWDFriendId:friendCustId} success:^(NSURLSessionDataTask *task, id responseObject) {
       
        success(responseObject[DWDApiDataKey]);
         DWDLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure(error);
        DWDLog(@"%@",error);
        
    }];
}

-(void)getGroupRestTransferOwnershipGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSNumber*)friendCustId
{
    [[HttpClient sharedClient]postApi:@"GroupRestService/transferOwnership" params:@{@"groupId":groupId,DWDCustId:custId,DWDFriendId:friendCustId} success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"%@",error);
        
    }];

}


-(void)getGroupRestUpdateGroupWithGroupId:(NSNumber*)groupId groupName:(NSString *)groupName  groupNickName:(NSString *)groupNickName success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *dictParams;
    if (groupName) {
        dictParams = @{@"groupId":groupId, DWDCustId: [DWDCustInfo shared].custId, @"groupName":groupName};
    }
    if (groupNickName) {
        dictParams = @{@"groupId":groupId,DWDCustId:[DWDCustInfo shared].custId, @"nickname":groupNickName};

    }
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];

    [[HttpClient sharedClient]postApi:@"GroupRestService/updateGroup" params:dictParams success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"修改成功" afterDelay:DefaultTime];
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud showText:@"修改失败,请重试" afterDelay:DefaultTime];
        failure(error);
    }];
}


//更新群资料 -- 头像
-(void)getGroupRestUpdateGroupWithGroupId:(NSNumber*)groupId photoKey:(NSString *)photoKey success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    __block DWDProgressHUD *hud;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hud = [DWDProgressHUD showHUD];
        hud.labelText = @"正在上传";
    });
    
    [[HttpClient sharedClient]postApi:@"GroupRestService/updateGroup" params:@{@"groupId":groupId, DWDCustId: [DWDCustInfo shared].custId, @"photoKey":photoKey} success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
-(void)getGroupRestUpdateGroupWithGroupId:(NSNumber*)groupId custId:(NSNumber*)custId isTop:(NSNumber*)isTop isClose:(NSNumber*)isClose isSave:(NSNumber*)isSave isShowNick:(NSNumber*)isShowNick success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [[HttpClient sharedClient]postApi:@"GroupRestService/updateGroup" params:@{@"groupId":groupId,DWDCustId:custId,@"isTop":isTop,@"isClose":isClose,@"isSave":isSave,@"isShowNick":isShowNick} success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject[DWDApiDataKey]);
        DWDLog(@"%@",responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"%@",error);
        
    }];
}
@end
