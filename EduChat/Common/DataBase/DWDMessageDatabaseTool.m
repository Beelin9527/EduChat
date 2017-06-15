//
//  DWDChatSessionClient.m
//  EduChat
//
//  Created by apple on 1/8/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "DWDMessageDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"

#import "DWDChatSession.h"

#import "DWDAudioChatMsg.h"
#import "DWDTextChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDNoteChatMsg.h"
#import "DWDTimeChatMsg.h"
#import "DWDVideoChatMsg.h"
#import "DWDChatMsgReceipt.h"

#import "NSString+TableNames.h"

#import <YYModel.h>
#define DWDChatSessionTableCreatedKey @"contacts_table_created"
#define DWDChatMessageDBKey @"message_table_created"

@implementation DWDMessageDatabaseTool

DWDSingletonM(MessageDatabaseTool);

- (NSError *)buildMyError {
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Insert contact error",
                               NSLocalizedFailureReasonErrorKey:@"Insert contact error"};
    
    NSError *error = [NSError errorWithDomain:kDWDDBErrorDomain code:-1 userInfo:userInfo];
    
    return error;
}

/** 首次进入聊天界面 获取参数条数的历史消息 */
- (NSMutableArray *)fetchHistoryMessageWithToId:(NSNumber *)tid chatType:(DWDChatType)chatType fetchCount:(NSUInteger)count{
    
    NSMutableArray *results = [NSMutableArray array];
    __block FMResultSet *rs;
    __block NSString *tableName;
    __block NSString *sql;
    BOOL createSuccess;
    
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {   // 群聊
        tableName = [NSString c2mTableNameStringWithCusid:tid];
        createSuccess = [self createMessageTableWithTableName:tableName];
    }else{   //  单聊
        tableName = [NSString c2cTableNameStringWithCusid:tid];
        createSuccess = [self createMessageTableWithTableName:tableName];
    }
    if (createSuccess) {
       sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY creatTime ASC LIMIT %@;" , tableName , @(count)];
    }
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            NSData *messageData = [rs objectForColumnName:@"message"];
            NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            NSString *msgType = [rs objectForColumnName:@"msgType"];
            
            if ([msgType isEqualToString:kDWDMsgTypeText]) {
                DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                textMsg.state = [rs intForColumn:@"state"];
                textMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:textMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                audioMsg.read = [rs boolForColumn:@"isRead"];
                audioMsg.state = [rs intForColumn:@"state"];
                audioMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:audioMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                imageMsg.state = [rs intForColumn:@"state"];
                imageMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:imageMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson];
                noteMsg.noteString = [rs stringForColumn:@"noteString"];
                noteMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                noteMsg.msgType = kDWDMsgTypeNote;
                [results addObject:noteMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){
                DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                videoMsg.state = [rs intForColumn:@"state"];
                videoMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:videoMsg];
            }
        }
        [rs close];
    }];
    
    return results;
}

/** 获取数据库中最后的未读消息以下的已读消息 , 最多25条 */
- (void)fetchMsgsUntilLastMsgOfUnreadMsgsWithFriendId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)(NSArray *chatSessions))success failure:(void(^)(NSError *error))failure{
    
    NSMutableArray *results = [NSMutableArray array];
    
    __block FMResultSet *rs;
    __block NSString *tableName;
    __block NSString *sql;
    __block BOOL haveMsg = YES;
    
    // 创建聊天表格
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {   // 群聊
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        
        BOOL createSuccess = [self createMessageTableWithTableName:tableName];
        
        if (createSuccess) { // 取出来要重新排序
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime >= (SELECT creatTime FROM %@ WHERE unreadMsgCount >= 0 ORDER BY creatTime DESC LIMIT 1) ORDER BY creatTime DESC LIMIT 6;" , tableName , tableName];
        }else{
            sql = nil;
        }
        
    }else{   //  单聊
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
        
        BOOL createSuccess = [self createMessageTableWithTableName:tableName];
        
        if (createSuccess) {  // 取出来要重新排序
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime >= (SELECT creatTime FROM %@ WHERE unreadMsgCount >= 0 ORDER BY creatTime DESC LIMIT 1) ORDER BY creatTime DESC LIMIT 6;", tableName, tableName];
            
        }else{
            sql = nil;
        }
        
    }
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            haveMsg = NO;
            NSData *messageData = [rs objectForColumnName:@"message"];
            NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            NSString *msgType = [rs objectForColumnName:@"msgType"];
            
            if ([msgType isEqualToString:kDWDMsgTypeText]) {
                DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                textMsg.state = [rs intForColumn:@"state"];
                textMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:textMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                audioMsg.read = [rs boolForColumn:@"isRead"];
                audioMsg.state = [rs intForColumn:@"state"];
                audioMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:audioMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                imageMsg.state = [rs intForColumn:@"state"];
                imageMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:imageMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeTime]){
                DWDTimeChatMsg *timeMsg = [DWDTimeChatMsg yy_modelWithJSON:messageJson];
                timeMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                timeMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:timeMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson];
                noteMsg.noteString = [rs stringForColumn:@"noteString"];
                noteMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                noteMsg.msgType = kDWDMsgTypeNote;
                [results addObject:noteMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){
                DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                videoMsg.state = [rs intForColumn:@"state"];
                videoMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:videoMsg];
            }
        }
        [rs close];
    }];
    
    if (haveMsg == YES) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY creatTime DESC LIMIT 6;" , tableName];
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            rs = [db executeQuery:sql];
            
            while (rs.next) {
                NSData *messageData = [rs objectForColumnName:@"message"];
                NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
                NSString *msgType = [rs objectForColumnName:@"msgType"];
                
                if ([msgType isEqualToString:kDWDMsgTypeText]) {
                    DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                    textMsg.state = [rs intForColumn:@"state"];
                    textMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                    textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:textMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                    DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                    audioMsg.read = [rs boolForColumn:@"isRead"];
                    audioMsg.state = [rs intForColumn:@"state"];
                    audioMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                    audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:audioMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                    DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                    imageMsg.state = [rs intForColumn:@"state"];
                    imageMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                    imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:imageMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeTime]){
                    DWDTimeChatMsg *timeMsg = [DWDTimeChatMsg yy_modelWithJSON:messageJson];
                    timeMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                    timeMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:timeMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                    DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson];
                    noteMsg.noteString = [rs stringForColumn:@"noteString"];
                    noteMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                    noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    noteMsg.msgType = kDWDMsgTypeNote;
                    [results addObject:noteMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){
                    DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                    videoMsg.state = [rs intForColumn:@"state"];
                    videoMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                    videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:videoMsg];
                    
                }
            }
            [rs close];
        }];
    }
    
    if (rs != nil || rs.next) {
        success(results);
    }else {
        failure([self buildMyError]);
    }
    
}

