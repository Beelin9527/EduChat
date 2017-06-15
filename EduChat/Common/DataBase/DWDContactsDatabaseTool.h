//
//  DWDContactsClient.h
//  EduChat
//
//  Created by apple on 12/7/15.
//  Copyright © 2015 dwd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DWDSingleton.h"
@class DWDBaseChatMsg;
@class DWDSystemChatMsg;
@class DWDOfflineMsg, DWDTempContactModel;


@interface DWDContactsDatabaseTool : NSObject

DWDSingletonH(ContactsClient)


#pragma mark Create Table
- (void)reCreateTables;

#pragma mark - Add
/** 
 群组表增加字段
 2016.12.07 为群表增加 isSave（是否保存通讯录）
 */
- (void)groupTableAddElement:(NSString *)column;

/**
 班级组表增加字段
 2016.12.17 为表增加 schDel（标记学校能删除， 1不能删除 ，0能删除）
 */
- (void)classTableAddElement:(NSString *)column;


#pragma mark - Insert
/**  添加或者更新一个联系人 */
//- (void)addContact:(NSDictionary *)contact for:(NSNumber *)custId success:(void(^)())success failure:(void(^)(NSError *error))failure;

/**
 添加一个临时联系人(临时单聊)

 @param model 返回模型数据
 */
- (void)addTempContact:(DWDTempContactModel *)model;


/**
 新加一个朋友,设定一个初始状态,让isFriend = 1, 使聊天控制器显示正确(没有临时聊天view)

 */
- (void)addNewFriendTempStatus:(NSNumber *)custID nickname:(NSString *)nickname;


#pragma mark - Get
/**
 * 校验是否是好友
 */
- (BOOL)getRelationWithFriendCustId:(NSNumber *)friendCustId;

/**
 * 获取好友的备注名
 */
- (NSString *)getRemarkNameWithFriendId:(NSNumber *)friendId;

/**
 * 传ID数组获取指定的这些联系人
 */
- (NSArray *)getContactsByIds:(NSArray *)custemIds;

/**
 * 群组 返回 除去传入的数据
 */
- (NSArray *)getGroupedContacts:(NSNumber *)custemId
                        exclude:(NSArray *)contactIds;

/**
 * 群组 返回 传入的数据
 */
- (NSArray *)getGroupedContacts:(NSNumber *)custemId
                          ByIds:(NSArray *)custemIds;

/**
 * 获取联系人
 */
- (NSArray *)getContactsById:(NSNumber *)custId;


/**
 * 获取好友的nickname
 */
- (NSString *)fetchNicknameWithFriendId:(NSNumber *)friendId;

/**
 * 获取好友的photokey
 */
- (NSString *)fetchPhotoKeyWithFriendId:(NSNumber *)friendId;


/**
 * 根据离线消息的类型, 从联系人表中获取信息
 */
- (NSArray *)getInfoFromDBbyId:(NSNumber *)custId
                   FriendCusId:(NSNumber *)friendCusId
                WithOfflineMsg:(DWDOfflineMsg *)offlineMsg;

/**
 * 根据聊天的类型, 查询不同的表, 获取数据 , 用于插入新数据到recentchatlist
 */
- (NSArray *)getContactsById:(NSNumber *)custId
                 FriendCusId:(NSNumber *)friendCusId
                    chatType:(DWDChatType )chatType;


#pragma mark - Update
/**
 * 更新通讯录
 */
- (void)updateContactsByCustemId:(NSNumber *)custemId
                         success:(void(^)())updateSuccess
                         failure:(void (^)(NSError *error))updateFailure;

/**
 *  更新好友备注名
 */
- (void)updateFriendRemarkNameMyCustId:(NSNumber *)myCustId
                        byFriendCustId:(NSNumber *)friendCustId
                            remarkName:(NSString *)remarkName
                               success:(void(^)())updateSucess
                               failure:(void(^)())failure;
;

/**
 *  更新联系人昵称
 */
- (void)updateFriendNickname:(NSString *)nickname
                    MyCustId:(NSNumber *)myCustId
              byFriendCustId:(NSNumber *)friendCustId
                     success:(void(^)())updateSucess
                     failure:(void(^)())failure;

/**
 *  更新联系人photokey
 */
- (void)updateFriendPhotoKey:(NSString *)photoKey
                    MyCustId:(NSNumber *)myCustId
              byFriendCustId:(NSNumber *)friendCustId
                     success:(void(^)())updateSucess
                     failure:(void(^)())failure;

- (void)updateFriendShipWithCustId:(NSNumber *)friendCustId
                          isFriend:(BOOL)isFriend;


#pragma mark - Delete
/**
 *  删除好友
 */
- (void)deleteContactWithFriendCustId:(NSNumber *)friendCustId
                              success:(void(^)())success
                              failure:(void(^)())failure;


// =====================================================  系统消息 =======================================
- (void)systemMessageInsertToSysMessageTableWith:(DWDSystemChatMsg *)msg success:(void(^)())updateSucess
                                         failure:(void (^)())Failure;


@end
