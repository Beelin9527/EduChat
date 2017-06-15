//
//  DWDRecentChatDatabaseTool.m
//  EduChat
//
//  Created by Superman on 16/4/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRecentChatDatabaseTool.h"
#import <FMDB.h>
#import "DWDContactsDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"

#import "DWDBaseChatMsg.h"
#import "DWDOfflineMsg.h"
#import "DWDTextChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDAudioChatMsg.h"
#import "DWDVideoChatMsg.h"
#import "DWDNoteChatMsg.h"
#import "DWDRecentChatModel.h"
#import "DWDSysMsg.h"
#import "DWDSystemChatMsg.h"
#import <YYModel.h>

@implementation DWDRecentChatDatabaseTool

DWDSingletonM(RecentChatDatabaseTool);

- (instancetype)init {
    
    if ([super init]) {
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            
            if (![db tableExists:@"tb_recentchatlist"]) {
                [db executeUpdate:@"CREATE TABLE tb_recentchatlist (id INTEGER PRIMARY KEY AUTOINCREMENT, myCustId INTEGER, custId INTEGER UNIQUE, lastContent TEXT, photoKey TEXT,nickname TEXT, remarkName TEXT , isFriend INTEGER , lastCreatTime INTEGER , type TEXT , chatType INTEGER, albumId INTEGER , memberCount INTEGER , badgeCount INTEGER ,isShowNick INTEGER);"];
            }
            
        }];
    }
    
    return self;
}

- (void)reCreateTables{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        if (![db tableExists:@"tb_recentchatlist"]) {
            [db executeUpdate:@"CREATE TABLE tb_recentchatlist (id INTEGER PRIMARY KEY AUTOINCREMENT, myCustId INTEGER, custId INTEGER UNIQUE, lastContent TEXT, photoKey TEXT,nickname TEXT, remarkName TEXT , isFriend INTEGER , lastCreatTime INTEGER , type TEXT , chatType INTEGER, albumId INTEGER , memberCount INTEGER , badgeCount INTEGER ,isShowNick INTEGER);"];
        }
        
    }];
}

/** 根据好友ID返回recentChat的点击前badgeCount */
- (NSNumber *)getRecentChatBadgeNumWithFriendId:(NSNumber *)friendId{
    
    __block FMResultSet *rs;
    NSString *sql;
    __block NSNumber *badgeNumber = nil;
    
    sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            badgeNumber = [NSNumber numberWithInt:[rs intForColumn:@"badgeCount"]];
        }
        [rs close];
        
    }];
    
    return badgeNumber;
    
}

/**  传入需要增加的badgeCount 修改这条记录里的badgeCount数量 */
- (void)updateBadgeCountRecentChatWithMyCusId:(NSNumber *)myCusId friendId:(NSNumber *)friendId addBadgeCount:(NSUInteger)badgeCount success:(void(^)())updateSucess failure:(void(^)())Failure{
    
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_recentchatlist SET badgeCount = badgeCount + ? WHERE myCustId = ? AND custId = ?;",[NSNumber numberWithInteger:badgeCount] ,myCusId, friendId];
        
    }];
    
    if (success) {
        updateSucess();
    }else{
        Failure();
    }
}

/** 获取所有的badgeCount总数 */
- (NSNumber *)getAllRecentChatBadgeNum{
    
    __block FMResultSet *rs;
    __block NSString *sql;
    __block int totle = 0;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@;", [DWDCustInfo shared].custId];
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            totle = totle + [rs intForColumn:@"badgeCount"];
        }
        
        [rs close];
        
    }];
    
    return [NSNumber numberWithInt:totle];
}

/** 某条recentChat记录badgeCount减1 */
- (void)minusOneNumToRecentChatWithFriendId:(NSNumber *)friendId myCusId:(NSNumber *)myCusId success:(void(^)())sucess failure:(void(^)())Failure{
    
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_recentchatlist SET badgeCount = badgeCount - 1 WHERE myCustId = ? AND badgeCount > 0 AND custId = ?;" ,myCusId, friendId];
        
    }];
    
    if (success) {
        sucess();
    }else{
        Failure();
    }
}

