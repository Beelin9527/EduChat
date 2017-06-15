//
//  DWDContactsClient.m
//  EduChat
//
//  Created by apple on 12/7/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "DWDContactsDatabaseTool.h"
#import "HttpClient.h"
#import "DWDBaseChatMsg.h"


#import "DWDSystemChatMsg.h"
#import "DWDOfflineMsg.h"

#import "NSString+extend.h"

#import "DWDContactModel.h"
#import "DWDTempContactModel.h"
#import "DWDGroupEntity.h"
#import "DWDClassModel.h"
#define DWDContactsLastUpdateKey @"contacts_last_update_key"
#define DWDSysMsgTableCreatedKey @"DWDSysMsgTableCreatedKey"


@interface DWDContactsDatabaseTool ()

@property (strong, nonatomic) HttpClient *httpApiClient;

@end

@implementation DWDContactsDatabaseTool

DWDSingletonM(ContactsClient)

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _httpApiClient = [HttpClient sharedClient];
        [self createContactsTable];
    }
    
    return self;
}


#pragma Create Table
/**
 创建联系人表、群组表、班级表
 */

- (void)createContactsTable
{
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS tb_contacts (\
                        id INTEGER PRIMARY KEY AUTOINCREMENT,\
                        myCustId        INTEGER ,\
                        custId          INTEGER UNIQUE,\
                        isFriend        INTEGER,\
                        nickname        TEXT,\
                        remarkName      TEXT,\
                        photoKey        TEXT,\
                        level           INTEGER,\
                        state           INTEGER,\
                        custType        INTEGER);"] &&
        
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS tb_groups (\
                         id INTEGER PRIMARY KEY AUTOINCREMENT,\
                         myCustId       INTEGER,\
                         groupId        INTEGER UNIQUE,\
                         groupName      TEXT,\
                         nickname       TEXT,\
                         memberCount    INTEGER,\
                         photoKey       TEXT,\
                         level          INTEGER,\
                         isMian         INTEGER,\
                         state          INTEGER,\
                         isShowNick     INTEGER,\
                         isExist        INTEGER,\
                         isSave         INTEGER);"] &&
        
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS tb_classes (\
                         id INTEGER PRIMARY KEY AUTOINCREMENT,\
                         myCustId       INTEGER, \
                         classId        INTEGER UNIQUE,\
                         className      TEXT,\
                         memberCount    INTEGER,\
                         photoKey       TEXT,\
                         level          INTEGER,\
                         isMian         INTEGER,\
                         isManager      INTEGER,\
                         state          INTEGER ,\
                         albumId        INTEGER ,\
                         isShowNick     INTEGER,\
                         classAcct      INTEGER,\
                         introduce      TEXT,\
                         isExist        INTEGER,\
                         schoolId       INTEGER,\
                         schoolName     TEXT,\
                        nickname        TEXT);"];
        
        
        //                添加系统消息 custID 10000 为默认好友
        //                myCustId INTEGER, custId INTEGER, isFriend INTEGER, nickname TEXT, remarkName TEXT, photoKey TEXT, level INTEGER, state INTEGER
        
        success = [db executeUpdate:@"REPLACE INTO tb_contacts( myCustId , custId , isFriend , nickname , remarkName , photoKey , level , state , custType) VALUES(?,?, ?, ?, ?, ?, ? , ? , ?);",
                   [DWDCustInfo shared].custId, @1000, @1 , @"消息中心", @"消息中心", @"http://educhat.oss-cn-hangzhou.aliyuncs.com/093F7C29-8714-4255-ACA7-7DA64711679C", @1, @2 , @0];
        
        
        success = [db executeUpdate:@"REPLACE INTO tb_contacts ( myCustId , custId , isFriend , nickname , remarkName , photoKey , level , state , custType) VALUES(?,?, ?, ?, ?, ?, ? , ? , ?);",
                   [DWDCustInfo shared].custId, @1001, @1 , @"接送中心", @"接送中心", @"http://educhat.oss-cn-hangzhou.aliyuncs.com/6351EDFA-9F25-4F17-A791-9EAD6E4FE18B", @1, @2 , @0];

        success = [db executeUpdate:@"REPLACE INTO tb_contacts ( myCustId , custId , isFriend , nickname , remarkName , photoKey , level , state , custType) VALUES(?,?, ?, ?, ?, ?, ? , ? , ?);",
                   [DWDCustInfo shared].custId, @1002, @1 , @"智能办公", @"智能办公", @"http://educhat.oss-cn-hangzhou.aliyuncs.com/icon_office_msg.png", @1, @2 , @0];
        
    }];

}

