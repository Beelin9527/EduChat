//
//  DWDShcoolDataBaseTool.m
//  EduChat
//
//  Created by Beelin on 16/12/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSchoolDataBaseTool.h"
#import <FMDB/FMDB.h>

@implementation DWDSchoolDataBaseTool
+(instancetype)sharedSchoolDataBase
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

/**
 * 创建学校表 schoolTable
 classId 为0 是空模板
 classId 为1 是有学校无班级，指校务人员。疑惑的话，找产品经理与后台同事吧 2016.12.20
 本地字段名            描述          服务器返回字段名
 schoolId            学校id           sid
 schoolName          学校名           schlNm
 classId             班级id           cgid
 className           班级名           cgNm
 
 */
#pragma mark - Create Table
- (void)createTable
{
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        
        //创建班级成员表
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS tb_school (\
                         id INTEGER PRIMARY KEY AUTOINCREMENT,\
                         schoolId       INTEGER,\
                         schoolName     TEXT,\
                         classId       INTEGER NOT NULL DEFAULT 0 UNIQUE,\
                         className     TEXT\
                         );"
                         ];
        [db executeUpdate:sql];
    }];
}


- (void)reCreateTables
{
    [self createTable];
}


#pragma mark - Insert
- (BOOL)insertSchoolTalbeWithArrayModel:(NSArray<DWDSchoolModel *> *)arrayModel{
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] beginTransactionInDatabase:^(FMDatabase *db, BOOL *rollback) {
        for(DWDSchoolModel *model in arrayModel){
            result =  [db executeUpdate:@"REPLACE INTO tb_school ( \
                       schoolId ,\
                       schoolName,\
                       classId ,\
                       className)\
                       VALUES(?, ?, ?, ?);"
                       ,model.schoolId,
                       model.schoolName,
                       model.classId,
                       model.className];
        }
        if (!result) {
            *rollback = YES;
            return;
        }
    }];
    return result;
}

#pragma mark - Query

- (NSArray *)querySchoolAndClass{
    __block NSMutableArray *result = [NSMutableArray array];
    __block FMResultSet *rs;

    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
         //排除空模板学校
        rs = [db executeQuery:@"select * from tb_school where schoolId != '-2010000000000' group by schoolId;"];
        while (rs.next) {
            DWDSchoolModel *model = [[DWDSchoolModel alloc] init];
            model.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
            model.schoolName = [rs stringForColumn:@"schoolName"];
        
            [result addObject:model];
        }
        
        //数组为空，说明没有学校，查询空模板学校显示。
        if (result.count == 0) {
            rs = [db executeQuery:@"select schoolId , schoolName from tb_school where schoolId = -2010000000000;"];
            while (rs.next) {
                DWDSchoolModel *model = [[DWDSchoolModel alloc] init];
                model.schoolId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"schoolId"]];
                model.schoolName = [rs stringForColumn:@"schoolName"];
                
                [result addObject:model];
            }

        }
        [rs close];
    }];
    
   
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        ;
        for (DWDSchoolModel *model in result) {
            
            NSMutableArray *classM = [NSMutableArray array];
            
            NSString *sql = [NSString stringWithFormat:@"select classId , className from tb_school where schoolId = %@ and classId != 1;",model.schoolId];
            rs = [db executeQuery:sql];
            while (rs.next) {
                DWDIntClassModel *classModel = [[DWDIntClassModel alloc] init];
                classModel.classId = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"classId"]];
                classModel.className = [rs stringForColumn:@"className"];
                [classM addObject:classModel];
                model.arrayClassModel = classM.mutableCopy;
            }
        }
        [rs close];
    }];
    
    return result;
}


/**
 删除班级
 */
- (void)deleteClassWithClassId:(NSNumber *)classId success:(void(^)())success{
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
      
       result = [db executeUpdate:@"DELETE FROM tb_school WHERE classId = ?;",classId];
    }];
    if (result) success();
}

@end
