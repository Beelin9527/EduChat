//
//  DWDGroupRestService.h
//  EduChat
//
//  Created by Gatlin on 15/12/12.
//  Copyright © 2015年 dwd. All rights reserved.
//  群组请求业务 

#import <Foundation/Foundation.h>

@interface DWDGroupClient : NSObject
+(instancetype)sharedRequestGroup;
//创建组
-(void)getGroupRestAddGroup:(NSString*)groupName duration:(NSNumber *)duration friendCustId:(NSArray*)friendCustId success:(void(^)(id responseObject))success failure:(void(^)(NSError *error))failure;

//添加组成员
-(void)requestAddEntityGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSArray*)friendCustId success:(void (^)(id responseObject))success failure:(void (^)(NSError * error))failure;

//删除组成员  群主删除该群 或 成员退出该群 custId 与 friendCustId 必须相等
-(void)requestDeleteEntityGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSArray*)friendCustId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//获取群组信息getGroup
-(void)getGroupRestgetGroupGroupId:(NSNumber*)groupId custId:(NSNumber*)custId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//获取群所有成员信息getList
-(void)getGroupRestGetListGroupId:(NSNumber*)groupId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//获取群某成员信息getEntity
-(void)getGroupRestGetEntityGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSNumber*)friendCustId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//群主转让transferOwnership
-(void)getGroupRestTransferOwnershipGroupId:(NSNumber*)groupId custId:(NSNumber*)custId friendCustId:(NSNumber*)friendCustId;

//更新群资料 -- 更新群组名称  或 个人群称昵
-(void)getGroupRestUpdateGroupWithGroupId:(NSNumber*)groupId groupName:(NSString *)groupName  groupNickName:(NSString *)groupNickName success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//更新群资料 -- 头像
- (void)getGroupRestUpdateGroupWithGroupId:(NSNumber*)groupId photoKey:(NSString *)photoKey success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//更新群资料 -- 更新群组按钮设置状态  必须带上custid，设置时表明修改用户对群组的设置信息
-(void)getGroupRestUpdateGroupWithGroupId:(NSNumber*)groupId custId:(NSNumber*)custId isTop:(NSNumber*)isTop isClose:(NSNumber*)isClose isSave:(NSNumber*)isSave isShowNick:(NSNumber*)isShowNick success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