/**向上获取数据 取到第一次遇到未读标记位置 或者达到个数为止*/
- (void)upFetchMsgsFromBeginningCreatTime:(NSNumber *)beginningCreatTime friendId:(NSNumber *)friendId chatType:(DWDChatType )chatType fetchCount:(NSNumber *)fetchCount success:(void(^)(NSMutableArray *chatSessions))success failure:(void(^)(NSError *error))failure{
    
    NSMutableArray *results = [NSMutableArray array];
    
    __block FMResultSet *rs;
    __block NSString *tableName;
    __block NSString *sql;
    __block BOOL createSuccess;
    __block NSNumber *lastCreateTimeOnDB;
    // 创建聊天表格
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {   // 群聊
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        
        createSuccess = [self createMessageTableWithTableName:tableName];
        
    }else{   //  单聊
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
        
        createSuccess = [self createMessageTableWithTableName:tableName];
        
    }
    
    if (beginningCreatTime == nil) { // 首次进聊天控制器
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            sql = [NSString stringWithFormat:@"SELECT creatTime FROM %@ ORDER BY creatTime DESC LIMIT 1" , tableName];
            rs = [db executeQuery:sql];
            while (rs.next) {
                lastCreateTimeOnDB = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
            }
        }];
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime >= (SELECT creatTime FROM %@ WHERE creatTime < %@ and unreadMsgCount >= 0 ORDER BY creatTime DESC LIMIT 1) ORDER BY creatTime DESC LIMIT %@" , tableName ,tableName,lastCreateTimeOnDB, fetchCount];
    }else{
       sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime < %@ AND creatTime >= (SELECT creatTime FROM %@ WHERE creatTime < %@ and unreadMsgCount >= 0 ORDER BY creatTime DESC LIMIT 1) ORDER BY creatTime DESC LIMIT %@" , tableName , beginningCreatTime , tableName, beginningCreatTime , fetchCount];
    }
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            NSData *messageData = [rs objectForColumnName:@"message"];
            NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            NSString *msgType = [rs objectForColumnName:@"msgType"];
            int unreadMsgCount = [rs intForColumn:@"unreadMsgCount"];
            
            if ([msgType isEqualToString:kDWDMsgTypeText]) {
                DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                textMsg.state = [rs intForColumn:@"state"];
                textMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:textMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                audioMsg.read = [rs boolForColumn:@"isRead"];
                audioMsg.state = [rs intForColumn:@"state"];
                audioMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:audioMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                imageMsg.state = [rs intForColumn:@"state"];
                imageMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:imageMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson]; // data 出来的可能是别的消息类型
                noteMsg.noteString = [rs stringForColumn:@"noteString"];
                noteMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                noteMsg.msgType = kDWDMsgTypeNote;
                [results addObject:noteMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){  // 视频
                DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                videoMsg.state = [rs intForColumn:@"state"];
                videoMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                [results addObject:videoMsg];
                
            }
            
            if (unreadMsgCount > 0) {
                break;
            }
        }
        
        if (results.count == 0) { // 在数据库中没遇到未读标记 全是Null
            NSNumber *selectTime;
            if (beginningCreatTime == nil) {
                selectTime = lastCreateTimeOnDB;
            }else{
                selectTime = beginningCreatTime;
            }
            sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime <= %@ ORDER BY creatTime DESC LIMIT %@" , tableName ,selectTime, fetchCount];
            rs = [db executeQuery:sql];
            while (rs.next) {
                NSData *messageData = [rs objectForColumnName:@"message"];
                NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
                NSString *msgType = [rs objectForColumnName:@"msgType"];
                int unreadMsgCount = [rs intForColumn:@"unreadMsgCount"];
                
                if ([msgType isEqualToString:kDWDMsgTypeText]) {
                    DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                    textMsg.state = [rs intForColumn:@"state"];
                    textMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                    textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:textMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                    DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                    audioMsg.read = [rs boolForColumn:@"isRead"];
                    audioMsg.state = [rs intForColumn:@"state"];
                    audioMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                    audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:audioMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                    DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                    imageMsg.state = [rs intForColumn:@"state"];
                    imageMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                    imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:imageMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                    DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson];
                    noteMsg.noteString = [rs stringForColumn:@"noteString"];
                    noteMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                    noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    noteMsg.msgType = kDWDMsgTypeNote;
                    [results addObject:noteMsg];
                    
                }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){  // 视频
                    DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                    videoMsg.state = [rs intForColumn:@"state"];
                    videoMsg.unreadMsgCount = [NSNumber numberWithInt:unreadMsgCount];
                    videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                    [results addObject:videoMsg];
                    
                }
                
                if (unreadMsgCount > 0) {
                    break;
                }
            }
        }
        
        [rs close];
        
    }];
    
    if (rs != nil) {
        success(results);
    }else {
        failure([self buildMyError]);
    }
}

