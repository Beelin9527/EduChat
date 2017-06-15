//
//  DWDGroupDataBase.m
//  EduChat
//
//  Created by Gatlin on 16/2/19.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGroupDataBaseTool.h"

#import "DWDCustInfo.h"
#import "DWDGroupEntity.h"
#import <FMDB.h>

@interface DWDGroupDataBaseTool()
@end

@implementation DWDGroupDataBaseTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(instancetype)sharedGroupDataBase
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

#pragma mark Insert
/** 插入某一个群组 */
- (void)insertOneGroup:(DWDGroupEntity *)groupModel
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"INSERT INTO tb_groups ( myCustId , groupId , groupName , nickname, memberCount , photoKey , level , isMian , state , isShowNick, isExist, isSave ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", [DWDCustInfo shared].custId, groupModel.groupId, groupModel.groupName, groupModel.nickname, groupModel.memberCount, groupModel.photoKey, @0, groupModel.isMian, @2, groupModel.isShowNick, @1, groupModel.isSave];
        if (res) {
            DWDLog(@"insert to tb_groups success");
        }
    }];
  
}


#pragma mark - Get
/** 获取群组列表 */
-(NSArray *)getGroupList:(NSNumber *)custemId
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:10];
    __block FMResultSet *rs;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_groups WHERE myCustId = %@ AND state = 2 AND isExist = 1 AND isSave = 1;", custemId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            DWDGroupEntity *entity = [[DWDGroupEntity alloc] init];
            entity.groupId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"groupId"]];
            entity.groupName = [rs stringForColumn:@"groupName"];
            entity.nickname = [rs stringForColumn:@"nickname"];
            entity.memberCount = [NSNumber numberWithInt:[rs intForColumn:@"memberCount"]];
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.isMian = [NSNumber numberWithInt:[rs intForColumn:@"isMian"]];
            entity.isShowNick = [NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]];
            entity.isSave = [NSNumber numberWithInt:[rs intForColumn:@"isSave"]];
            [result addObject:entity];
        }
        
        [rs close];
    }];
    
    return result;
}


/** 获取某个群组信息 */
- (DWDGroupEntity *)getGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId
{
    __block FMResultSet *rs;
   __block DWDGroupEntity *model = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_groups WHERE myCustId = %@ AND groupId = %@ AND state = 2;", custId,groupId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
           model = [[DWDGroupEntity alloc] init];
            model.groupId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"groupId"]];
            model.groupName = [rs stringForColumn:@"groupName"];
             model.nickname = [rs stringForColumn:@"nickname"];
            model.photoKey = [rs stringForColumn:@"photoKey"];
            model.memberCount = [NSNumber numberWithInt:[rs intForColumn:@"memberCount"]];
           model.isShowNick = [NSNumber numberWithInt:[rs intForColumn:@"isShowNick"]];
            model.isMian = [NSNumber numberWithInt:[rs intForColumn:@"isMian"]];
             model.isSave = [NSNumber numberWithInt:[rs intForColumn:@"isSave"]];
        }
        
        [rs close];
    }];
    
    
    return model ? model : nil;
    
}




#pragma mark Update
/** 用户对群组设置 是否显示其他用户昵称 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId isShowNick:(NSNumber *)isShowNick
{
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_groups SET isShowNick = ? WHERE myCustId = ? AND groupId = ?;",isShowNick,custId,groupId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
    
}

/** 更新某个群组名称 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId groupName:(NSString *)groupName
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_groups SET groupName = ? WHERE myCustId = ? AND groupId = ?;", groupName,custId,groupId];
        if (res) {
            DWDLog(@"success to update db table");
        }
    }];
    
}

/** 更新我在某个群组昵称 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId nickname:(NSString *)nickname
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_groups SET nickname = ? WHERE myCustId = ? AND groupId = ?;", nickname,custId,groupId];
        if (res) {
            DWDLog(@"success to update db table");
        }
    }];
}

/** 更新某个群组人数 */
- (void)updateGroupInfoWithMyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId menberCount:(NSNumber *)menberCount
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_groups SET memberCount = ? WHERE myCustId = ? AND groupId = ?;", menberCount,custId,groupId];
        if (res) {
            DWDLog(@"success to update db table");
        }
    }];
}
/** 更新某个群组状态 isExist*/
- (void)updateGroupWithIsExist:(NSNumber *)isExist MyCustId:(NSNumber *)custId groupId:(NSNumber *)groupId
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE  tb_groups SET isExist = ? WHERE myCustId = ? AND groupId = ?;"];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:sql,isExist, custId,groupId];
        if (!res) {
            DWDLog(@"error when update db table");
        } else {
            DWDLog(@"success to update db table");
        }
    }];
}


/** 删除某个群组 */
- (void)deleteGroupWithMyCustId:(NSNumber *)custId gorupId:(NSNumber *)groupId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"DELETE FROM tb_groups WHERE myCustId = ? AND groupId = ?;",custId,groupId];
        if (res) {
            DWDLog(@"success to delete db table");
        }
    }];
}

/*

 id INTEGER PRIMARY KEY AUTOINCREMENT, myCustId INTEGER, groupId INTEGER UNIQUE, groupName TEXT, nickname TEXT,  memberCount INTEGER, photoKey TEXT, level INTEGER, isMian INTEGER, state INTEGER , isShowNick INTEGER , isExist INTEGER
 
 */


/**  实时更新群组头像 */
- (void)updateGroupPhotokeyWithGroupId:(NSNumber *)groupId photokey:(NSString *)photokey success:(void(^)())updateSucess failure:(void (^)())updateFailure{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE  tb_groups SET photoKey = ? WHERE myCustId = ? AND groupId = ?;" ,photokey, [DWDCustInfo shared].custId ,groupId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}

/**  实时更新群组昵称 */
- (void)updateGroupNicknameWithGroupId:(NSNumber *)groupId groupName:(NSString *)groupName success:(void(^)())updateSucess failure:(void (^)())updateFailure{
    __block BOOL success = NO;
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:@"UPDATE  tb_groups SET groupName = ? WHERE myCustId = ? AND groupId = ?;", groupName, [DWDCustInfo shared].custId ,groupId];
    }];
    
    if (success) {
        updateSucess();
    }else{
        updateFailure();
    }
}

/** 获取群组的photokey */
- (NSString *)fetchPhotoKeyWithFriendId:(NSNumber *)friendId{
    __block FMResultSet *rs;
    __block NSString *photoKey;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_groups WHERE myCustId = %@ AND groupId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            photoKey = [rs stringForColumn:@"photoKey"];
        }
        [rs close];
    }];
    return photoKey;
}

/** 获取群组的nickname */
- (NSString *)fetchNicknameWithFriendId:(NSNumber *)friendId{
    __block FMResultSet *rs;
    __block NSString *groupName;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tb_groups WHERE myCustId = %@ AND groupId = %@;", [DWDCustInfo shared].custId , friendId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            groupName = [rs stringForColumn:@"groupName"];
        }
        [rs close];
    }];
    return groupName;
}
@end