/** 清空某个recentChat的badgeCount为0  friendId可以是系统ID 接送中心ID */
- (void)clearBadgeCountWithFriendId:(NSNumber *)friendId myCusId:(NSNumber *)myCusId success:(void(^)())sucess failure:(void(^)())Failure{
    
    __block BOOL success = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_recentchatlist SET badgeCount = ? WHERE myCustId = ? AND custId = ?;" , @0 ,myCusId, friendId];
        
    }];
    
    if (success) {
        sucess();
    }else{
        Failure();
    }
    
}

/* =======================================                 ===================================================   */

- (void)insertNewDataToRecentChatListWithOfflineLastMsg:(DWDBaseChatMsg *)msg FriendCusId:(NSNumber *)friendCusid myCusId:(NSNumber *)cusId success:(void(^)())insertSucess failure:(void (^)())Failure{
    __block BOOL success = YES;
    __block NSNumber *friendId;
    __block NSString *photokey;
    __block NSString *nickName;
    __block NSNumber *badgeCount;
    __block NSString *remarkName;
    
    if (msg.chatType == DWDChatTypeClass) {
        
        friendId = msg.toUser;
        photokey = [[DWDClassDataBaseTool sharedClassDataBase] fetchPhotoKeyWithFriendId:friendId];
        nickName = [[DWDClassDataBaseTool sharedClassDataBase] fetchNicknameWithFriendId:friendId];
        remarkName = nil;
        
    }else if (msg.chatType == DWDChatTypeGroup){
        photokey = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchPhotoKeyWithFriendId:friendId];
        nickName = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchNicknameWithFriendId:friendId];
        friendId = msg.toUser;
        remarkName = nil;
        
    }else{ // 单聊
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发出去的消息  需要拿别人的头像 和 nickname 插会话表
            NSArray *arr = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId FriendCusId:friendCusid chatType:msg.chatType];
            NSDictionary *dict = arr[0];
            friendId = msg.toUser;
            photokey = dict[@"photoKey"];
            nickName = dict[@"nickname"];
            remarkName = [self getRemarkNameWithFriendId:friendId];
        }else{  // 别人发的新消息
            photokey = msg.photohead.photoKey;
            nickName = msg.nickname;
            friendId = msg.fromUser;
            remarkName = [self getRemarkNameWithFriendId:friendId];
        }
    }
    
    badgeCount = [[self getRecentChatBadgeNumWithFriendId:friendId] isEqual:nil] ? @0 : @([[self getRecentChatBadgeNumWithFriendId:friendId] integerValue] + [msg.badgeCount integerValue]);
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
            DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
            NSString *lastContent = textMsg.content;
            
            success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ ,%@);",
                       cusId, friendId, lastContent , photokey, nickName, textMsg.createTime , [NSNumber numberWithUnsignedInteger:textMsg.chatType] ,badgeCount ,remarkName];
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
            DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
            success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType,badgeCount ,remarkName) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ , %@);",
                       cusId, friendId, @"[图片]" , photokey, nickName, imageMsg.createTime , [NSNumber numberWithUnsignedInteger:imageMsg.chatType] , badgeCount ,remarkName];
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
            DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
            success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName ) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ , %@);",
                       cusId, friendId, @"[语音消息]" , photokey, nickName, audioMsg.createTime ,[NSNumber numberWithUnsignedInteger:audioMsg.chatType] , badgeCount,remarkName];
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]){
            DWDVideoChatMsg *audioMsg = (DWDVideoChatMsg *)msg;
            success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName ) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ , %@);",
                       cusId, friendId, @"[视频]" , photokey, nickName, audioMsg.createTime ,[NSNumber numberWithUnsignedInteger:audioMsg.chatType] , badgeCount,remarkName];
            
        }else{
            
            success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName ) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ , %@);",
                       cusId, friendId, @"你们已经是好友了,点击进入聊天", photokey, nickName, msg.createTime , [NSNumber numberWithUnsignedInteger:msg.chatType] , badgeCount,remarkName];
        }
        
    }];
    
    if (success) {
        
        insertSucess();
        
    }else{
        Failure();
    }
}