/** 获取最后的一条消息 */
- (DWDBaseChatMsg *)fetchLastMsgWithToUser:(NSNumber *)toId chatType:(DWDChatType )chatType{
    __block FMResultSet *rs;
    __block NSString *tableName;
    __block NSString *sql;
    __block BOOL createSuccess;
    __block DWDBaseChatMsg *base;
    // 创建聊天表格
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {   // 群聊
        tableName = [NSString c2mTableNameStringWithCusid:toId];
        
        createSuccess = [self createMessageTableWithTableName:tableName];
        
    }else{   //  单聊
        tableName = [NSString c2cTableNameStringWithCusid:toId];
        
        createSuccess = [self createMessageTableWithTableName:tableName];
    }
    sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY creatTime DESC LIMIT 1" , tableName];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            NSData *messageData = [rs objectForColumnName:@"message"];
            NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            NSString *msgType = [rs objectForColumnName:@"msgType"];
            
            if ([msgType isEqualToString:kDWDMsgTypeText]) {
                DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                textMsg.state = [rs intForColumn:@"state"];
                textMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = textMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                audioMsg.read = [rs boolForColumn:@"isRead"];
                audioMsg.state = [rs intForColumn:@"state"];
                audioMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = audioMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                imageMsg.state = [rs intForColumn:@"state"];
                imageMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = imageMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeTime]){
                DWDTimeChatMsg *timeMsg = [DWDTimeChatMsg yy_modelWithJSON:messageJson];
                timeMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                timeMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = timeMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson];
                noteMsg.noteString = [rs stringForColumn:@"noteString"];
                noteMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                noteMsg.msgType = kDWDMsgTypeNote;
                base = noteMsg;
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){  // 视频
                DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                videoMsg.state = [rs intForColumn:@"state"];
                videoMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = videoMsg;
            }
        }
    }];
    
    return base;
    
}

/** 取出指定消息的上一条 非时间 提示的消息 , 可能会是note提示的消息 */
- (DWDBaseChatMsg *)upFetchChatMsgWithMsg:(DWDBaseChatMsg *)msg toUser:(NSNumber *)toId chatType:(DWDChatType )chatType{
    __block FMResultSet *rs;
    __block NSString *tableName;
    __block NSString *sql;
    __block BOOL createSuccess;
    __block DWDBaseChatMsg *base;
    // 创建聊天表格
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {   // 群聊
        tableName = [NSString c2mTableNameStringWithCusid:toId];
        
        createSuccess = [self createMessageTableWithTableName:tableName];
        
    }else{   //  单聊
        tableName = [NSString c2cTableNameStringWithCusid:toId];
        
        createSuccess = [self createMessageTableWithTableName:tableName];
    }
    sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime < %@ AND state != %@ ORDER BY creatTime DESC LIMIT 1" , tableName , msg.createTime , @(DWDChatMsgStateDeleted)];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            NSData *messageData = [rs objectForColumnName:@"message"];
            NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            NSString *msgType = [rs objectForColumnName:@"msgType"];
            
            if ([msgType isEqualToString:kDWDMsgTypeText]) {
                DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                textMsg.state = [rs intForColumn:@"state"];
                textMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = textMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                audioMsg.read = [rs boolForColumn:@"isRead"];
                audioMsg.state = [rs intForColumn:@"state"];
                audioMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = audioMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                imageMsg.state = [rs intForColumn:@"state"];
                imageMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = imageMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = [DWDNoteChatMsg yy_modelWithJSON:messageJson];
                noteMsg.noteString = [rs stringForColumn:@"noteString"];
                noteMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                noteMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                noteMsg.msgType = kDWDMsgTypeNote;
                base = noteMsg;
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){  // 视频
                DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                videoMsg.state = [rs intForColumn:@"state"];
                videoMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                base = videoMsg;
            }
        }
    }];
    
    return base;
    
}

- (void)resetMsgUnreadCountToNullWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType msgId:(NSString *)msgId success:(void(^)())success{
    __block BOOL isSuccess = NO;
    NSString *tableName;
    NSString *sql;
    
    // 创建聊天表格
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) { // 群聊
        tableName = [NSString c2mTableNameStringWithCusid:tid];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:tid];
    }
    
    [self createMessageTableWithTableName:tableName];
    
    sql = [NSString stringWithFormat:@"UPDATE %@ ", tableName];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdateWithFormat:[sql stringByAppendingString:@"SET unreadMsgCount = %@ WHERE msgId = %@;"], nil , msgId];
    }];
    
    if (isSuccess) {
        success();
    }
    
}

/** 重置未读标记为 Null  */
- (void)resetMsgUnreadCountToNull:(DWDBaseChatMsg *)msg success:(void(^)())success failure:(void(^)(NSError *error))failure{
    __block BOOL isSuccess = NO;
    NSNumber *friendId;
    NSString *tableName;
    NSString *sql;
    
    // 创建聊天表格
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = msg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        
    }else{
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = msg.toUser;
        }else{  // 别人发的
            friendId = msg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    [self createMessageTableWithTableName:tableName];
    
    sql = [NSString stringWithFormat:@"UPDATE %@ ", tableName];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdateWithFormat:[sql stringByAppendingString:@"SET unreadMsgCount = %@ WHERE creatTime = %@;"], nil , msg.createTime];
    }];
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
}

