//
//  DWDClassDataBase.m
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassDataBaseTool.h"
#import <FMDB/FMDB.h>
#import "DWDClassModel.h"
#import "DWDClassMember.h"
#import <YYModel/YYModel.h>
@interface DWDClassDataBaseTool ()
@end


@implementation DWDClassDataBaseTool
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(instancetype)sharedClassDataBase
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

/**
 * 创建班级成员表
 */
- (void)createClassNembersTableWithClassId:(NSNumber *)classId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        //创建班级成员表
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (\
                         id INTEGER PRIMARY KEY AUTOINCREMENT,\
                         myCustId       INTEGER,\
                         classId        INTEGER ,\
                         custId         INTEGER  UNIQUE,\
                         isMian         INTEGER,\
                         isManager      INTEGER,\
                         photoKey       TEXT,\
                         nickname       TEXT,\
                         remarkName     TEXT,\
                         isExist        INTEGER);",
                         [NSString stringWithFormat:@"tb_classMembers_%@",classId]];
        [db executeUpdate:sql];
    }];
}
/*
 id INTEGER PRIMARY KEY AUTOINCREMENT, myCustId INTEGER, classId INTEGER UNIQUE, className TEXT, memberCount INTEGER, photoKey TEXT, level INTEGER, isMian INTEGER, isManager INTEGER, state INTEGER , albumId INTEGER ,isShowNick INTEGER, classAcct INTEGER, introduce TEXT, isExist INTEGER, schoolId INTEGER, schoolName TEXT,nickname TEXT
 */

#pragma mark - Get
/** 获取班级列表 */
- (NSArray *)getClassList:(NSNumber *)custemId {
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:13];
    __block FMResultSet *rs;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_classes WHERE myCustId = ? AND state = 2 AND isExist = 1;"];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql, custemId];
        
        while (rs.next) {
            
            DWDClassModel *entity = [[DWDClassModel alloc] init];
            entity.classId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]];
            entity.className = [rs stringForColumn:@"className"];
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.memberNum = [NSNumber numberWithInt:[rs intForColumn:@"memberCount"]];
            entity.status = [NSNumber numberWithInt:[rs intForColumn:@"state"]];
            entity.isMian = [NSNumber numberWithInt:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithInt:[rs intForColumn:@"isManager"]];
            entity.isExist = [NSNumber numberWithInt:[rs intForColumn:@"isExist"]];
            entity.albumId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"albumId"]];
            entity.isShowNick = [NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]];
            entity.introduce = [rs stringForColumn:@"introduce"];
            entity.nickname = [rs stringForColumn:@"nickname"];
            entity.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
            entity.schoolName = [rs stringForColumn:@"schoolName"];
            entity.classAcct = [NSNumber numberWithLong:[rs longForColumn:@"classAcct"]];
            [result addObject:entity];
        }
        
        [rs close];
    }];
    
    return result;
}

/** 根据classId 获取班级信息 */
- (DWDClassModel *)getClassInfoWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    __block FMResultSet *rs;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_classes WHERE classId = %@ AND myCustId = %@;",classId, myCustId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            DWDClassModel *entity = [[DWDClassModel alloc] init];
            entity.classId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]];
            entity.className = [rs stringForColumn:@"className"];
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.memberNum = [NSNumber numberWithInt:[rs intForColumn:@"memberCount"]];
            entity.status = [NSNumber numberWithInt:[rs intForColumn:@"state"]];
            entity.isMian = [NSNumber numberWithInt:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithInt:[rs intForColumn:@"isManager"]];
            entity.albumId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"albumId"]];
            entity.isShowNick = [NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]];
            entity.introduce = [rs stringForColumn:@"introduce"];
            entity.nickname = [rs stringForColumn:@"nickname"];
            entity.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
            entity.schoolName = [rs stringForColumn:@"schoolName"];
            entity.classAcct = [NSNumber numberWithLong:[rs longForColumn:@"classAcct"]];
            entity.isExist = [NSNumber numberWithInt:[rs intForColumn:@"isExist"]];
            [result addObject:entity];
            
        }
        
        [rs close];
    }];
    
    return result.count == 0 ? nil : result[0];
}