/** 根据收到新的消息类型 插入新的数据到 会话列表 */
- (void)insertNewDataToRecentChatListWithMsg:(DWDBaseChatMsg *)msg FriendCusId:(NSNumber *)friendCusid myCusId:(NSNumber *)cusId success:(void(^)())insertSucess failure:(void (^)())Failure{
    
    __block BOOL success = YES;
    __block NSNumber *friendId;
    __block NSString *photokey;
    __block NSString *nickName;
    __block NSNumber *badgeCount;
    __block NSString *remarkName;
    
    if (msg.chatType == DWDChatTypeClass) {
        friendId = msg.toUser;
        photokey = [[DWDClassDataBaseTool sharedClassDataBase] fetchPhotoKeyWithFriendId:friendId];
        nickName = [[DWDClassDataBaseTool sharedClassDataBase] fetchNicknameWithFriendId:friendId];
        remarkName = nil;
    }else if (msg.chatType == DWDChatTypeGroup){
        
        friendId = msg.toUser;
        photokey = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchPhotoKeyWithFriendId:friendId];
        nickName = [[DWDGroupDataBaseTool sharedGroupDataBase] fetchNicknameWithFriendId:friendId];
        remarkName = nil;
        
    }else{ // 单聊
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发出去的消息  需要拿别人的头像 和 nickname 插会话表
            NSArray *arr = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId FriendCusId:friendCusid chatType:msg.chatType];
            
            //判断是否空
            if (!arr.count){
                Failure();
                return;
            }
            NSDictionary *dict = arr[0];
            friendId = msg.toUser;
            photokey = dict[@"photoKey"];
            nickName = dict[@"nickname"];
            remarkName = [self getRemarkNameWithFriendId:friendId];
        }else{  // 别人发的新消息
            photokey = msg.photohead.photoKey;
            nickName = msg.nickname;
            friendId = msg.fromUser;
            remarkName = [self getRemarkNameWithFriendId:friendId];
        }
    }
    
    
    if (![msg.fromUser isEqual:[DWDCustInfo shared].custId]) {
        badgeCount = [[self getRecentChatBadgeNumWithFriendId:friendId] isEqual:nil] ? @0 : @([[self getRecentChatBadgeNumWithFriendId:friendId] integerValue] + 1);
    }else{
        badgeCount = [self getRecentChatBadgeNumWithFriendId:friendId];
    }
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
            DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
            NSString *lastContent = textMsg.content;
            
            if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent ,photoKey ,nickname ,  lastCreatTime , chatType , badgeCount , remarkName) VALUES(%@ ,%@ ,%@ ,%@ ,%@, %@, %@, %@ ,%@);",
                           cusId, friendId, lastContent , photokey,nickName ,textMsg.createTime , [NSNumber numberWithUnsignedInteger:textMsg.chatType] ,badgeCount ,remarkName];
            }else{
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount, remarkName) VALUES(%@ ,%@, %@, %@, %@ ,%@, %@, %@, %@);",
                           cusId, friendId, lastContent , photokey, nickName, textMsg.createTime , [NSNumber numberWithUnsignedInteger:textMsg.chatType] ,badgeCount ,remarkName ];
            }
            
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
            DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
            
            if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent , photoKey ,nickname , lastCreatTime ,chatType , badgeCount, remarkName) VALUES(%@ , %@ , %@ ,%@ ,%@, %@, %@, %@ ,%@);",
                           cusId, friendId, @"[图片]" , photokey , nickName, imageMsg.createTime ,[NSNumber numberWithUnsignedInteger:imageMsg.chatType] ,badgeCount ,remarkName];
            }else{
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType,badgeCount,remarkName) VALUES(%@ ,%@, %@, %@, %@ ,%@, %@, %@, %@ );",
                           cusId, friendId, @"[图片]" , photokey, nickName, imageMsg.createTime , [NSNumber numberWithUnsignedInteger:imageMsg.chatType] , badgeCount,remarkName];
            }
            
            
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
            DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
            
            if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent , photoKey ,nickname , lastCreatTime , chatType , badgeCount,remarkName) VALUES(%@,%@,%@ ,%@ ,%@, %@, %@, %@ ,%@);",
                           cusId, friendId, @"[语音消息]" , photokey,nickName, audioMsg.createTime , [NSNumber numberWithUnsignedInteger:audioMsg.chatType] ,badgeCount ,remarkName];
            }else{
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName) VALUES(%@ ,%@, %@, %@, %@ ,%@, %@, %@, %@);",
                           cusId, friendId, @"[语音消息]" , photokey, nickName, audioMsg.createTime ,[NSNumber numberWithUnsignedInteger:audioMsg.chatType] , badgeCount ,remarkName];
            }
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeNote]){
            DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)msg;
            
            if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent ,photoKey ,nickname ,  lastCreatTime , chatType , badgeCount,remarkName) VALUES(%@ , %@ , %@ ,%@ ,%@ ,%@, %@, %@, %@ );",
                           cusId, friendId, noteMsg.noteString , photokey , nickName, noteMsg.createTime , [NSNumber numberWithUnsignedInteger:noteMsg.chatType] ,badgeCount ,remarkName];
            }else{
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName) VALUES(%@ ,%@ ,%@, %@, %@, %@ ,%@, %@, %@);",
                           cusId, friendId, noteMsg.noteString , photokey, nickName, noteMsg.createTime ,[NSNumber numberWithUnsignedInteger:noteMsg.chatType] , badgeCount ,remarkName];
            }
            
        }else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]) {  // -- fzg
            
            DWDVideoChatMsg *imageMsg = (DWDVideoChatMsg *)msg;
            
            if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent , photoKey ,nickname , lastCreatTime ,chatType , badgeCount, remarkName) VALUES(%@ , %@ ,%@ ,%@ ,%@ ,%@, %@, %@, %@ );",
                           cusId, friendId, @"[视频]" , photokey , nickName, imageMsg.createTime ,[NSNumber numberWithUnsignedInteger:imageMsg.chatType] ,badgeCount ,remarkName];
            }else{
                success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType,badgeCount,remarkName) VALUES(%@ ,%@ ,%@, %@, %@, %@ ,%@, %@, %@);",
                           cusId, friendId, @"[视频]" , photokey, nickName, imageMsg.createTime , [NSNumber numberWithUnsignedInteger:imageMsg.chatType] , badgeCount,remarkName];
            }
            
            
            
        }
        
        else{
            
            success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ,remarkName ) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ , %@);",
                       cusId, friendId, @"你们已经是好友了,点击进入聊天", photokey, nickName, msg.createTime , [NSNumber numberWithUnsignedInteger:msg.chatType] , badgeCount,remarkName];
        }
        
    }];
    
    if (success) {
        
        insertSucess();
        
    }else{
        Failure();
    }
}