- (void)reCreateTables
{
    [self createContactsTable];
}


#pragma mark - Add
- (void)groupTableAddElement:(NSString *)column{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (![db columnExists:column inTableWithName:@"tb_groups"]) {
            NSString *sql;
            if ([column isEqualToString:@"isSave"]) {
                //            alter table test add column isSave integer default 1
                sql = @"ALTER TABLE tb_groups ADD COLUMN isSave INTEGER DEFAULT 1;";
            } else {
            sql = [NSString stringWithFormat:@"ALTER TABLE tb_groups ADD %@ INTEGER",column];
            }
            [db executeUpdate:sql];
        }
    }];
}

- (void)classTableAddElement:(NSString *)column{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (![db columnExists:column inTableWithName:@"tb_classes"]) {
            NSString *sql;
            if ([column isEqualToString:@"schDel"]) {
                //            alter table test add column isSave integer default 1
                sql = @"ALTER TABLE tb_classes ADD COLUMN schDel INTEGER DEFAULT 0;";
            } else {
                sql = [NSString stringWithFormat:@"ALTER TABLE tb_classes ADD %@ INTEGER",column];
            }
            [db executeUpdate:sql];
        }
    }];
}

#pragma mark - Insert
/**  添加或者更新一个联系人 */
/*- (void)addContact:(NSDictionary *)contact for:(NSNumber *)custId success:(void(^)())success failure:(void(^)(NSError *error))failure {
 __block BOOL isInsertSuccess;
 __block FMResultSet *rs;
 
 [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
 
 rs = [db executeQuery:[NSString stringWithFormat:@"SELECT custId FROM tb_contacts WHERE myCustId = %@ AND custId = %@", custId, contact[@"custId"]]];
 if (rs.next) {
 isInsertSuccess = [db executeUpdate:[NSString stringWithFormat:@"UPDATE tb_contacts SET isFriend = %@, nickname = '%@', remark = '%@', photoKey = '%@', level = %@, state = %@ , custType = %@ WHERE myCustId = %@ AND custId = %@",contact[@"isFriend"], contact[@"nickname"], contact[@"remark"], contact[@"photoKey"], contact[@"level"], contact[@"state"], contact[@"custType"], custId, contact[@"custId"]]];
 }
 else {
 isInsertSuccess = [db executeUpdate:[NSString stringWithFormat:@"INSERT INTO tb_contacts ( myCustId , custId , isFriend , nickname , remarkName , photoKey , level , state , custType) VALUES(%@, %@, %@, '%@', '%@', '%@', %@, %@ , %@);", custId, contact[@"custId"], contact[@"isFriend"], contact[@"nickname"], contact[@"remark"], contact[@"photoKey"], contact[@"level"], contact[@"state"], contact[@"custType"]]];
 }
 
 [rs close];
 }];
 
 if (isInsertSuccess) {
 
 success();
 
 } else {
 
 NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Insert contact error",
 NSLocalizedFailureReasonErrorKey:@"Insert contact error"};
 
 NSError *error = [NSError errorWithDomain:kDWDDBErrorDomain code:-1 userInfo:userInfo];
 
 failure(error);
 }
 
 }*/

- (void)addTempContact:(DWDTempContactModel *)model {
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM tb_contacts WHERE custId = ?;", model.custId];
        if (!result.next) {
            [db executeUpdate:@"REPLACE INTO tb_contacts ( \
             myCustId ,\
             custId ,\
             isFriend ,\
             nickname ,\
             remarkName ,\
             photoKey,\
             state ,\
             custType) \
             VALUES(?, ?, ?, ?, ?, ?, ?, ?);",
             model.custId,
             model.friendCustId,
             model.isFriend,
             model.nickname,
             model.friendNickname,
             model.photoKey ? model.photoKey : model.photohead.photoKey,
             @2,
             @0];
        }
    }];
}

