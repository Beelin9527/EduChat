//
//  DWDIntelligenceMenuDatabaseTool.m
//  EduChat
//
//  Created by Beelin on 16/12/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntelligenceMenuDatabaseTool.h"
#import <FMDB/FMDB.h>

@implementation DWDIntelligenceMenuDatabaseTool
+(instancetype)sharedIntelligenceDataBase
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

/**
 * 创建智能办公菜单表 intelligenceMenuTable
 本地字段名            描述          服务器返回字段名
schoolId            学校id         sid
parentCode          父菜单编码      pcd
parentName          父菜单名称      pNm
 
modeType            模块类型         modtype
serialNumber        序号，用于排序    sn
menuType            菜单类型         mntype
menuCode            菜单编号         mncd
menuName            菜单名称         mnNm
menuIcon            菜单图标         mnioc
funcDesc            菜单功能描述      funcdesc
 
isOpen              是否开通         isOpen
isShow              是否显示         isShow
 
classId             班级ID（本地增加字段）
className
sole                唯一值（学校ID + 班级ID + 菜单编号 ）本地增加字段）
 
 */
#pragma mark - Create Table
- (void)createIntelligenceMenuTable
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        //创建
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS tb_intelligence_menu (\
                         id INTEGER PRIMARY KEY AUTOINCREMENT,\
                         schoolId       INTEGER,\
                         parentCode     TEXT,\
                         parentName     TEXT,\
                         modeType       INTEGER NOT NULL DEFAULT 0,\
                         serialNumber   INTEGER NOT NULL DEFAULT 0,\
                         menuType       INTEGER NOT NULL DEFAULT 0,\
                         menuCode       TEXT,\
                         menuName       TEXT,\
                         menuIcon       TEXT,\
                         funcDesc       TEXT,\
                         isOpen         INTEGER NOT NULL DEFAULT 0,\
                         isShow         INTEGER NOT NULL DEFAULT 0,\
                         classId       INTEGER NOT NULL DEFAULT 0,\
                         sole          TEXT UNIQUE\
                         );"
                         ];
        [db executeUpdate:sql];
    }];
}


- (void)reCreateTables
{
    [self createIntelligenceMenuTable];
}


#pragma mark - Insert
- (BOOL)insertIntelligenceMenuDatabaseWithArrayModel:(NSArray<DWDIntelligenceMenuModel *> *)arrayModel{
    __block BOOL result = NO;
    //事务
    [[DWDDataBaseHelper sharedManager] beginTransactionInDatabase:^(FMDatabase *db, BOOL *rollback) {
        for (DWDIntelligenceMenuModel *model in arrayModel) {
            result = [db executeUpdate:@"REPLACE INTO tb_intelligence_menu ( \
                      schoolId ,\
                      parentCode ,\
                      parentName ,\
                      modeType ,\
                      serialNumber ,\
                      menuType ,\
                      menuCode ,\
                      menuName ,\
                      menuIcon ,\
                      funcDesc ,\
                      isOpen ,\
                      isShow ,\
                      classId ,\
                      sole)\
                      VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
                      ,model.schoolId ,
                      model.parentCode,
                      model.parentName,
                      model.modeType,
                      model.serialNumber,
                      model.menuType,
                      model.menuCode,
                      model.menuName,
                      model.menuIcon,
                      model.funcDesc,
                      model.isOpen,
                      model.isShow,
                      model.classId,
                      model.sole
                      ];
        }

        if (!result) {
            *rollback = YES;
            return;
        }
    }];
    return result;
}

#pragma mark - Query
- (NSArray *)queryClassManegerMenuWithClassId:(NSNumber *)classId{
    __block NSMutableArray *result = [NSMutableArray array];
     __block NSMutableArray *classManagerMenu = [NSMutableArray array];
     __block NSMutableArray *memberManagerMenu = [NSMutableArray array];
    __block FMResultSet *rs;
    
    NSString *sql = [NSString stringWithFormat:@"select * from tb_intelligence_menu where classId = %@;",classId];

    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            DWDIntelligenceMenuModel *model = [[DWDIntelligenceMenuModel alloc] init];
            model.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
            model.parentCode = [rs stringForColumn:@"parentCode"];
            model.parentName = [rs stringForColumn:@"parentName"];
            
            model.modeType = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"modeType"]];
            model.serialNumber = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"serialNumber"]];
            model.menuType = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"menuType"]];
            model.menuCode = [rs stringForColumn:@"menuCode"];
            model.menuName = [rs stringForColumn:@"menuName"];
            model.menuIcon = [rs stringForColumn:@"menuIcon"];
            model.funcDesc = [rs stringForColumn:@"funcDesc"];
            
            model.isOpen = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"isOpen"]];
            model.isShow = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"isShow"]];
            model.classId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]];
            
        
            if ([model.parentCode isEqualToString:@"A020101010101"]) {
                [classManagerMenu addObject:model];
            }else if ([model.parentCode isEqualToString:@"A020101010102"]){
                [memberManagerMenu addObject:model];
            }
            
        }
        [result addObject:classManagerMenu];
        [result addObject:memberManagerMenu];
        [rs close];
    }];
    return result;
}