/** 获取好友的备注名 */
- (NSString *)getRemarkNameWithFriendId:(NSNumber *)friendId{
    
    __block FMResultSet *rs;
    __block NSString *remarkName;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            remarkName = [rs stringForColumn:@"remarkName"];
        }
        
        [rs close];
        
    }];
    
    return remarkName;
}

/** 根据收到新的消息 , 更新最新的字段信息到会话列表 */
- (void)updateNewMsgToRecentChatListWithMsg:(DWDBaseChatMsg *)msg cusId:(NSNumber *)cusId friendId:(NSNumber *)friendId success:(void(^)())updateSucess
                                    failure:(void (^)())Failure{
    
//    NSString *lastContent;
//    NSString *photoKey;
//    NSString *nickName;
//    NSString *remarkName;
//    __block BOOL success = NO;
//    
//    if (msg.chatType == DWDChatTypeGroup || msg.chatType == DWDChatTypeClass) {  // 群聊
//        
//        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发出去的消息  需要拿别人的头像 和 nickname 插会话表
//            
//            photoKey = nil;
//            nickName = nil;
//            remarkName = nil;
//        }else{  // 别人发的新消息
//            photoKey = nil;
//            nickName = nil;
//            remarkName = nil;
//        }
//        
//    }else{  // 单聊
//        
//        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发出去的消息  需要拿别人的头像 和 nickname 插会话表
//            
//            NSArray *arr = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId FriendCusId:msg.toUser chatType:msg.chatType];
//            NSDictionary *dict = arr[0];
//            photoKey = dict[@"photoKey"];
//            nickName = dict[@"nickname"];
//            remarkName = [self getRemarkNameWithFriendId:friendId];
//            
//        }else{  // 别人发的新消息
//            photoKey = msg.photohead.photoKey;
//            nickName = msg.nickName;
//            remarkName = [self getRemarkNameWithFriendId:friendId];
//        }
//    }
//    
//    
//    if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
//        DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
//        lastContent = textMsg.content;
//    }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
//        lastContent = @"[图片]";
//    }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
//        lastContent = @"[语音消息]";
//    }
//    
//    
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        
//        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {
//            success = [db executeUpdate:@"UPDATE tb_recentchatlist SET lastContent = ? , nickname = ? , lastCreatTime = ? , photoKey = ? ,remarkName = ? WHERE myCustId = ? AND custId = ?;", lastContent  , nickName,  msg.createTime ,photoKey  , remarkName,  cusId , friendId];
//        }else{
//            success = [db executeUpdate:@"UPDATE tb_recentchatlist SET lastContent = ? , nickname = ? , lastCreatTime = ? , photoKey = ? ,badgeCount = badgeCount + 1 ,remarkName = ? WHERE myCustId = ? AND custId = ?;", lastContent  , nickName,  msg.createTime ,photoKey  , remarkName,  cusId , friendId];
//        }
//        
//    }];
//    
//    
//    if (success) {
//        updateSucess();
//    }else{
//        Failure();
//    }
    
}

