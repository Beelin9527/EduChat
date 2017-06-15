//
//  DWDClassDataBase.h
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//  班级本地库

#import <Foundation/Foundation.h>
@class DWDClassModel,DWDClassMember;

@interface DWDClassDataBaseTool : NSObject
+(instancetype)sharedClassDataBase;

#pragma mark - Get
/** 获取班级列表 */
- (NSArray *)getClassList:(NSNumber *)custemId;
/** 根据classId 获取班级信息 */
- (DWDClassModel *)getClassInfoWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;

/**
 * 获取班级成员，非班级创建者
 */
- (NSArray *)getClassMemberIsNotMianWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;
/** 根据classId 获取班级所有成员 */
- (NSArray *)getClassMemberWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;
/** 获取班级成员不超过14人 */
- (NSArray *)getClassMemberNoMoreThanFourTeenWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;
/** 获取班级总人数 */
- (void)getClassMemberCountWithClassId:(NSNumber *)classId success:(void(^)(NSUInteger memberCount))success failure:(void(^)())failure;

/** 根据数组，获取该数组对应该班级成员 includeMian 需不需要返回创建者*/
- (NSArray *)getClassMemberWithByMembersId:(NSArray *)membersId  ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId includeMian:(BOOL)includeMian;;
/** 根据数组，获取排除该数组对应该班级成员 */
- (NSArray *)getClassMemberWithExcludeByMembersId:(NSArray *)membersId  ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;

/** 根据classId 获取所有班级成员昵称 */
- (NSArray *)getClassAllMemberNicknameWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;
/** 根据classId、array 获取班级 array 成员昵称 */
- (NSArray *)getClassMemberNicknameWithClassId:(NSNumber *)classId memberArray:(NSArray *)memberArray;

#pragma mark - Insert
/** 插入班级 */
- (void)insertClassWithClassModel:(DWDClassModel *)classModel insertSuccess:(void(^)())insetSuccess insertFailure:(void(^)())insertFailure;
/** 插入班级成员 */
- (void)insertClassMember:(id)responseObject classId:(NSNumber *)classId myCustId:(NSNumber *)myCustId updateSuccess:(void(^)())updateSuccess updateFailure:(void(^)())updateFailure;

#pragma mark - Update
/** 更新班级头像 */
- (void)updateClassInfoWithPhotoKey:(NSString *)photoKey classId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;
/** 更新班级信息 介绍 */
- (void)updateClassInfoWithIntroduce:(NSString *)introduce ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;

/** 更新班级信息 自己班级昵称 */
- (void)updateClassInfoWithNickname:(NSString *)nickname ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;

/**  更新班级信息 是否显示其他用户昵称 */
- (void)updateClassInfoWithisShowNick:(NSNumber *)isShowNick classId:(NSNumber *)classId myCustId:(NSNumber *)myCustId;

/** 更新班级信息 人数 */
- (void)updateClassInfoWithMemberCount:(NSNumber *)memberCount classId:(NSNumber *)classId;

/**  实时更新班级头像 */
- (void)updateClassPhotokeyWithClassId:(NSNumber *)classId photokey:(NSString *)photokey success:(void(^)())updateSucess failure:(void (^)())updateFailure;

/** 获取班级的nickname */
- (NSString *)fetchNicknameWithFriendId:(NSNumber *)friendId;

/** 获取班级的photokey */
- (NSString *)fetchPhotoKeyWithFriendId:(NSNumber *)friendId;


#pragma mark - Delete
/** 删除该班级 */
- (void)deleteClassId:(NSNumber *)classId success:(void(^)())updateSucess failure:(void (^)())updateFailure;
/** 删除班级成员 */
- (void)deleteClassMemberWithClassId:(NSNumber *)classId membersId:(NSArray *)membersId success:(void(^)())updateSucess failure:(void (^)())updateFailure;

@end