/** 
 查询班级管理菜单 当无班级情况查询 schoolId -2010000000000
 */
- (NSArray *)queryClassManegerMenuWithSchoolId:(NSNumber *)schoolId{
    __block NSMutableArray *result = [NSMutableArray array];
    __block NSMutableArray *classManagerMenu = [NSMutableArray array];
    __block NSMutableArray *memberManagerMenu = [NSMutableArray array];
    __block FMResultSet *rs;
    
    NSString *sql = [NSString stringWithFormat:@"select * from tb_intelligence_menu where schoolId = %@;",schoolId];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            DWDIntelligenceMenuModel *model = [[DWDIntelligenceMenuModel alloc] init];
            model.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
            model.parentCode = [rs stringForColumn:@"parentCode"];
            model.parentName = [rs stringForColumn:@"parentName"];
            
            model.modeType = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"modeType"]];
            model.serialNumber = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"serialNumber"]];
            model.menuType = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"menuType"]];
            model.menuCode = [rs stringForColumn:@"menuCode"];
            model.menuName = [rs stringForColumn:@"menuName"];
            model.menuIcon = [rs stringForColumn:@"menuIcon"];
            model.funcDesc = [rs stringForColumn:@"funcDesc"];
            
            model.isOpen = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"isOpen"]];
            model.isShow = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"isShow"]];
            model.classId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]];
            
            
            if ([model.parentCode isEqualToString:@"A020101010101"]) {
                [classManagerMenu addObject:model];
            }else if ([model.parentCode isEqualToString:@"A020101010102"]){
                [memberManagerMenu addObject:model];
            }
            
        }
        [result addObject:classManagerMenu];
        [result addObject:memberManagerMenu];
        [rs close];
    }];
    return result;
}


/** 查询移动办公菜单 */
- (NSArray *)queryOfficeMenuWittSchoolId:(NSNumber *)schoolId{
    __block NSMutableArray *result = [NSMutableArray array];
    __block NSMutableArray *classManagerMenu = [NSMutableArray array];
    __block NSMutableArray *memberManagerMenu = [NSMutableArray array];
    __block FMResultSet *rs;
    
    NSString *sql = [NSString stringWithFormat:@"select * from tb_intelligence_menu where schoolId = %@;",schoolId];

    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        
        while (rs.next) {
            DWDIntelligenceMenuModel *model = [[DWDIntelligenceMenuModel alloc] init];
            model.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
            model.parentCode = [rs stringForColumn:@"parentCode"];
            model.parentName = [rs stringForColumn:@"parentName"];
            
            model.modeType = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"modeType"]];
            model.serialNumber = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"serialNumber"]];
            model.menuType = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"menuType"]];
            model.menuCode = [rs stringForColumn:@"menuCode"];
            model.menuName = [rs stringForColumn:@"menuName"];
            model.menuIcon = [rs stringForColumn:@"menuIcon"];
            model.funcDesc = [rs stringForColumn:@"funcDesc"];
            
            model.isOpen = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"isOpen"]];
            model.isShow = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"isShow"]];
            model.classId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]];
            
            
            if ([model.parentCode isEqualToString:@"A0201010201"]) {
                [classManagerMenu addObject:model];
            }else if ([model.parentCode isEqualToString:@"A0201010202"]){
                [memberManagerMenu addObject:model];
            }
            
        }
        [result addObject:classManagerMenu];
        [result addObject:memberManagerMenu];
        [rs close];
    }];
    return result;
}

#pragma mark - Delete
/**
 删除班级菜单
 */
- (void)deleteClassMenuWithClassId:(NSNumber *)classId success:(void(^)())success{
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"DELETE FROM tb_intelligence_menu WHERE classId = ?;",classId];
    }];
    if (result) success();
}
@end