/**  在新的朋友中 点击接受  根据传入的recentChat模型 插入数据到会话列表 */
- (void)insertNewDataToRecentChatListWithRecentChatModel:(DWDRecentChatModel *)recentChat success:(void(^)())insertSucess failure:(void (^)())Failure{
    
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdateWithFormat:@"INSERT INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType , badgeCount , remarkName) VALUES(%@ ,%@, %@, %@, %@ ,%@, %@, %@, %@);",
                   recentChat.myCustId, recentChat.custId, recentChat.lastContent , recentChat.photoKey, recentChat.nickname, recentChat.lastCreatTime , [NSNumber numberWithInteger:DWDChatTypeFace] , @1 , recentChat.remarkName , nil];
        
    }];
    
    if (success) {
        
        insertSucess();
        
    }else{
        Failure();
    }
    
}

/* ------------------------------------------------  */

/** 查看最近会话列表是否有传入id的系统消息cell */
- (BOOL)haveSysDataInRecentChatWithSysId:(NSNumber *)sysId{
    __block FMResultSet *rs;
    __block NSString *sql;
    __block BOOL isHave = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , sysId];
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            isHave = YES;
            break;
        }
        
        [rs close];
    }];
    
    return isHave;
}

/** 根据收到新的系统消息 , 更新最新的字段信息到会话列表 */
- (void)updateNewMsgToRecentChatListWithSysMsg:(DWDSysMsg *)sysMsg sysId:(NSNumber *)sysId content:(NSString *)content success:(void(^)())updateSucess failure:(void (^)())Failure{
    
    __block BOOL success = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_recentchatlist SET lastContent = ? , lastCreatTime = ? , badgeCount = badgeCount + 1  WHERE myCustId = ? AND custId = ?;", content , sysMsg.entity.createTime , [DWDCustInfo shared].custId , sysId];
        
    }];
    
    if (success) {
        updateSucess();
    }else{
        Failure();
    }
}

/** 根据系统消息 (通过我的好友申请 , 班级申请 , 群主申请) 插入新的数据到 会话列表 */
- (void)insertNewDataToRecentChatListWithSysMsg:(DWDSysMsg *)sysMsg friendId:(NSNumber *)sysId content:(NSString *)content nickName:(NSString *)nickName chatType:(DWDChatType )type success:(void(^)())insertSucess failure:(void (^)())Failure{
    
    __block BOOL success = NO;
    NSNumber *cusId;
    NSString *photoKey;
    NSNumber *badgeNum;
    // 根据Id的类型 , 插recentChat表可能是聊天cell 可能是系统cell
    
    if ([sysId isEqual:@1001] || [sysId isEqual:@1000] || [sysId isEqual:@1002]) {
        cusId = sysId;
    }else{
        if (sysMsg.entity.classId) {
            cusId = sysMsg.entity.classId;
        }else if (sysMsg.entity.groupId){
            cusId = sysMsg.entity.groupId;
        }else{
            cusId = sysMsg.entity.custId;
        }
    }
    
    photoKey = [self fetchSysPhotoKeyWithSysId:sysId];
    badgeNum = [[self getRecentChatBadgeNumWithFriendId:cusId] isEqual:nil] ? @1 : @([[self getRecentChatBadgeNumWithFriendId:cusId] integerValue] + 1);
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdateWithFormat:@"REPLACE INTO tb_recentchatlist(myCustId , custId , lastContent  ,photoKey ,nickname ,  lastCreatTime , chatType ,badgeCount ) VALUES(%@, %@, %@, %@ ,%@, %@, %@, %@ );",
                   [DWDCustInfo shared].custId, cusId , content , photoKey, nickName, sysMsg.entity.createTime , [NSNumber numberWithInteger:type] , badgeNum];
        
    }];
    
    if (success) {
        insertSucess();
    }else{
        Failure();
    }
    
}