- (NSArray *)getClassMemberWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:40];
    __block FMResultSet *rs;
    
   NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1;",tableName, classId, myCustId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            DWDClassMember *entity = [[DWDClassMember alloc] init];
            entity.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.isExist = [NSNumber numberWithBool:[rs intForColumn:@"isExist"]];
            entity.isMian = [NSNumber numberWithBool:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithBool:[rs intForColumn:@"isManager"]];
            entity.nickname = [rs stringForColumn:@"nickname"];
            
            [result addObject:entity];
            
        }
        
        [rs close];
    }];

    return result;
}

- (NSArray *)getClassMemberIsNotMianWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:40];
    __block FMResultSet *rs;
    
    NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1 AND isMian = 0 AND custId != %@;",tableName, classId, myCustId,myCustId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            DWDClassMember *entity = [[DWDClassMember alloc] init];
            entity.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.isExist = [NSNumber numberWithBool:[rs intForColumn:@"isExist"]];
            entity.isMian = [NSNumber numberWithBool:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithBool:[rs intForColumn:@"isManager"]];
            entity.nickname = [rs stringForColumn:@"nickname"];
            
            [result addObject:entity];
            
        }
        
        [rs close];
    }];
    
    return result;
}

/** 获取班级成员不超过14人 */
- (NSArray *)getClassMemberNoMoreThanFourTeenWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:14];
    __block FMResultSet *rs;
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1;",tableName, classId, myCustId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        int count = 0;
        
        while (rs.next && count < 14) {
            
            DWDClassMember *entity = [[DWDClassMember alloc] init];
            entity.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.isExist = [NSNumber numberWithBool:[rs intForColumn:@"isExist"]];
            entity.isMian = [NSNumber numberWithBool:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithBool:[rs intForColumn:@"isManager"]];
            entity.nickname = [rs stringForColumn:@"nickname"];
            
            [result addObject:entity];
            
            count ++;
        }
        
        [rs close];
    }];
    
    return result;
}

/** 获取班级总人数 */
- (void)getClassMemberCountWithClassId:(NSNumber *)classId success:(void(^)(NSUInteger memberCount))success failure:(void(^)())failure;
{
       __block FMResultSet *rs;
    __block NSUInteger memberCount = 0;
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT custId FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1;", tableName,classId, [DWDCustInfo shared].custId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            memberCount ++;
        }
        
        [rs close];
    }];
    
    if (memberCount)
    {
        success(memberCount);
    }
    else
    {
        failure();
    }
   
}



- (NSArray *)getClassAllMemberNicknameWithClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:40];
    __block FMResultSet *rs;
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT nickname FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1;", tableName,classId, myCustId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            NSString *nickname = [rs stringForColumn:@"nickname"];
            [result addObject:nickname];
        }
        [rs close];
    }];
    
    return result;

}