- (void)addNewFriendTempStatus:(NSNumber *)custID nickname:(NSString *)nickname {
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM tb_contacts WHERE custId = ? AND isFriend = 1;", custID];
        if (!result.next) {
            [db executeUpdate:@"REPLACE INTO tb_contacts ( \
             custId ,\
             isFriend ,\
             nickname ,\
             state)\
             VALUES(?, ?, ?, ?);",
             custID,
             @1,
             nickname,
             @2];
        }
    }];
}

#pragma mark - Get
/** 校验是否是好友 */
- (BOOL)getRelationWithFriendCustId:(NSNumber *)friendCustId
{
    __block BOOL isFriend = NO;
     __block FMResultSet *rs;
    NSString *sql = [NSString stringWithFormat:@"SELECT isFriend FROM tb_contacts WHERE custId = %@;", friendCustId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            isFriend = [rs intForColumn:@"isFriend"];
        }
        [rs close];
    }];
    return isFriend;
 
}

/** 获取我的所有联系人 */
- (NSArray *)getContactsById:(NSNumber *)custId
{
    
    NSMutableArray *result = [NSMutableArray array];
    __block FMResultSet *rs;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND state = 2 AND isFriend = 1;", custId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            DWDContactModel *contact = [DWDContactModel new];
            if([rs longLongIntForColumn:@"custId"] == 1000 || [rs longLongIntForColumn:@"custId"] == 1001 || [rs longLongIntForColumn:@"custId"] == 1002){
                continue;
            }
            contact.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            contact.nickname = [rs stringForColumn:@"nickname"];
            contact.status = [NSNumber numberWithInt:[rs intForColumn:@"state"]];
            contact.remarkName = [rs stringForColumn:@"remarkName"];
            contact.photoKey = [rs stringForColumn:@"photoKey"] ;
            contact.custType = [NSNumber numberWithInt:[rs intForColumn:@"custType"]];
            [result addObject:contact];
        }
        
        [rs close];
    }];
    
    return result;
    
}
/** 获取好友的备注名 */
- (NSString *)getRemarkNameWithFriendId:(NSNumber *)friendId
{
    
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

/** 获取好友的photokey */
- (NSString *)fetchPhotoKeyWithFriendId:(NSNumber *)friendId
{
    __block FMResultSet *rs;
    __block NSString *photoKey;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            photoKey = [rs stringForColumn:@"photoKey"];
        }
        [rs close];
    }];
    return photoKey;
}

/** 获取好友的nickname */
- (NSString *)fetchNicknameWithFriendId:(NSNumber *)friendId
{
    
    __block FMResultSet *rs;
    __block NSString *nickname;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND custId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            nickname = [rs stringForColumn:@"nickname"];
        }
        [rs close];
    }];
    return nickname;
}



/** 好友的
 state
 1-未激活  2-正常  3-冻结  4-注销  5-黑名单  */
/** 根据聊天的类型, 查询不同的表, 获取数据 , 用于插入新数据到recentchatlist */
- (NSArray *)getContactsById:(NSNumber *)custId
                 FriendCusId:(NSNumber *)friendCusId
                    chatType:(DWDChatType )chatType
{
    
    NSMutableArray *result = [NSMutableArray array];
    __block FMResultSet *rs;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        // friendid 可能是 班级  群组
        
        if (chatType == DWDChatTypeClass) {
            
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_classes WHERE myCustId = %@ AND classId = %@;", custId , friendCusId];
            rs = [db executeQuery:sql];
            while (rs.next) {
                
                NSMutableDictionary *contact = [NSMutableDictionary dictionary];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]] forKey:@"custId"];
                [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
                [contact setObject:[rs stringForColumn:@"gradeName"] forKey:@"nickname"];
                [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"state"]] forKey:@"state"];
                [contact setObject:@"classChat" forKey:@"type"];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"memberCount"]] forKey:@"memberCount"];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"albumId"]] forKey:@"albumId"];
                
                [result addObject:contact];
            }
            
        }else if (chatType == DWDChatTypeGroup){
            
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_groups WHERE myCustId = %@ AND groupId = %@;", custId , friendCusId];
            rs = [db executeQuery:sql];
            while (rs.next) {
                
                NSMutableDictionary *contact = [NSMutableDictionary dictionary];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"groupId"]] forKey:@"custId"];
                [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
                [contact setObject:[rs stringForColumn:@"groupName"] forKey:@"nickname"];
                [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"state"]] forKey:@"state"];
                [contact setObject:@"groupChat" forKey:@"type"];
                [result addObject:contact];
            }
            
        }else{
            NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND custId = %@;", custId , friendCusId];
            rs = [db executeQuery:sql];
            while (rs.next) {
                
                NSMutableDictionary *contact = [NSMutableDictionary dictionary];
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
                
                if ([rs longLongIntForColumn:@"custId"] == 1000) {
                    continue;
                }
                
                [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]] forKey:@"custId"];
                [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
                [contact setObject:[rs stringForColumn:@"nickname"] forKey:@"nickname"];
                [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"state"]] forKey:@"state"];
                [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isFriend"]] forKey:@"isFriend"];
                [contact setObject:@"singleChat" forKey:@"type"];
                if ([rs stringForColumn:@"remarkName"] && ![[rs stringForColumn:@"remarkName"] isEqualToString:@""]) {
                    [contact setObject:[rs stringForColumn:@"remarkName"] forKey:@"remarkName"];
                }
                [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"custType"]] forKey:@"custType"];
                [result addObject:contact];
            }
        }
        
        [rs close];
    }];
    
    return result;
    
}