- (NSString *)fetchSysPhotoKeyWithSysId:(NSNumber *)sysId{
    
    __block FMResultSet *rs;
    NSString *sql;
    __block NSString *photokey;
    
    sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , sysId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            photokey = [rs stringForColumn:@"photoKey"];
        }
        
        [rs close];
        
    }];
    return photokey;
}

/** 更新recentchat 的备注名*/
- (void)updateRecentChatRemarkNameWithFriendId:(NSNumber *)friendId remarkName:(NSString *)remarkName Success:(void(^)())success failure:(void (^)())Failure{
    __block BOOL isSuccess = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"UPDATE tb_recentchatlist SET remarkName = ?  WHERE myCustId = ? AND custId = ?;" , remarkName ,[DWDCustInfo shared].custId , friendId];
        
    }];
    
    if (isSuccess) {
        success();
    }else{
        Failure();
    }
    
}
/** 更新recentchat 的nickname*/
- (void)updateRecentChatNicknameWithFriendId:(NSNumber *)friendId nickname:(NSString *)nickname Success:(void(^)())success failure:(void (^)())Failure
{
    __block BOOL isSuccess = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"UPDATE tb_recentchatlist SET nickname = ?  WHERE myCustId = ? AND custId = ?;" , nickname ,[DWDCustInfo shared].custId , friendId];
        
    }];
    
    if (isSuccess) {
        success();
    }else{
        Failure();
    }
 
}
/*  -------------------------------------------------------------  */
/** 获取最近聊天会话列表 */
- (NSArray *)getRecentChatListById:(NSNumber *)custId {
    
    NSMutableArray *result = [NSMutableArray array];
    __block FMResultSet *rs;
    __block NSString *sql;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@;", custId];
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]] forKey:@"custId"];
            
            
            // 由于点击添加好友时 , 好友的很多信息会没有设置 , 所以需要判断是否有值
            if ([rs stringForColumn:@"photoKey"].length > 0) {
                [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
            }
            if ([rs stringForColumn:@"nickname"].length > 0) {
                [contact setObject:[rs stringForColumn:@"nickname"] forKey:@"nickname"];
            }
            
            if ([rs stringForColumn:@"lastContent"].length > 0) {
                [contact setObject:[rs stringForColumn:@"lastContent"] forKey:@"lastContent"];
            }
            
            
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isFriend"]] forKey:@"isFriend"];
            
            
            if ([rs stringForColumn:@"lastCreatTime"].length > 0) {
                [contact setObject:[rs stringForColumn:@"lastCreatTime"] forKey:@"lastCreatTime"];
            }
            
            
            if ([rs stringForColumn:@"type"].length > 0) {
                [contact setObject:[rs stringForColumn:@"type"] forKey:@"type"];
            }
            
            if ([rs stringForColumn:@"remarkName"] && ![[rs stringForColumn:@"remarkName"] isEqualToString:@""]) {
                [contact setObject:[rs stringForColumn:@"remarkName"] forKey:@"remarkName"];
            }
            
            if ([rs longLongIntForColumn:@"memberCount"]) {
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"memberCount"]] forKey:@"memberCount"];
            }
            
            if ([rs longLongIntForColumn:@"albumId"]) {
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"albumId"]] forKey:@"albumId"];
            }
            
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]] forKey:@"isShowNick"];
            
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"chatType"]] forKey:@"chatType"];
            
            [result addObject:contact];
        }
        
        [rs close];
    }];
    return result;
}