/** 插入时间模型, 到指定消息模型的ID上面 */
- (void)insertTimeMsg:(DWDTimeChatMsg *)timeChatMsg AboveMsg:(DWDBaseChatMsg *)baseMsg success:(void(^)())success failure:(void(^)(NSError *error))failure{
    
    __block BOOL isSuccess = NO;
    __block NSData *data;
    NSNumber *friendId;
    NSString *tableName;
    // 创建聊天表格
    
    if (baseMsg.chatType == DWDChatTypeClass || baseMsg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = baseMsg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
    }else{
        if ([baseMsg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = baseMsg.toUser;
        }else{  // 别人发的
            friendId = baseMsg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    data = [timeChatMsg yy_modelToJSONData];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        NSString *insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
        isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,msgId, state) VALUES ( %@ ,%@, %@, %@, %@ , %@ , %@);"], data , timeChatMsg.fromUser , timeChatMsg.toUser , timeChatMsg.createTime , timeChatMsg.msgType , timeChatMsg.msgId,@(timeChatMsg.state)];
        
        DWDLog(@"自己发消息时插入时间模型到表1次 , 并更新了以下所有的OrderId");
    }];
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
    
}


// 插入新消息到数据库 (一条)
- (void)addMsgToDBWithMsg:(DWDBaseChatMsg *)msg success:(void(^)())success failure:(void(^)(NSError *error))failure{
    
    __block BOOL isSuccess = NO;
    __block NSData *data;
    NSNumber *friendId;
    NSNumber *remarkFriendId;
    NSString *tableName;
    // 创建聊天表格
    
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = msg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        remarkFriendId = msg.fromUser;
    }else{
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = msg.toUser;
            remarkFriendId = msg.toUser;
        }else{  // 别人发的
            friendId = msg.fromUser;
            remarkFriendId = msg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    NSString *remarkName = [[DWDContactsDatabaseTool sharedContactsClient] getRemarkNameWithFriendId:remarkFriendId];
    BOOL createSuccess = [self createMessageTableWithTableName:tableName];
    __block NSString *insertSql;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (createSuccess) {
            if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
                
                DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
                data = [textMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , remarkName ,msgId, state ) VALUES ( %@ ,%@ , %@, %@, %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入文本模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
                
                DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
                
                data = [audioMsg yy_modelToJSONData];
                
                if ([audioMsg.fromUser isEqual:[DWDCustInfo shared].custId]) {
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , duration , isRead , remarkName,msgId , state) VALUES (%@ ,%@, %@, %@ , %@ , %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , @1 ,remarkName , msg.msgId , @(msg.state)];
                }else{
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , duration , isRead , remarkName,msgId , state ) VALUES (%@ ,%@, %@, %@ , %@ , %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , @0 ,remarkName , msg.msgId , @(msg.state)];
                }
                
                DWDLog(@"插入音频模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
                
                DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
                data = [imageMsg yy_modelToJSONData];
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state) VALUES (%@ , %@, %@, %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入图片模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeTime]){
                DWDTimeChatMsg *timeMsg = (DWDTimeChatMsg *)msg;
                data = [timeMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state) VALUES (%@, %@, %@, %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId,@(msg.state)];
                
                DWDLog(@"插入时间模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)msg;
                data = [noteMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , noteString , remarkName ,msgId, state) VALUES (%@ , %@, %@, %@ , %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , noteMsg.noteString ,remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入提示模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]) { // --fzg
                
                DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)msg;
                data = [videoMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state ) VALUES ( %@ ,%@ , %@, %@, %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入视频模型到表1次");
                
            }
            

            
        }
    }];
    
    if (isSuccess) {
        success();
    }else {
        failure([self buildMyError]);
    }
    
}

/** 批量添加消息到数据库 */
- (void)addMsgsToDBWithMsgs:(NSArray *)msgs success:(void(^)())success failure:(void(^)(NSError *error))failure{
    
    BOOL __block isSuccess = NO;
    __block NSData *data;
    NSNumber *friendId;
    NSNumber *remarkFriendId;
    NSString *tableName;
    NSString __block *insertSql = @"";
    
    for (int i = 0; i < msgs.count; i++) {
        DWDBaseChatMsg *msg = msgs[i];
        // 创建聊天表格
        if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
            friendId = msg.toUser;
            remarkFriendId = msg.fromUser;
            tableName = [NSString c2mTableNameStringWithCusid:friendId];
            
        }else{
            if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
                friendId = msg.toUser;
                remarkFriendId = msg.toUser;
            }else{  // 别人发的
                friendId = msg.fromUser;
                remarkFriendId = msg.fromUser;
            }
            
            tableName = [NSString c2cTableNameStringWithCusid:friendId];
        }
        
        NSString *remarkName = [[DWDContactsDatabaseTool sharedContactsClient] getRemarkNameWithFriendId:remarkFriendId];
        
        [self createMessageTableWithTableName:tableName];
        
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            
            if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
                
                DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
                data = [textMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , remarkName ,msgId, state) VALUES (%@ ,%@ ,%@, %@, %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType,remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入文本模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
                
                DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
                
                data = [audioMsg yy_modelToJSONData];
                
                if ([audioMsg.fromUser isEqual:[DWDCustInfo shared].custId]) {
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , duration , isRead , remarkName ,msgId, state) VALUES (%@ ,%@, %@, %@ , %@ , %@ , %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , @1 ,remarkName , msg.msgId , @(msg.state)];
                }else{
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , duration , isRead ,remarkName ,msgId, state) VALUES (%@ ,%@ ,%@ ,%@, %@, %@ , %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , @0 ,remarkName , msg.msgId , @(msg.state)];
                }
                
                DWDLog(@"插入音频模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
                
                DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
                data = [imageMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state) VALUES ( %@ ,%@ ,%@ ,%@, %@, %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId ,@(msg.state)];
                
                DWDLog(@"插入图片模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeTime]){
                DWDTimeChatMsg *timeMsg = (DWDTimeChatMsg *)msg;
                data = [timeMsg yy_modelToJSONData];
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId , state) VALUES ( %@ ,%@ ,%@ ,%@, %@, %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入时间模型到表1次");
                
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)msg;
                data = [noteMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , noteString ,remarkName ,msgId , state) VALUES ( %@ ,%@, %@ ,%@, %@, %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , noteMsg.noteString ,remarkName , msg.msgId , @(msg.state)];
                
                DWDLog(@"插入提示模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]) { // --fzg
                
                DWDVideoChatMsg *imageMsg = (DWDVideoChatMsg *)msg;
                data = [imageMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state) VALUES (%@ ,%@ ,%@, %@, %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId ,@(msg.state)];
                
                DWDLog(@"插入视频模型到表1次");
                
            }
            
            if (!isSuccess) {
                failure([self buildMyError]);
                return;
            }
        }];
        
    }
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
    
}

