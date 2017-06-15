//
//  DWDRecentChatDatabaseTool.h
//  EduChat
//
//  Created by Superman on 16/4/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWDOfflineMsg;
@class DWDBaseChatMsg;
@class DWDRecentChatModel;
@class DWDSysMsg;
@class DWDSystemChatMsg;

@interface DWDRecentChatDatabaseTool : NSObject

DWDSingletonH(RecentChatDatabaseTool);

@property (nonatomic , strong) NSNumber *currentOperationMyCusId;  // 当前聊天正在操作的ID
@property (nonatomic , strong) NSNumber *currentOperationFriendId;   // 当前聊天正在操作的ID

/** 根据好友ID返回recentChat的点击前badgeCount */
- (NSNumber *)getRecentChatBadgeNumWithFriendId:(NSNumber *)friendId;

/**  传入需要增加的badgeCount 修改这条记录里的badgeCount数量 */
- (void)updateBadgeCountRecentChatWithMyCusId:(NSNumber *)myCusId friendId:(NSNumber *)friendId addBadgeCount:(NSUInteger)badgeCount success:(void(^)())updateSucess failure:(void(^)())Failure;

/** 获取数据库中所有的未读消息总和 */
- (NSNumber *)getAllRecentChatBadgeNum;

/** 某条recentChat记录badgeCount减1 */
- (void)minusOneNumToRecentChatWithFriendId:(NSNumber *)friendId myCusId:(NSNumber *)myCusId success:(void(^)())sucess failure:(void(^)())Failure;

/** 清空某个recentChat的badgeCount为0  friendId可以是系统ID 接送中心ID */
- (void)clearBadgeCountWithFriendId:(NSNumber *)friendId myCusId:(NSNumber *)myCusId success:(void(^)())sucess failure:(void(^)())Failure;

/** 根据收到    (((新的消息)))   类型 插入新的数据到 会话列表 */
- (void)insertNewDataToRecentChatListWithMsg:(DWDBaseChatMsg *)msg FriendCusId:(NSNumber *)friendCusid myCusId:(NSNumber *)cusId success:(void(^)())insertSucess failure:(void (^)())Failure;

/** 根据收到   (((新的消息)))    , 更新最新的字段信息到会话列表 */
- (void)updateNewMsgToRecentChatListWithMsg:(DWDBaseChatMsg *)msg cusId:(NSNumber *)cusId friendId:(NSNumber *)friendId success:(void(^)())updateSucess failure:(void (^)())Failure;


/**  在新的朋友中 点击接受  根据传入的recentChat模型 插入数据到会话列表 */
- (void)insertNewDataToRecentChatListWithRecentChatModel:(DWDRecentChatModel *)recentChat success:(void(^)())insertSucess failure:(void (^)())Failure;

/**  根据离线消息  <<<(离线消息的最后一条消息结构和对发一样)>>> 插入会话列表 */
- (void)insertNewDataToRecentChatListWithOfflineLastMsg:(DWDBaseChatMsg *)msg FriendCusId:(NSNumber *)friendCusid myCusId:(NSNumber *)cusId success:(void(^)())insertSucess failure:(void (^)())Failure;


/*    ---------------------------------------------------  */

/** 查看最近会话列表是否有传入id的系统消息cell */
- (BOOL)haveSysDataInRecentChatWithSysId:(NSNumber *)sysId;

/** 根据收到新的系统消息 , 更新最新的字段信息到会话列表 */
- (void)updateNewMsgToRecentChatListWithSysMsg:(DWDSysMsg *)sysMsg sysId:(NSNumber *)sysId content:(NSString *)content success:(void(^)())updateSucess failure:(void (^)())Failure;

/** 根据系统消息 (通过我的好友申请 , 班级申请 , 群主申请) 插入新的数据到 会话列表 */
- (void)insertNewDataToRecentChatListWithSysMsg:(DWDSysMsg *)sysMsg friendId:(NSNumber *)sysId content:(NSString *)content nickName:(NSString *)nickName chatType:(DWDChatType )type success:(void(^)())insertSucess failure:(void (^)())Failure;

/** 更新recentchat 的备注名*/
- (void)updateRecentChatRemarkNameWithFriendId:(NSNumber *)friendId remarkName:(NSString *)remarkName Success:(void(^)())success failure:(void (^)())Failure;

/** 更新lastContent */
- (void)updateLastContentWithCusId:(NSNumber *)cusId content:(NSString *)lastContent success:(void(^)())updateSucess failure:(void (^)())updateFailure;

/** 更新recentchat 的nickname*/
- (void)updateRecentChatNicknameWithFriendId:(NSNumber *)friendId nickname:(NSString *)nickname Success:(void(^)())success failure:(void (^)())Failure;

/* ------------------------------------------------------------------------  */
/** 获取最近聊天会话列表 */
- (NSArray *)getRecentChatListById:(NSNumber *)custId;

/*  -------------------------------------------------------------  */
/** 获取最近聊天会话列表 转发用 */
- (NSArray *)getRecentChatListByIdForRelayOnChat:(NSNumber *)custId;

/** 通过ID获取单条recentChat数据 */
- (DWDRecentChatModel *)fetchRecentChatById:(NSNumber *)custId;

/** 对最近会话表设置 是否显示其他用户昵称 */
- (void)updateRecentWithMyCustId:(NSNumber *)myCust custId:(NSNumber *)custId isShowNick:(NSNumber *)isShowNick;

/** 查看会话列表中是否有friendid这条数据 */
//- (BOOL)haveDataInRecentChat:(NSNumber *)cusId FriendId:(NSNumber *)friendId;

/** 传好友ID 删除这条recentchat记录 */
- (void)deleteRecentChatWithFriendId:(NSNumber *)friendId success:(void(^)())deleteSucess failure:(void (^)())Failure;

/** 更新系统消息到最近联系人列表 */
- (void)updateNewSystemMsgToRecentChatListWith:(DWDSystemChatMsg *)msg success:(void(^)())updateSucess failure:(void (^)())Failure;

/** 把有新成员加入班级系统消息插入数据库*/
- (void)insertNewClassMemberverifyToRecentChatListWithMyCusId:(NSNumber *)myCusId CustId:(NSNumber *)custId lasteContent:(NSString *)lastContent nickName:(NSString *)nickName success:(void(^)())insertSucess failure:(void (^)())Failure;

/**  实时更新头像 */
- (void)updatePhotokeyWithCusId:(NSNumber *)cusId photokey:(NSString *)photokey success:(void(^)())updateSucess failure:(void (^)())updateFailure;
/**  实时更新昵称 */
- (void)updateNicknameWithCusId:(NSNumber *)cusId nickname:(NSString *)nickname success:(void(^)())updateSucess failure:(void (^)())updateFailure;

- (void)reCreateTables;

@end