/*  -------------------------------------------------------------  */
/** 获取最近聊天会话列表 转发用 */
- (NSArray *)getRecentChatListByIdForRelayOnChat:(NSNumber *)custId {
    
    NSMutableArray *result = [NSMutableArray array];
    __block FMResultSet *rs;
    __block NSString *sql;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@ AND custId > 10000;", custId];
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]] forKey:@"custId"];
            
            
            // 由于点击添加好友时 , 好友的很多信息会没有设置 , 所以需要判断是否有值
            if ([rs stringForColumn:@"photoKey"].length > 0) {
                [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
            }
            if ([rs stringForColumn:@"nickname"].length > 0) {
                [contact setObject:[rs stringForColumn:@"nickname"] forKey:@"nickname"];
            }
            
            if ([rs stringForColumn:@"lastContent"].length > 0) {
                [contact setObject:[rs stringForColumn:@"lastContent"] forKey:@"lastContent"];
            }
            
            
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isFriend"]] forKey:@"isFriend"];
            
            
            if ([rs stringForColumn:@"lastCreatTime"].length > 0) {
                [contact setObject:[rs stringForColumn:@"lastCreatTime"] forKey:@"lastCreatTime"];
            }
            
            
            if ([rs stringForColumn:@"type"].length > 0) {
                [contact setObject:[rs stringForColumn:@"type"] forKey:@"type"];
            }
            
            if ([rs stringForColumn:@"remarkName"] && ![[rs stringForColumn:@"remarkName"] isEqualToString:@""]) {
                [contact setObject:[rs stringForColumn:@"remarkName"] forKey:@"remarkName"];
            }
            
            if ([rs longLongIntForColumn:@"memberCount"]) {
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"memberCount"]] forKey:@"memberCount"];
            }
            
            if ([rs longLongIntForColumn:@"albumId"]) {
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"albumId"]] forKey:@"albumId"];
            }
            
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]] forKey:@"isShowNick"];
            
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"chatType"]] forKey:@"chatType"];
            
            [result addObject:contact];
        }
        
        [rs close];
    }];
    return result;
}

/** 通过ID获取单条recentChat数据 */
- (DWDRecentChatModel *)fetchRecentChatById:(NSNumber *)custId{
    
    __block DWDRecentChatModel *recentModel;
    
    __block FMResultSet *rs;
    __block NSString *sql;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , custId];
        
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]] forKey:@"custId"];
            
            // 由于点击添加好友时 , 好友的很多信息会没有设置 , 所以需要判断是否有值
            if ([rs stringForColumn:@"photoKey"].length > 0) {
                [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
            }
            if ([rs stringForColumn:@"nickname"].length > 0) {
                [contact setObject:[rs stringForColumn:@"nickname"] forKey:@"nickname"];
            }
            
            if ([rs stringForColumn:@"lastContent"].length > 0) {
                [contact setObject:[rs stringForColumn:@"lastContent"] forKey:@"lastContent"];
            }
            
            
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isFriend"]] forKey:@"isFriend"];
            
            
            if ([rs stringForColumn:@"lastCreatTime"].length > 0) {
                [contact setObject:[rs stringForColumn:@"lastCreatTime"] forKey:@"lastCreatTime"];
            }
            
            
            if ([rs stringForColumn:@"type"].length > 0) {
                [contact setObject:[rs stringForColumn:@"type"] forKey:@"type"];
            }
            
            if ([rs stringForColumn:@"remarkName"] && ![[rs stringForColumn:@"remarkName"] isEqualToString:@""]) {
                [contact setObject:[rs stringForColumn:@"remarkName"] forKey:@"remarkName"];
            }
            
            if ([rs longLongIntForColumn:@"memberCount"]) {
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"memberCount"]] forKey:@"memberCount"];
            }
            
            if ([rs longLongIntForColumn:@"albumId"]) {
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"albumId"]] forKey:@"albumId"];
            }
            
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]] forKey:@"isShowNick"];
            
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"chatType"]] forKey:@"chatType"];
            
            recentModel = [DWDRecentChatModel yy_modelWithDictionary:contact];
        }
        
        [rs close];
    }];
    
    return recentModel;
}

/** 对最近会话表设置 是否显示其他用户昵称 */
- (void)updateRecentWithMyCustId:(NSNumber *)myCustId custId:(NSNumber *)custId isShowNick:(NSNumber *)isShowNick
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_recentchatlist SET isShowNick = ? WHERE myCustId = ? AND custId = ?;",isShowNick,myCustId,custId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
        
    }];
}

/** 查看最近会话列表是否有传入id的这个人的列表 */
//- (BOOL)haveDataInRecentChat:(NSNumber *)cusId FriendId:(NSNumber *)friendId{
//    __block FMResultSet *rs;
//    NSString *sql;
//    __block BOOL isHave = NO;
//    
//    sql = [NSString stringWithFormat:@"SELECT * FROM tb_recentchatlist WHERE myCustId = %@ AND custId = %@;", cusId , friendId];
//    
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        
//        rs = [db executeQuery:sql];
//        
//        while (rs.next) {
//            
//            isHave = YES;
//            break;
//        }
//        
//        [rs close];
//    }];
//    
//    return isHave;
//}