/**  添加所有的未读消息的 <<最后那条>> 到数据库 ,并标记好未读字段 */
- (void)addLastMsgsOfUnreadMsg:(NSArray *)lastMsgOfUnreadArray success:(void(^)())success failure:(void(^)(NSError *error))failure{
    BOOL __block isSuccess = NO;
    __block NSData *data;
    NSNumber *friendId;
    NSNumber *remarkFriendId;
    NSString *tableName;
    NSString __block *insertSql = @"";
    
    for (int i = 0; i < lastMsgOfUnreadArray.count; i++) {
        DWDBaseChatMsg *msg = lastMsgOfUnreadArray[i];
        // 创建聊天表格
        if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
            friendId = msg.toUser;
            remarkFriendId = msg.fromUser;
            tableName = [NSString c2mTableNameStringWithCusid:friendId];
            
        }else{
            if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
                friendId = msg.toUser;
                remarkFriendId = msg.toUser;
            }else{  // 别人发的
                friendId = msg.fromUser;
                remarkFriendId = msg.fromUser;
            }
            
            tableName = [NSString c2cTableNameStringWithCusid:friendId];
        }
        
        [self createMessageTableWithTableName:tableName];
        
        NSString *remarkName = [[DWDContactsDatabaseTool sharedContactsClient] getRemarkNameWithFriendId:remarkFriendId];
        
        NSNumber *unreadCount = @([msg.unreadMsgCount integerValue] - 1);  // 服务器返回的 多次未读的消息 累加的总数
        
        
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            
            if (![db tableExists:tableName]) {   // 如果用户下载过软件, 离线状态有人给他发消息 , 还没收这部分消息又删了软件 , 再次下载时需要重新建表
                NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, message BLOB NOT NULL, fromId INTEGER , toId INTEGER ,msgId TEXT UNIQUE , state INTEGER ,creatTime INTEGER , msgType TEXT , noteString TEXT , duration INTEGER , isRead INTEGER , remarkName TEXT ,  unreadMsgCount INTEGER);",tableName];
                [db executeUpdate:sql];
            }
            
            if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
                
                DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
                data = [textMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , remarkName ,msgId, state , unreadMsgCount) VALUES ( %@ ,%@ ,%@, %@, %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType,remarkName , msg.msgId , @(msg.state) , unreadCount];
                
                DWDLog(@"插入文本模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
                
                DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
                
                data = [audioMsg yy_modelToJSONData];
                
                if ([audioMsg.fromUser isEqual:[DWDCustInfo shared].custId]) {
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , duration , isRead , remarkName ,msgId, state , unreadMsgCount) VALUES ( %@ ,%@ ,%@, %@, %@ , %@ , %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , @1 ,remarkName , msg.msgId , @(msg.state)  , unreadCount];
                }else{
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , duration , isRead ,remarkName ,msgId, state, unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@ ,%@, %@, %@ , %@ , %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , @0 ,remarkName , msg.msgId , @(msg.state) , unreadCount];
                }
                
                DWDLog(@"插入音频模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
                
                DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
                data = [imageMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@ ,%@, %@, %@ , %@ ,%@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId ,@(msg.state)  , unreadCount];
                
                DWDLog(@"插入图片模型到表1次");
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeTime]){
                DWDTimeChatMsg *timeMsg = (DWDTimeChatMsg *)msg;
                data = [timeMsg yy_modelToJSONData];
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId , state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@ ,%@, %@, %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state) , unreadCount];
                
                DWDLog(@"插入时间模型到表1次");
                
            }else if ([msg.msgType isEqualToString:kDWDMsgTypeNote]){
                DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)msg;
                data = [noteMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType , noteString ,remarkName ,msgId , state  , unreadMsgCount) VALUES ( %@ , %@ ,%@, %@ ,%@, %@, %@ , %@ ,%@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , noteMsg.noteString ,remarkName , msg.msgId , @(msg.state) , unreadCount];
                
                DWDLog(@"插入提示模型到表1次");
                
            }
            else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]){   //视频
                DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)msg;
                data = [videoMsg yy_modelToJSONData];
                
                insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId, state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@ ,%@, %@, %@ , %@ ,%@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId ,@(msg.state)  , unreadCount];
                
                DWDLog(@"插入视频模型到表1次");
            }
            
            if (!isSuccess) {
                failure([self buildMyError]);
                return;
            }
        }];
        
    }
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
}

- (void)updateAudioMessageTbWithMsg:(DWDAudioChatMsg *)msg success:(void(^)())success failure:(void(^)(NSError *error))failure{
    
    __block BOOL isSuccess = NO;
    NSNumber *friendId;
    NSString *tableName;
    NSString *sql;
    
    
    // 创建聊天表格
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = msg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        
    }else{
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = msg.toUser;
        }else{  // 别人发的
            friendId = msg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    [self createMessageTableWithTableName:tableName];
    
    sql = [NSString stringWithFormat:@"UPDATE %@ ", tableName];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdateWithFormat:[sql stringByAppendingString:@"SET isRead = %@ WHERE creatTime = %@ AND duration = %@;"], [NSNumber numberWithBool:msg.isRead] , msg.createTime , msg.duration];
    }];
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
}