/** 根据离线消息的类型, 从联系人表中获取信息 */
- (NSArray *)getInfoFromDBbyId:(NSNumber *)custId
                   FriendCusId:(NSNumber *)friendCusId
                WithOfflineMsg:(DWDOfflineMsg *)offlineMsg
{
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    __block FMResultSet *rs;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND custId = %@;", custId , friendCusId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            
            NSMutableDictionary *contact = [[NSMutableDictionary alloc] initWithCapacity:6];
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
            
            if ([rs longLongIntForColumn:@"custId"] < 10000) {
                continue;
            }
            
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]] forKey:@"custId"];
            [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
            [contact setObject:[rs stringForColumn:@"nickname"] forKey:@"nickname"];
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"state"]] forKey:@"state"];
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"isFriend"]] forKey:@"isFriend"];
            
            if ([rs stringForColumn:@"remarkName"] && ![[rs stringForColumn:@"remarkName"] isEqualToString:@""]) {
                [contact setObject:[rs stringForColumn:@"remarkName"] forKey:@"remarkName"];
            }
            [result addObject:contact];
        }
        
        [rs close];
    }];
    
    return result;
    
}





/** 返回 除去传入的数组 联系人 */
- (NSArray *)getGroupedContacts:(NSNumber *)custemId
                        exclude:(NSArray *)contactIds
{
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    __block FMResultSet *rs;
    NSString *inBlock = [[contactIds valueForKey:@"description"] componentsJoinedByString:@","];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND state = 2 AND isFriend = 1 AND custId NOT IN (%@) AND custId NOT IN (1000,1001);", custemId, inBlock];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            
            DWDContactModel *contact = [DWDContactModel new];
            
            contact.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            contact.nickname = [rs stringForColumn:@"nickname"];
            contact.status = [NSNumber numberWithInt:[rs intForColumn:@"state"]];
            contact.remarkName = [rs stringForColumn:@"remarkName"];
            contact.photoKey = [rs stringForColumn:@"photoKey"] ;
            contact.custType = [NSNumber numberWithInt:[rs intForColumn:@"custType"]];
            [result addObject:contact];
            
        }
        [rs close];
    }];
    
    return result;
}

/** 返回 传入数组的数据 联系人 */
- (NSArray *)getGroupedContacts:(NSNumber *)custemId
                          ByIds:(NSArray *)custemIds
{
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    __block FMResultSet *rs;
    NSString *inBlock = [[custemIds valueForKey:@"description"] componentsJoinedByString:@","];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE myCustId = %@ AND state = 2 AND isFriend = 1 AND custId IN (%@);",custemId, inBlock];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            if ([rs longLongIntForColumn:@"custId"] == 1000) {
                continue;
            }
            
            DWDContactModel *contact = [DWDContactModel new];
            
            contact.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            contact.nickname = [rs stringForColumn:@"nickname"];
            contact.status = [NSNumber numberWithInt:[rs intForColumn:@"state"]];
            contact.remarkName = [rs stringForColumn:@"remarkName"];
            contact.photoKey = [rs stringForColumn:@"photoKey"] ;
            contact.custType = [NSNumber numberWithInt:[rs intForColumn:@"custType"]];
            [result addObject:contact];
        }
        
        [rs close];
    }];
    
    return result;
}