/** 根据classId、array 获取班级 array 成员昵称 */
- (NSArray *)getClassMemberNicknameWithClassId:(NSNumber *)classId memberArray:(NSArray *)memberArray
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:1];
    __block FMResultSet *rs;
    
    NSString *memberArrayStr = [memberArray componentsJoinedByString:@","];
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT nickname FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1 AND custId IN (%@);",tableName, classId,[DWDCustInfo shared].custId, memberArrayStr];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            NSString *nickname = [rs stringForColumn:@"nickname"];
            [result addObject:nickname];
        }
        [rs close];
    }];
    
    return result;
 
}
- (NSArray *)getClassMemberWithByMembersId:(NSArray *)membersId  ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId includeMian:(BOOL)includeMian
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:40];
    __block FMResultSet *rs;
    NSString *sql;
    NSString *tempString = [membersId componentsJoinedByString:@","];
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    if (includeMian) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1 AND custId != %@ AND custId IN (%@);",tableName, classId, myCustId,myCustId,tempString];
    }else{
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1 AND isMian = 0 AND custId != %@ AND custId IN (%@);",tableName, classId, myCustId,myCustId,tempString];
    }
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while (rs.next) {
            
            DWDClassMember *entity = [[DWDClassMember alloc] init];
            entity.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.isExist = [NSNumber numberWithBool:[rs intForColumn:@"isExist"]];
            entity.isMian = [NSNumber numberWithBool:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithBool:[rs intForColumn:@"isManager"]];
            entity.nickname = [rs stringForColumn:@"nickname"];
            
            [result addObject:entity];
            
        }
        
        [rs close];
    }];
    
    return result;
}

- (NSArray *)getClassMemberWithExcludeByMembersId:(NSArray *)membersId  ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:40];
    __block FMResultSet *rs;
    NSString *tempString = [membersId componentsJoinedByString:@","];
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE classId = %@ AND myCustId = %@ AND isExist = 1 AND custId NOT IN (%@) AND custId != %@;",tableName, classId, myCustId,tempString,myCustId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            
            DWDClassMember *entity = [[DWDClassMember alloc] init];
            entity.custId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"custId"]];
            
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.isExist = [NSNumber numberWithBool:[rs intForColumn:@"isExist"]];
            entity.isMian = [NSNumber numberWithBool:[rs intForColumn:@"isMian"]];
            entity.isManager = [NSNumber numberWithBool:[rs intForColumn:@"isManager"]];
            entity.nickname = [rs stringForColumn:@"nickname"];
            
            [result addObject:entity];
            
        }
        
        [rs close];
    }];
    
    return result;

}


#pragma mark - Insert
/** 插入班级 */
- (void)insertClassWithClassModel:(DWDClassModel *)classModel insertSuccess:(void(^)())insertSuccess insertFailure:(void(^)())insertFailure
{
      BOOL __block success = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
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
                   [DWDCustInfo shared].custId,
                   classModel.classId,
                   classModel.className,
                   classModel.memberNum,
                   classModel.photoKey,
                   classModel.level,
                   classModel.isMian,
                   classModel.isManager,
                   classModel.status,
                   classModel.albumId,
                   classModel.isShowNick,
                   classModel.classAcct,
                   classModel.introduce,
                   classModel.schoolId,
                   classModel.schoolName,
                   classModel.nickname,
                   classModel.isExist];
            }];
    if (success)
    {
        insertSuccess();
    }
    else
    {
        insertFailure();
    }
}

- (void)insertClassMember:(id)responseObject classId:(NSNumber *)classId myCustId:(NSNumber *)myCustId updateSuccess:(void (^)())updateSuccess updateFailure:(void(^)())updateFailure;
{
    BOOL __block success = NO;
    NSArray *members = responseObject[DWDApiDataKey][@"custInfo"];
    
    //创建班级成员表
    [self createClassNembersTableWithClassId:classId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
       
        for (NSDictionary *member in members) {
            
            NSString *insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ ", [NSString stringWithFormat:@"tb_classMembers_%@",classId]];
            success = [db executeUpdateWithFormat:[insertSql stringByAppendingString:@"( \
                       myCustId ,\
                       classId , \
                       custId , \
                       isMian , \
                       isManager , \
                       photoKey , \
                       nickname ,\
                       remarkName, \
                       isExist ) \
                       VALUES(%@, %@, %@, %@, %@, %@, %@, %@, %@);"],
                       myCustId,
                       classId,
                       member[@"custId"],
                       member[@"isMian"],
                       member[@"isManager"],
                       member[@"photoKey"],
                       member[@"nickname"] ,
                       member[@"remarkName"],
                       member[@"isExist"]];
        }
    }];
    
    if (success)
    {
        DWDLog(@"last update key is :%@", responseObject[DWDApiDataKey][@"time"]);
        NSString *lastUpdateKey = [NSString stringWithFormat:@"%@-%@-%@", @"lastRequest",classId,  [DWDCustInfo shared].custId];
        [[NSUserDefaults standardUserDefaults] setObject:responseObject[DWDApiDataKey][@"time"] forKey:lastUpdateKey];
        updateSuccess();
    }
    else
    {
        updateFailure();
    }
}
#pragma mark - Update
/** 更新班级头像 */
- (void)updateClassInfoWithPhotoKey:(NSString *)photoKey classId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_classes SET photoKey = ? WHERE myCustId = ? AND classId = ?;", photoKey,myCustId,classId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
 
}
- (void)updateClassInfoWithIntroduce:(NSString *)introduce ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE tb_classes SET introduce = '%@' WHERE myCustId = %@ AND classId = %@;", introduce,myCustId,classId];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
    
}