/** 向上找时间消息 查看是否超出指定时间 msg用于创建表格 和判断时间时候超出*/
- (BOOL)upFindTimeMsgBeyond5MinuteWithmsg:(DWDBaseChatMsg *)msg isUnreadMsg:(BOOL)isUnread beyondTime:(NSTimeInterval)beyondTime{
    
    NSString *tableName;
    NSNumber *friendId;
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = msg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        
    }else{
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = msg.toUser;
        }else{  // 别人发的
            friendId = msg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    // 倒序取出第一个时间模型
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE msgType = '%@' ORDER BY creatTime DESC LIMIT 1;" , tableName , kDWDMsgTypeTime];
    
    __block FMResultSet *rs;
    
    __block NSNumber *lastCreateTime = nil;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        rs = [db executeQuery:sql];
        while ([rs next]) {  // 数据库里有
            lastCreateTime = @([rs longLongIntForColumn:@"creatTime"]);
        }
        [rs close];
    }];
    
//    if (isUnread) {  // 如果是获取下来的未读消息 判断是否超过5分钟应该使用未读消息的创建时间
//        lastCreateTime = msg.createTime;
//    }
    
    NSTimeInterval timeDelta;
    
    if (lastCreateTime == nil) { // 数据库里一条时间提示都没有
        timeDelta = MAXFLOAT;
        
    }else{  // 取出了最后一条时间数据
        double aTimeStamp = [msg.createTime longLongValue] / 1000.0;
        timeDelta = aTimeStamp - [lastCreateTime longLongValue] / 1000.0;
    }
    
    DWDLog(@"数据库取出的最后一条时间消息的时间戳 : %lld" , [lastCreateTime longLongValue]);
    
    if (timeDelta > beyondTime) {
        return YES;
    }else{
        return NO;
    }
}


/** 向上找时间模型, 根据指定的时间戳 , 返回是否超过beyondTime */
- (BOOL)upFindOutTimeMsgDESCOrderByCreateTimeLessThanTimeStamp:(NSNumber *)createTime tableName:(DWDBaseChatMsg *)msg{
    
    NSString *tableName;
    NSNumber *friendId;
    NSTimeInterval beyongdTime;
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = msg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        beyongdTime = 60;
    }else{
        beyongdTime = 180;
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = msg.toUser;
        }else{  // 别人发的
            friendId = msg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime < %@ AND msgType = '%@' ORDER BY creatTime DESC LIMIT 1;",tableName , createTime , kDWDMsgTypeTime];
    
    __block long long timeStamp;
    __block FMResultSet *rs;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            timeStamp = [rs longLongIntForColumn:@"creatTime"];
        }
        
        [rs close];
    }];
    
    if (([createTime longLongValue] - timeStamp) / 1000.0 > beyongdTime) {
        return YES;
    }else{
        return NO;
    }
    
}

/** 插入所有未读消息到  消息数据表 */
- (void)insertUnreadMsgToDBWithMsg:(NSArray *)msgs success:(void(^)())success failure:(void(^)(NSError *error))failure{
    
    __block BOOL isSuccess = NO;
    
    for (int i = 0; i < msgs.count; i++) {
        DWDBaseChatMsg *msg = msgs[i];
        
        NSNumber *friendId;
        NSNumber *remarkFriendId;
        NSString *tableName;
        __block NSString *insertSql;
        
        // 创建聊天表格
        
        if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
            friendId = msg.toUser;
            remarkFriendId = msg.fromUser;
            tableName = [NSString c2mTableNameStringWithCusid:friendId];
            
        }else{
            if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
                friendId = msg.toUser;
                remarkFriendId = msg.toUser;
            }else{  // 别人发的
                friendId = msg.fromUser;
                remarkFriendId = msg.fromUser;
            }
            
            tableName = [NSString c2cTableNameStringWithCusid:friendId];
        }
        
        NSString *remarkName = [[DWDContactsDatabaseTool sharedContactsClient] getRemarkNameWithFriendId:remarkFriendId];
        
        BOOL createSuccess = [self createMessageTableWithTableName:tableName];
        // 建立对应的表
        
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            
            if (createSuccess) {
                if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
                    
                    DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msg;
                    NSData *data = [textMsg yy_modelToJSONData];
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName , msgId, state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@, %@, %@, %@ , %@ , %@);"],  data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state) , msg.unreadMsgCount];
                    
                }else if ([msg.msgType isEqualToString:kDWDMsgTypeImage]){
                    
                    DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msg;
                    NSData *data = [imageMsg yy_modelToJSONData];
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"( message, fromId , toId , creatTime , msgType ,remarkName , msgId, state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@, %@, %@, %@ , %@ , %@);"],  data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state) , msg.unreadMsgCount];
                    
                }else if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]){
                    
                    DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msg;
                    NSData *data = [audioMsg yy_modelToJSONData];
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"( message, fromId , toId , creatTime , msgType , duration , isRead ,remarkName , msgId , state , unreadMsgCount) VALUES ( %@ , %@ , %@ , %@ ,%@ ,%@, %@, %@, %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType , audioMsg.duration , [NSNumber numberWithBool:audioMsg.isRead] , remarkName , msg.msgId , @(msg.state) , msg.unreadMsgCount];
                    
                }else if ([msg.msgType isEqualToString:kDWDMsgTypeVideo]){ //视频
                    
                    DWDVideoChatMsg *imageMsg = (DWDVideoChatMsg *)msg;
                    NSData *data = [imageMsg yy_modelToJSONData];
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"( message, fromId , toId , creatTime , msgType ,remarkName , msgId, state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@, %@, %@, %@ , %@ , %@);"],  data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state) , msg.unreadMsgCount];
                    
                }else if ([msg.msgType isEqualToString:kDWDMsgTypeTime]){
                    
                    DWDTimeChatMsg *timeMsg = (DWDTimeChatMsg *)msg;
                    NSData *data = [timeMsg yy_modelToJSONData];
                    insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", tableName];
                    isSuccess = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"(message, fromId , toId , creatTime , msgType ,remarkName ,msgId , state , unreadMsgCount) VALUES ( %@ , %@ ,%@ ,%@ ,%@, %@, %@ , %@ , %@);"], data , msg.fromUser , msg.toUser , msg.createTime , msg.msgType ,remarkName , msg.msgId , @(msg.state) , msg.unreadMsgCount];
                    
                    DWDLog(@"插入未读消息时 , 插入时间模型到表1次");
                }
                
                if (isSuccess == NO) {  // 中间一旦插入错误 , 则返回
                    
                    failure([self buildMyError]);
                    return ;
                }
            }
            
        }];
        
    }
    
    if (isSuccess) {
        success();  // 循环结束 , 回调成功block
    }
}