/** 根据数组ID 来查询返回数据 */
- (NSArray *)getContactsByIds:(NSArray *)custemIds
{
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    NSString *inBlock = [[custemIds valueForKey:@"description"] componentsJoinedByString:@","];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_contacts WHERE state = 2 AND isFriend = 1 AND custId IN (%@);", inBlock];
    __block FMResultSet *rs;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            NSMutableDictionary *contact = [[NSMutableDictionary alloc] initWithCapacity:3];
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"myCustId"]] forKey:@"myCustId"];
            [contact setObject:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]] forKey:@"custId"];
            [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
            [contact setObject:[rs stringForColumn:@"nickname"] forKey:@"nickname"];
            if ([rs stringForColumn:@"remarkName"] && ![[rs stringForColumn:@"remarkName"] isEqualToString:@""]) {
                [contact setObject:[rs stringForColumn:@"remarkName"] forKey:@"remarkName"];
            }
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"state"]] forKey:@"state"];
            [contact setObject:[NSNumber numberWithInt:[rs intForColumn:@"custType"]] forKey:@"custType"];
            [result addObject:contact];
        }
        
        [rs close];
    }];
    
    return result;
}



#pragma mark - Update
/** 更新好友备注名 */
- (void)updateFriendRemarkNameMyCustId:(NSNumber *)myCustId
                        byFriendCustId:(NSNumber *)friendCustId
                            remarkName:(NSString *)remarkName
                               success:(void (^)())updateSucess
                               failure:(void (^)())failure
{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_contacts SET remarkName = ? WHERE myCustId = ? AND custId = ?;",remarkName, myCustId,friendCustId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        failure();
    }
    
}

- (void)updateContactsByCustemId:(NSNumber *)custemId
                         success:(void(^)())updateSuccess
                         failure:(void (^)(NSError *error))updateFailure
{
    
    NSString *lastUpdateKey = [NSString stringWithFormat:@"%@-%@", DWDContactsLastUpdateKey, custemId];
    
    NSString *lastModifyDate =
    [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdateKey];
    
    if (!lastModifyDate) lastModifyDate = @"0";
    
    // 如果本地没有 , 从服务器获取所有好友列表和班级列表
    
    [self.httpApiClient getApi:@"AddressBookRestService/getList" params:@{DWDCustId: custemId, DWDLastModifyDate:lastModifyDate} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *friends = responseObject[DWDApiDataKey][@"friends"];  // 从服务器获取的好友, 群组 ,班级
        NSArray *classes = responseObject[DWDApiDataKey][@"grades"];
        NSArray *groups = responseObject[DWDApiDataKey][@"groups"];
        
        BOOL __block success = NO;
        
        
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            
            for (NSDictionary *newContact in friends) {  // 遍历获取到的好友列表
                
                success = [db executeUpdate:@"REPLACE INTO tb_contacts ( \
                           myCustId ,\
                           custId ,\
                           isFriend ,\
                           nickname ,\
                           remarkName ,\
                           photoKey,\
                           level ,\
                           state ,\
                           custType) \
                           VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?);"
                           ,custemId,
                           newContact[@"custId"],
                           newContact[@"isFriend"],
                           newContact[@"nickname"],
                           newContact[@"friendRemarkName"],
                           newContact[@"photoKey"],
                           newContact[@"level"],
                           newContact[@"status"],
                           newContact[@"custType"]];
            }
            for (NSDictionary *newContact in classes) {  // 遍历获取到的班级列表
                
                success = [db executeUpdate:@"REPLACE INTO tb_classes ( \
                           myCustId ,\
                           classId , \
                           className , \
                           memberCount , \
                           photoKey , \
                           level , \
                           isMian ,\
                           isManager, \
                           state , \
                           albumId ,\
                           isShowNick , \
                           classAcct , \
                           introduce , \
                           schoolId , \
                           schoolName , \
                           nickname, \
                           isExist) \
                           VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
                           custemId,
                           newContact[@"custId"],
                           newContact[@"className"],
                           newContact[@"memberNum"],
                           newContact[@"photoKey"],
                           newContact[@"level"],
                           newContact[@"isMian"] ,
                           newContact[@"isManager"],
                           newContact[@"status"] ,
                           newContact[@"albumId"] ,
                           newContact[@"isShowNick"],
                           newContact[@"classAcct"] ,
                           newContact[@"introduce"] ,
                           newContact[@"schoolId"] ,
                           newContact[@"schoolName"] ,
                           newContact[@"nickname"],
                           newContact[@"isExist"]];
            }
            for (NSDictionary *newContact in groups) {  // 遍历获取到的群组列表
                
                success = [db executeUpdate:@"REPLACE INTO tb_groups ( \
                           myCustId ,\
                           groupId ,\
                           groupName ,\
                           nickname, \
                           memberCount ,\
                           photoKey ,\
                           level ,\
                           isMian ,\
                           state ,\
                           isShowNick,\
                           isExist,\
                           isSave ) \
                           VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
                           custemId,
                           newContact[@"custId"],
                           newContact[@"groupName"],
                           newContact[@"nickname"],
                           newContact[@"memberNum"],
                           newContact[@"photoKey"],
                           newContact[@"level"],
                           newContact[@"isMian"],
                           newContact[@"status"],
                           newContact[@"isShowNick"],
                           newContact[@"isExist"],
                           newContact[@"isSave"]];
            }
            
        }];
        
        
        if (success) {
            DWDLog(@"last update key is :%@", responseObject[DWDApiDataKey][@"time"]);
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[DWDApiDataKey][@"time"] forKey:lastUpdateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            updateSuccess();
        }
        else
        {
            updateFailure(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        updateFailure(error);
        
    }];
}