/** 传好友ID 删除这条recentchat记录 */
- (void)deleteRecentChatWithFriendId:(NSNumber *)friendId success:(void(^)())deleteSucess failure:(void (^)())Failure{
    
    __block BOOL success = NO;
    
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"DELETE FROM tb_recentchatlist WHERE myCustId = ? AND custId = ?;",[DWDCustInfo shared].custId, friendId];
        
    }];
    
    if (success) {
        deleteSucess();
    }else{
        Failure();
    }
    
}

/** 更新系统消息到最近联系列表 */
- (void)updateNewSystemMsgToRecentChatListWith:(DWDSystemChatMsg *)msg success:(void(^)())updateSucess failure:(void (^)())Failure{
    
    __block BOOL success = NO;
    
    NSNumber *myCusId;
    NSNumber *friendId;
    myCusId = [DWDCustInfo shared].custId;
    friendId = [DWDCustInfo shared].systemCustId;
    
    NSString *lastContent;
    lastContent = msg.content;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"UPDATE tb_recentchatlist SET myCustId = ? ,custId = ? ,lastContent = ? ,photoKey = ? ,nickname = ? ,remarkName = ? ,isFriend = ? , lastCreatTime = ?  WHERE myCustId = ? AND custId = ?;",myCusId, friendId, msg.content , @"http://educhat.oss-cn-hangzhou.aliyuncs.com/093F7C29-8714-4255-ACA7-7DA64711679C" , @"系统消息" , @"系统消息" , @1, msg.createTime , myCusId , friendId];
        
    }];
    
    if (success) {
        updateSucess();
    }else{
        Failure();
    }
}

/**
 *  插入系统消息[消息:某某某 申请加入了班级]
 *
 */
- (void)insertNewClassMemberverifyToRecentChatListWithMyCusId:(NSNumber *)myCusId
                                                       CustId:(NSNumber *)custId
                                                 lasteContent:(NSString *)lastContent
                                                     nickName:(NSString *)nickName
                                                      success:(void(^)())insertSucess
                                                      failure:(void (^)())Failure {
#warning 所有的fomater 需要做一个单例
    NSString *msgType = @"classVerify";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *createTimeStr = [dateFormatter stringFromDate:[NSDate date]];
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"REPLACE INTO tb_recentchatlist(myCustId,photoKey, custId, lastContent, nickname, lastCreatTime, type) VALUES(?, ?, ?, ? , ?, ?, ? , ?);", myCusId, @"http://educhat.oss-cn-hangzhou.aliyuncs.com/093F7C29-8714-4255-ACA7-7DA64711679C", custId, lastContent , nickName, createTimeStr, msgType ];
    }];
    
    if (success) {
        insertSucess();
    }else{
        Failure();
    }
    
}

/**  实时更新头像 */
- (void)updatePhotokeyWithCusId:(NSNumber *)cusId photokey:(NSString *)photokey success:(void(^)())updateSucess failure:(void (^)())updateFailure{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdateWithFormat:@"UPDATE tb_recentchatlist SET photokey = %@ WHERE myCustId = %@ AND custId = %@", photokey, [DWDCustInfo shared].custId , cusId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}

/** 更新lastContent */
- (void)updateLastContentWithCusId:(NSNumber *)cusId content:(NSString *)lastContent success:(void(^)())updateSucess failure:(void (^)())updateFailure{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdateWithFormat:@"UPDATE tb_recentchatlist SET lastContent = %@ WHERE myCustId = %@ AND custId = %@", lastContent, [DWDCustInfo shared].custId , cusId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}

/**  实时更新昵称 */
- (void)updateNicknameWithCusId:(NSNumber *)cusId nickname:(NSString *)nickname success:(void(^)())updateSucess failure:(void (^)())updateFailure{
    __block BOOL success = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdateWithFormat:@"UPDATE tb_recentchatlist SET nickname = %@ WHERE myCustId = %@ AND custId = %@", nickname, [DWDCustInfo shared].custId , cusId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}

@end
