//
//  DWDFriendApplyDataBase.m
//  EduChat
//
//  Created by Gatlin on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDFriendApplyDataBaseTool.h"
#import <FMDB/FMDB.h>

#import "DWDFriendApplyEntity.h"
@interface DWDFriendApplyDataBaseTool()
@end

@implementation DWDFriendApplyDataBaseTool
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createTable];
    }
    return self;
}

+(instancetype)sharedFriendApplyDataBase
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}


/** create Table */
- (void)createTable
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS  tb_friendApply(\
             myCustId       INTEGER ,\
             friendCustId   INTEGER UNIQUE, \
             friendNickname TEXT , \
             photokey       TEXT ,\
             addTime        INTEGER , \
             verifyInfo     TEXT , \
             status         INTEGER , \
             verifyTime     TEXT);"];
    }];
    
}

#pragma mark - insert
- (void)insertToTableWithMyCustId:(NSNumber *)myCustId friendApplyArray:(NSArray *)friendApplyArray
{
    [self createTable];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        for (DWDFriendApplyEntity *entity in friendApplyArray)
        {
            [db executeUpdate:@"REPLACE INTO tb_friendApply VALUES(?, ?, ?, ?, ?, ?, ?, ?);",myCustId,entity.friendCustId,entity.friendNickname,entity.photoKey,entity.addTime,entity.verifyInfo,entity.status,entity.verifyTime];
        }
    }];
}


#pragma mark - Delete
- (void)deleteWithFriendCustId:(NSNumber *)friendCustId  MyCustId:(NSNumber *)myCustId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"DELETE FROM tb_friendApply WHERE myCustId = ? AND friendCustId = ?;",myCustId,friendCustId];
       
    }];
    
}


#pragma mark - Update
- (void)updateWithStatus:(NSNumber *)status MyCustId:(NSNumber *)myCustId friendCustId:(NSNumber *)friendCustId
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:@"UPDATE tb_friendApply SET status = ? WHERE myCustId = ? AND friendCustId = ?;",status,myCustId,friendCustId];
        if (res)
        {
        }
        else
        {
        }
    }];
    
}


#pragma mark - get
- (NSArray *)getAllFriendsApplyWithMyCustId:(NSNumber *)myCustId
{
    __block FMResultSet *rs;
    NSMutableArray *friendApplyArray = [NSMutableArray arrayWithCapacity:10];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        rs = [db executeQuery:@"SELECT * FROM tb_friendApply WHERE myCustId = ?;",myCustId];
        while (rs.next) {
            DWDFriendApplyEntity *entity = [DWDFriendApplyEntity new];
            entity.friendCustId = [NSNumber numberWithLongLong: [rs longLongIntForColumn:@"friendCustId"]];
            entity.friendNickname = [rs stringForColumn:@"friendNickname"];
            entity.photoKey = [rs stringForColumn:@"photoKey"];
            entity.status = [NSNumber numberWithInt:[rs intForColumn:@"status"]];
            entity.addTime = @([rs longLongIntForColumn:@"addTime"]);
            entity.verifyInfo = [rs stringForColumn:@"verifyInfo"];
            entity.verifyTime = [rs stringForColumn:@"verifyTime"];
            [friendApplyArray addObject:entity];
        }
        FMResultSet *rs;
        [rs close];
    }];
    
    return friendApplyArray;
}

@end

