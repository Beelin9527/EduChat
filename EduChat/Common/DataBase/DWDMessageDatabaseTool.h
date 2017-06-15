//
//  DWDChatSessionClient.h
//  EduChat
//
//  Created by apple on 1/8/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDBaseChatMsg.h"

@class DWDTimeChatMsg,DWDChatMsgReceipt;
@interface DWDMessageDatabaseTool : NSObject

DWDSingletonH(MessageDatabaseTool);

/** 首次进入聊天界面 获取参数条数的历史消息 */
- (NSMutableArray *)fetchHistoryMessageWithToId:(NSNumber *)tid chatType:(DWDChatType)chatType fetchCount:(NSUInteger)count;

/** 获取count条和friendid的消息内容 按创建时间排序 */
//- (NSArray *)getMsgToDBByMycusId:(NSNumber *)myCusId andFriendId:(NSNumber *)friendId chatType:(DWDChatType )chatType msgCount:(NSUInteger )count success:(void(^)(NSArray *chatSessions))success failure:(void(^)(NSError *error))failure;


/** 获取数据库中最后的未读消息以下的已读消息 , 最多25条 */
- (void)fetchMsgsUntilLastMsgOfUnreadMsgsWithFriendId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)(NSArray *chatSessions))success failure:(void(^)(NSError *error))failure;

/** 取出一条消息 , 根据msgId */
- (DWDBaseChatMsg *)fetchMessageWithToId:(NSNumber *)toId MsgId:(NSString *)msgId chatType:(DWDChatType )chatType;

/** 根据传入的ORDERID 向上获取数据 取到第一次遇到未读标记位置 或者达到个数为止*/
- (void)upFetchMsgsFromBeginningCreatTime:(NSNumber *)beginningCreatTime friendId:(NSNumber *)friendId chatType:(DWDChatType )chatType fetchCount:(NSNumber *)fetchCount success:(void(^)(NSMutableArray *chatSessions))success failure:(void(^)(NSError *error))failure;

/** 取出指定消息的上一条 非时间 提示的消息 , 可能会是note提示的消息 */
- (DWDBaseChatMsg *)upFetchChatMsgWithMsg:(DWDBaseChatMsg *)msg toUser:(NSNumber *)toId chatType:(DWDChatType )chatType;

/** 重置未读标记为 Null  */
- (void)resetMsgUnreadCountToNull:(DWDBaseChatMsg *)msg success:(void(^)())success failure:(void(^)(NSError *error))failure;
- (void)resetMsgUnreadCountToNullWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType msgId:(NSString *)msgId success:(void(^)())success;

/** 插入时间模型, 到指定消息模型的ID上面 */
- (void)insertTimeMsg:(DWDTimeChatMsg *)timeChatMsg AboveMsg:(DWDBaseChatMsg *)baseMsg success:(void(^)())success failure:(void(^)(NSError *error))failure;

// 插入新消息到数据库
- (void)addMsgToDBWithMsg:(DWDBaseChatMsg *)msg success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 批量添加消息到数据库 */
- (void)addMsgsToDBWithMsgs:(NSArray *)msgs success:(void(^)())success failure:(void(^)(NSError *error))failure;

/**  添加所有的未读消息的最后那条 到数据库 ,并标记好未读字段 */
- (void)addLastMsgsOfUnreadMsg:(NSArray *)lastMsgOfUnreadArray success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 更新语音消息体 未读变已读*/
- (void)updateAudioMessageTbWithMsg:(DWDBaseChatMsg *)msg success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 插入所有未读消息到  消息数据表 */
- (void)insertUnreadMsgToDBWithMsg:(NSArray *)msgs success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 删除和某个ID的对话历史消息 , 传id 和 聊天类型 就可以了*/
- (void)deleteMessageWithId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

///** 删除消息 传被删除的消息 自动判断是否删除数据库中的时间提示*/
//- (void)deleteMessageAndJudgeShouldTimeNoteDeleteWithFriendId:(NSNumber *)friendId msg:(DWDBaseChatMsg *)msg chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

///** 更新createTime 用服务器的系统时间 */
//- (void)updateCreateTimeWithMsg:(DWDBaseChatMsg *)msg beforeUpdateTimeStamp:(NSNumber *)timeStamp success:(void(^)())success failure:(void(^)(NSError *error))failure;
/** 撤回消息 , 修改msgType 和NoteString */
- (void)revokeMsgWithNoteString:(NSString *)string revokedMsgId:(NSString *)msgId friendId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 更新消息的发送状态 */
- (void)updateMsgStateToState:(DWDChatMsgState )state WithMsgId:(NSString *)msgId toUserId:(NSNumber *)toUser chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 根据回执 , 更新消息的发送状态 和timeStamp */
- (void)updateMsgStateToState:(DWDChatMsgState )state WithMsgReceipt:(DWDChatMsgReceipt *)receipt chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 取出消息的发送状态 */
- (DWDChatMsgState)fetchMessageSendingStateWithToId:(NSNumber *)toId MsgId:(NSString *)msgId chatType:(DWDChatType )chatType;

/** 获取最后的一条消息 */
- (DWDBaseChatMsg *)fetchLastMsgWithToUser:(NSNumber *)toId chatType:(DWDChatType )chatType;
/** 向上找时间消息 查看是否超出指定时间 MSG仅用于寻找表格 */
- (BOOL)upFindTimeMsgBeyond5MinuteWithmsg:(DWDBaseChatMsg *)msg isUnreadMsg:(BOOL)isUnread beyondTime:(NSTimeInterval)beyondTime;

/** 向上找时间模型, 根据指定的时间戳 , 返回是否超过beyondTime */
- (BOOL)upFindOutTimeMsgDESCOrderByCreateTimeLessThanTimeStamp:(NSNumber *)createTime tableName:(DWDBaseChatMsg *)msg;
/** 删除多条消息 */
- (void)deleteMessageWithFriendId:(NSNumber *)friendId msgs:(NSArray *)msgs chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

#pragma mark - Delete
/**
 * 删除聊天记录 整张表
 */
- (void)deleteMessageTableWithFriendId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure;

/** 判断是否还有聊天记录 */
- (BOOL)JudgeChatRecordExistWithLastMsg:(DWDBaseChatMsg *)msg;
@end
