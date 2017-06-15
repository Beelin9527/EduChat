//
//  DWDGroupDataBase.h
//  EduChat
//
//  Created by Gatlin on 16/2/19.
//  Copyright © 2016年 dwd. All rights reserved.
//  群组本地库

#import <Foundation/Foundation.h>
@class DWDGroupEntity;
@interface DWDGroupDataBaseTool : NSObject

+(instancetype)sharedGroupDataBase;

#pragma mark Insert
/** 插入某一个群组 */
- (void)insertOneGroup:(DWDGroupEntity *)groupModel;

#pragma mark Get
/** 获取群组列表 */
-(NSArray *)getGroupList:(NSNumber *)custemId;
/** 获取某个群组信息 */
- (DWDGroupEntity *)getGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId;


/** 获取群组的nickname */
- (NSString *)fetchNicknameWithFriendId:(NSNumber *)friendId;

/** 获取群组的photokey */
- (NSString *)fetchPhotoKeyWithFriendId:(NSNumber *)friendId;


#pragma mark Update
/** 用户对群组设置 是否显示其他用户昵称 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId isShowNick:(NSNumber *)isShowNick;
/** 更新某个群组名称 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId groupName:(NSString *)groupName;
/** 更新我在某个群组昵称 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId nickname:(NSString *)nickname;
/** 更新某个群组人数 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId menberCount:(NSNumber *)menberCount;
/** 更新某个群组状态 isExist*/
- (void)updateGroupWithIsExist:(NSNumber *)isExist MyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId;

/**  实时更新群组头像 */
- (void)updateGroupPhotokeyWithGroupId:(NSNumber *)groupId photokey:(NSString *)photokey success:(void(^)())updateSucess failure:(void (^)())updateFailure;

/**  实时更新群组昵称 */
- (void)updateGroupNicknameWithGroupId:(NSNumber *)groupId groupName:(NSString *)groupName success:(void(^)())updateSucess failure:(void (^)())updateFailure;

#pragma mark Delete
/** 删除某个群组 */
- (void)deleteGroupWithMyCustId:(NSNumber *)custId gorupId:(NSNumber *)groupId;


@end