- (void)updateFriendNickname:(NSString *)nickname
                    MyCustId:(NSNumber *)myCustId
              byFriendCustId:(NSNumber *)friendCustId
                     success:(void (^)())updateSucess
                     failure:(void (^)())failure
{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_contacts SET nickname = ? WHERE myCustId = ? AND custId = ?;",nickname, myCustId,friendCustId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        failure();
    }
    
}


- (void)updateFriendPhotoKey:(NSString *)photoKey
                    MyCustId:(NSNumber *)myCustId
              byFriendCustId:(NSNumber *)friendCustId
                     success:(void (^)())updateSucess
                     failure:(void (^)())failure
{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE tb_contacts SET photoKey = ? WHERE myCustId = ? AND custId = ?;",photoKey, myCustId,friendCustId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        failure();
    }
}

- (void)updateFriendShipWithCustId:(NSNumber *)friendCustId isFriend:(BOOL)isFriend {
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"REPLACE INTO tb_contacts(myCustId, custId, isFriend, state, custType) VALUES(?, ?, ?, ?, ?);", [DWDCustInfo shared].custId, isFriend == YES ? @1 : @0, @1, @2, @0];
    }];
}

#pragma mark - Delete
/** 删除好友 */
- (void)deleteContactWithFriendCustId:(NSNumber *)friendCustId
                              success:(void(^)())success
                              failure:(void(^)())failure
{
    __block BOOL relust;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        relust = [db executeUpdate:@"DELETE FROM tb_contacts WHERE myCustId = ? AND custId = ?;",[DWDCustInfo shared].custId,friendCustId];
        
    }];
    if (relust) {
        success();
    } else {
        failure();
    }
}

#pragma Update Data

- (void)systemMessageInsertToSysMessageTableWith:(DWDSystemChatMsg *)msg success:(void(^)())updateSucess failure:(void(^)())Failure {
    NSString *isSysMsgTableCreated = [[NSUserDefaults standardUserDefaults] objectForKey:DWDSysMsgTableCreatedKey];
    
    if (!isSysMsgTableCreated) {
        [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            BOOL success = [db executeUpdate:@"CREATE TABLE sys_message (id integer PRIMARY KEY, verifyInfo TEXT, custId INTEGER, groupId INTEGER, creatTime INTEGER, verifyState INTEGER, msgType TEXT);"];
            if (success) {
                [[NSUserDefaults standardUserDefaults] setObject:@"Created" forKey:DWDSysMsgTableCreatedKey];
                DWDMarkLog(@"create sys_message table success");
            }
        }];
    }
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"INSERT INTO sys_message(verifyInfo,custId, groupId, creatTime, verifyState) VALUES (?, ?, ?, ?, ?);", msg.verifyInfo, msg.custId, msg.groupId, msg.createTime,[NSNumber numberWithBool:msg.verifyState]];
        if (success) {
            DWDMarkLog(@"insert to sys_message table success");
        }
    }];
    
}

@end