- (void)updateClassInfoWithNickname:(NSString *)nickname ClassId:(NSNumber *)classId myCustId:(NSNumber *)myCustId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_classes SET nickname = ? WHERE myCustId = ? AND classId = ?;",nickname,myCustId,classId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
}

- (void)updateClassInfoWithisShowNick:(NSNumber *)isShowNick classId:(NSNumber *)classId  myCustId:(NSNumber *)myCustId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_classes SET isShowNick = ? WHERE myCustId = ? AND classId = ?;",isShowNick,myCustId,classId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
    
}

/** 更新班级信息 人数 */
- (void)updateClassInfoWithMemberCount:(NSNumber *)memberCount classId:(NSNumber *)classId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_classes SET memberCount = ? WHERE myCustId = ? AND classId = ?;",memberCount,[DWDCustInfo shared].custId,classId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
 
}

/**  实时更新班级头像 */
- (void)updateClassPhotokeyWithClassId:(NSNumber *)classId photokey:(NSString *)photokey success:(void (^)())updateSucess failure:(void (^)())updateFailure{
    __block BOOL success = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
         success = [db executeUpdate:@"UPDATE tb_classes SET photoKey = ? WHERE myCustId = ? AND classId = ?;", photokey,[DWDCustInfo shared].custId, classId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}

/** 获取班级的photokey */
- (NSString *)fetchPhotoKeyWithFriendId:(NSNumber *)friendId{
    __block FMResultSet *rs;
    __block NSString *photoKey;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_classes WHERE myCustId = %@ AND classId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            photoKey = [rs stringForColumn:@"photoKey"];
        }
        [rs close];
    }];
    return photoKey;
}

/** 获取班级的nickname */
- (NSString *)fetchNicknameWithFriendId:(NSNumber *)friendId{
    __block FMResultSet *rs;
    __block NSString *className;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_classes WHERE myCustId = %@ AND classId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            className = [rs stringForColumn:@"className"];
        }
        [rs close];
    }];
    return className;
}


#pragma mark - Delete
/** 删除该班级 */
- (void)deleteClassId:(NSNumber *)classId success:(void(^)())updateSucess failure:(void (^)())updateFailure
{
    __block BOOL success = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"DELETE FROM tb_classes WHERE classId = ? AND myCustId = ?;", classId, [DWDCustInfo shared].custId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
 
}
/** 删除班级成员 */
- (void)deleteClassMemberWithClassId:(NSNumber *)classId membersId:(NSArray *)membersId success:(void(^)())updateSucess failure:(void (^)())updateFailure
{
    __block BOOL success = NO;
     NSString *tableName = [NSString stringWithFormat:@"tb_classMembers_%@",classId];
     NSString *tempString = [membersId componentsJoinedByString:@","];
     NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE classId = %@ AND myCustId = %@ AND custId IN (%@);",tableName, classId,[DWDCustInfo shared].custId ,tempString];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
    
        success = [db executeUpdate:sql];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}
@end