- (BOOL)createMessageTableWithTableName:(NSString *)tbName{
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT, message BLOB NOT NULL, fromId INTEGER , toId INTEGER ,msgId TEXT UNIQUE , state INTEGER ,creatTime INTEGER , msgType TEXT , noteString TEXT , duration INTEGER , isRead INTEGER , remarkName TEXT ,  unreadMsgCount INTEGER);",tbName];
    // 建立对应的表 ,
    __block BOOL createSuccess = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        createSuccess = [db executeUpdate:sql];
    }];
    
    if (createSuccess) {
        return YES;
    }else{
        return NO;
    }
}


- (void)deleteMessageWithId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE (fromId = %@ AND toId = %@) OR (fromId = %@ AND toId = %@);", tableName , [DWDCustInfo shared].custId , friendId , friendId , [DWDCustInfo shared].custId];
    __block BOOL deleteSuccess = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        deleteSuccess = [db executeUpdate:sql];
    }];
    
    if (deleteSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
}

/** 只做逻辑删除  state 赋值 99 */
- (void)deleteMessageWithFriendId:(NSNumber *)friendId msgs:(NSArray *)msgs chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    NSString *sql;
    __block BOOL deleteSuccess = NO;
    for (int i = 0; i< msgs.count; i++) {
        DWDBaseChatMsg *baseMsg = msgs[i];
        
        sql = [NSString stringWithFormat:@"UPDATE %@ SET state = %@ WHERE msgId = '%@';", tableName ,@(DWDChatMsgStateDeleted) ,baseMsg.msgId];
        
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            deleteSuccess = [db executeUpdate:sql];
        }];
    }
    
    if (deleteSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
}

/** 撤回消息 , 修改msgType 和NoteString */
- (void)revokeMsgWithNoteString:(NSString *)string revokedMsgId:(NSString *)msgId friendId:(NSNumber *)friendId chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    NSString *sql;
    __block BOOL revokeSuccess = NO;
    sql = [NSString stringWithFormat:@"UPDATE %@ SET msgType = '%@',noteString = '%@' WHERE msgId = '%@';" , tableName , kDWDMsgTypeNote , string , msgId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        revokeSuccess = [db executeUpdate:sql];
    }];
    if (revokeSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
}

/** 删除消息 传被删除的消息 自动判断是否删除数据库中的时间提示*/
//- (void)deleteMessageAndJudgeShouldTimeNoteDeleteWithFriendId:(NSNumber *)friendId msg:(DWDBaseChatMsg *)msg chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure{
//    NSString *tableName;
//    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
//        tableName = [NSString c2mTableNameStringWithCusid:friendId];
//    }else{
//        tableName = [NSString c2cTableNameStringWithCusid:friendId];
//    }
//    NSString *sql;
//    __block BOOL deleteSuccess = NO;
//    __block FMResultSet *rs;
//    
//    __block NSString *backWardMsgType;
//    __block BOOL isLastMsg = YES;
//    
//    __block long long backWardCreateTime;
//    __block long long forWardCreateTime;
//    
//    __block NSString *backWardMsgId;
//    
//    // 取出被删除消息的上一条消息
//    sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime < %@ ORDER BY creatTime DESC LIMIT 1;", tableName ,msg.createTime];
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        rs = [db executeQuery:sql];
//        while (rs.next) {
//            backWardMsgType = [rs stringForColumn:@"msgType"];
//            backWardCreateTime = [rs longLongIntForColumn:@"creatTime"];
//            backWardMsgId = [rs stringForColumn:@"msgId"];
//        }
//    }];
//    
//    // 判断被删除消息是否是最后一条消息
//    sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime > %@ ;", tableName ,msg.createTime];
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        rs = [db executeQuery:sql];
//        while (rs.next) {
//            isLastMsg = NO;
//        }
//    }];
//    
//    // 取出被删除消息的下一条消息
//    sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE creatTime > %@ and msgtype != 'time' ORDER BY creatTime ASC LIMIT 1;", tableName ,msg.createTime];
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        rs = [db executeQuery:sql];
//        while (rs.next) {
//            forWardCreateTime = [rs longLongIntForColumn:@"creatTime"];
//        }
//    }];
//    
//    if ([backWardMsgType isEqualToString:@"time"]) { // 上一条消息的msgType是时间提示
//        if (isLastMsg == NO) {  // 并且不是最后一条消息
//            NSTimeInterval timeInterval = msg.chatType == DWDChatTypeFace ? 180 : 120;
//            if (forWardCreateTime / 1000 - [msg.createTime longLongValue] / 1000 < timeInterval) {  // 不删除时间 , 仅删除消息
//                
//                sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = '%@';", tableName ,msg.msgId];
//                
//                [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//                    deleteSuccess = [db executeUpdate:sql];
//                }];
//                
//            }else{  // 删除时间 , 和消息
//                sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = '%@' OR msgId = '%@';", tableName ,backWardMsgId , msg.msgId];
//                
//                [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//                    deleteSuccess = [db executeUpdate:sql];
//                }];
//                
//            }
//        }else{ // 被删除的是最后一条消息 时间消息一起删除
//            sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = '%@' OR msgId = '%@';", tableName ,backWardMsgId , msg.msgId];
//            
//            [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//                deleteSuccess = [db executeUpdate:sql];
//            }];
//        }
//    }else{ // 上一条消息不是时间提示 直接删除消息
//        sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msgId = '%@';", tableName ,msg.msgId];
//        
//        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//            deleteSuccess = [db executeUpdate:sql];
//        }];
//    }
//    
//    
//    if (deleteSuccess) {
//        success();
//    }else{
//        failure([self buildMyError]);
//    }
//}

/** 判断是否还有聊天记录 */
- (BOOL)JudgeChatRecordExistWithLastMsg:(DWDBaseChatMsg *)msg{
    
    NSString *tableName;
    NSNumber *friendId;
    __block FMResultSet *rs;
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) { // 群聊
        friendId = msg.toUser;
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
        
    }else{
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) {  // 自己发
            friendId = msg.toUser;
        }else{  // 别人发的
            friendId = msg.fromUser;
        }
        
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    
    BOOL createSuccess = [self createMessageTableWithTableName:tableName];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE msgType != 'time' AND msgType != 'note' ", tableName];
    __block BOOL isSuccess;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        if (createSuccess) {
            rs = [db executeQuery:sql];
            while (rs.next) {
                DWDLog(@"");
            }
        }
        
    }];
    
    return isSuccess;
    
}

/** 更新消息的发送状态 */
- (void)updateMsgStateToState:(DWDChatMsgState )state WithMsgId:(NSString *)msgId toUserId:(NSNumber *)toUser chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:toUser];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:toUser];
    }
    
    BOOL createSuccess = [self createMessageTableWithTableName:tableName];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ ", tableName];
    __block BOOL isSuccess;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        if (createSuccess) {
            isSuccess = [db executeUpdateWithFormat:[sql stringByAppendingString:@"SET state = %@ WHERE msgId = %@;"], @(state) , msgId];
        }
        
    }];
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
    
}

/** 根据回执 , 更新消息的发送状态 和timeStamp */
- (void)updateMsgStateToState:(DWDChatMsgState )state WithMsgReceipt:(DWDChatMsgReceipt *)receipt chatType:(DWDChatType )chatType success:(void(^)())success failure:(void(^)(NSError *error))failure{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:receipt.toUser];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:receipt.toUser];
    }
    
    BOOL createSuccess = [self createMessageTableWithTableName:tableName];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ ", tableName];
    __block BOOL isSuccess;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        if (createSuccess) {
            isSuccess = [db executeUpdateWithFormat:[sql stringByAppendingString:@"SET state = %@ , creatTime = %@ WHERE msgId = %@;"], @(state) ,receipt.createTime ,receipt.msgId];
        }
        
    }];
    
    if (isSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
    
}

/** 取出消息的发送状态 */
- (DWDChatMsgState)fetchMessageSendingStateWithToId:(NSNumber *)toId MsgId:(NSString *)msgId chatType:(DWDChatType )chatType{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:toId];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:toId];
    }
    
    [self createMessageTableWithTableName:tableName];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT state FROM %@ WHERE msgId = ?;", tableName];
    
    __block FMResultSet *rs;
    __block DWDChatMsgState state;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql , msgId];
        if (rs.next) {
            state = [rs intForColumn:@"state"];
        }else{
            state = -1;
        }
        [rs close];
    }];
    
    return state;
}

/** 取出一条消息 , 根据msgId */
- (DWDBaseChatMsg *)fetchMessageWithToId:(NSNumber *)toId MsgId:(NSString *)msgId chatType:(DWDChatType )chatType{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:toId];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:toId];
    }
    
    [self createMessageTableWithTableName:tableName];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE msgId = ?;", tableName];
    
    __block FMResultSet *rs;
    __block DWDBaseChatMsg *msg;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql , msgId];
        if (rs.next) {  // gggggggggg
            NSData *messageData = [rs objectForColumnName:@"message"];
            NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            NSString *msgType = [rs objectForColumnName:@"msgType"];
            
            if ([msgType isEqualToString:kDWDMsgTypeText]) {
                DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithJSON:messageJson];
                textMsg.state = [rs intForColumn:@"state"];
                textMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                textMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                msg = textMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){
                DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithJSON:messageJson];
                audioMsg.read = [rs boolForColumn:@"isRead"];
                audioMsg.state = [rs intForColumn:@"state"];
                audioMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                audioMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                msg = audioMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){
                DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithJSON:messageJson];
                imageMsg.state = [rs intForColumn:@"state"];
                imageMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                imageMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                msg = imageMsg;
                
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){
                DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithJSON:messageJson];
                videoMsg.state = [rs intForColumn:@"state"];
                videoMsg.unreadMsgCount = [NSNumber numberWithInt:[rs intForColumn:@"unreadMsgCount"]];
                videoMsg.createTime = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"creatTime"]];
                msg = videoMsg;
            }
        }
        [rs close];
    }];
    
    return msg;
}


#pragma mark - Delete
/**
 * 删除聊天记录 整张表
 */
- (void)deleteMessageTableWithFriendId:(NSNumber *)friendId
                              chatType:(DWDChatType )chatType
                               success:(void(^)())success
                               failure:(void(^)(NSError *error))failure
{
    NSString *tableName;
    if (chatType == DWDChatTypeClass || chatType == DWDChatTypeGroup) {
        tableName = [NSString c2mTableNameStringWithCusid:friendId];
    }else{
        tableName = [NSString c2cTableNameStringWithCusid:friendId];
    }
    NSString *sql;
    __block BOOL deleteSuccess = NO;
    
    sql = [NSString stringWithFormat:@"DROP TABLE %@;", tableName];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        deleteSuccess = [db executeUpdate:sql];
    }];
    
    
    if (deleteSuccess) {
        success();
    }else{
        failure([self buildMyError]);
    }
    
}
@end

