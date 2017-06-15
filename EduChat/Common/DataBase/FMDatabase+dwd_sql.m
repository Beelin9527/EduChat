//
//  FMDatabase+dwd_sql.m
//  EduChat
//
//  Created by KKK on 16/8/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "FMDatabase+dwd_sql.h"

//model
#import "DWDPickUpCenterListDataBaseModel.h"
#import "DWDPickUpCenterDataBaseModel.h"

#import "NSString+extend.h"

#import <YYModel.h>

@implementation FMDatabase (dwd_sql)

- (void)puc_saveOfflineSocketData:(NSData *)data {
    //消息拿到手,是DWDPickUpCenterDataBaseModel类型,首先进行解析
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DWDPickUpCenterDataBaseModel *model = [DWDPickUpCenterDataBaseModel yy_modelWithJSON:jsonStr];
    //根据自己的状态判断是教师端还是家长端,存储到不同的位置
    //解析处理一哈数据
    //补完databasemodel
    NSString *time = model.time;
    model.formatTime = [time formatTimeStringWithString];
    //拼接listmodel
    DWDPickUpCenterListDataBaseModel *listModel = [DWDPickUpCenterListDataBaseModel new];
    listModel.schoolId = model.schoolId;
    listModel.schoolName = model.schoolName;
    listModel.classId = model.classId;
    listModel.className = model.className;
    if (![DWDCustInfo shared].isLogin) return;
    //教师端
    if ([DWDCustInfo shared].isTeacher) {
        //要存2个地方
        //1.班级列表的更新
        //创建表
        [self puc_teacher_list_createTableIfNotExists];
        //是否插入
        FMResultSet *set = [self puc_teacher_list_selectTableWithClassId:model.classId];
        long badgeCount = [set longForColumn:@"BADGENUMBER"];
        if (![set next])
            [self puc_teacher_list_insertTableValue:listModel];
        [self puc_teacher_list_updateBadgeNumberWithClassId:model.classId badgeNumber:badgeCount + 1];
        //2.内部状态的更新
        NSString *tableName = [[model.classId stringValue] tableNameStringWithClassId];
        BOOL result = [self puc_teacher_class_createTableIfNotExists:tableName];
        if (result == NO) return;
        [self changes];
        result = [self puc_teacher_class_updateTableValue:model tableName:tableName];
        if (result == NO) return;
        //没有更新
        if ([self changes] == 0) {
            [self puc_teacher_class_insertTableValue:model tableName:tableName];
        }
    }
    //家长端
    else {
        //要存2个地方
        //1.班级列表的更新
        //2.内部状态的更新
    }
    
}

/**************教师**************/

/***班级列表增改查***/

//班级列表_创建
- (BOOL)puc_teacher_list_createTableIfNotExists {
    BOOL result;
    result = [self executeUpdate:@"CREATE TABLE IF NOT EXISTS PUC_CLASSLIST(\
              CLASSID       INTEGER,\
              CLASSNAME     TEXT,\
              SCHOOLID      INTEGER,\
              SCHOOLNAME    TEXT,\
              BADGENUMBER   INTEGER);"];
    return result;
    
}

//班级列表_插入
- (BOOL)puc_teacher_list_insertTableValue:(DWDPickUpCenterListDataBaseModel *)model {
    BOOL result;
    NSString *insertStr = @"INSERT INTO PUC_CLASSLIST (CLASSID, CLASSNAME, SCHOOLID, SCHOOLNAME, BADGENUMBER) VALUES (?, ?, ?, ?, ?);";
    result = [self executeUpdate:
              insertStr,
              model.classId,
              model.className,
              model.schoolId,
              model.schoolName,
              @(1)];
    return result;
}

/*
 班级列表_更新
 班级列表只需要更新badgeNumber
 此逻辑就是取出badge number, badge number + 1, 更新badge number
 
 此方法调用前肯定已经插入数据
 **/
- (BOOL)puc_teacher_list_updateBadgeNumberWithClassId:(NSNumber *)classId badgeNumber:(long)badgeNumber {
    BOOL result;
    NSString *updateStr = @"UPDATE PUC_CLASSLIST SET BADGENUMBER = ? WHERE CLASSID = ?;";
    result = [self executeUpdate:
              updateStr,
              @(badgeNumber),
              classId];
    return result;
}

//班级列表_查询
- (FMResultSet *)puc_teacher_list_selectTableWithClassId:(NSNumber *)classId {
    NSString *queryStr = @"SELECT * FROM PUC_CLASSLIST WHERE CLASSID = ?;";
    FMResultSet *resultSet = [self executeQuery:queryStr, classId];
    return resultSet;
}

/***班级成员增改查***/
//班级成员_创建
- (BOOL)puc_teacher_class_createTableIfNotExists:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (\
                     CUSTID             INTEGER,\
                     NAME               TEXT,\
                     PHOTOKEY           TEXT,\
                     SCHOOLID           INTEGER,\
                     SCHOOLNAME         TEXT,\
                     CLASSID            INTEGER,\
                     CLASSNAME          TEXT,\
                     CONTEXTUAL         TEXT,\
                     PHOTO              TEXT,\
                     DATE               TEXT,\
                     TIME               TEXT,\
                     RELATION           INTEGER,\
                     PARENTID           INTEGER,\
                     PARENTNAME         TEXT,\
                     PARENTPHOTOKEY     TEXT,\
                     TYPE               INTEGER,\
                     FORMATTIME         TEXT,\
                     TEACHERID          INTEGER,\
                     TEACHERNAME        TEXT,\
                     TEACHERPHOTOKEY    TEXT,\
                     INDEXCOUNT         INTEGER\
                     );", tableName];
    return [self executeUpdate:sql];
}

//班级成员_插入
- (BOOL)puc_teacher_class_insertTableValue:(DWDPickUpCenterDataBaseModel *)model
                                 tableName:(NSString *)tableName {
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", tableName];
    return [self executeUpdate:
            sqlStr,
            model.custId,
            model.name,
            model.photokey,
            model.schoolId,
            model.schoolName,
            model.classId,
            model.className,
            model.contextual,
            model.photo,
            model.date,
            model.time,
            model.relation,
            model.parent.custId,
            model.parent.name,
            model.parent.photokey,
            model.type,
            model.formatTime,
            model.teacher.custId,
            model.teacher.name,
            model.teacher.photokey,
            model.index];
    
}
//班级成员_更新
- (BOOL)puc_teacher_class_updateTableValue:(DWDPickUpCenterDataBaseModel *)model
                                 tableName:(NSString *)tableName {
    
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET PHOTO = ?, TIME = ?, FORMATTIME = ?,PHOTOKEY = ?, CONTEXTUAL = ?, RELATION = ?, PARENTID = ?, PARENTNAME = ?, PARENTPHOTOKEY = ?, TEACHERID = ?, TEACHERNAME = ?, TEACHERPHOTOKEY = ? WHERE DATE = ? AND TYPE = ? AND CUSTID = ? AND INDEXCOUNT = ?;", tableName];
    
    return  [self executeUpdate:
             sqlStr,
             model.photo,
             model.time,
             model.formatTime,
             model.photokey,
             model.contextual,
             model.relation,
             model.parent.custId,
             model.parent.name,
             model.parent.photokey,
             model.teacher.custId,
             model.teacher.name,
             model.teacher.photokey,
             model.date,
             model.type,
             model.custId,
             model.index];
}
//班级成员_查询
- (FMResultSet *)puc_teacher_selectClassTableWithModel:(DWDPickUpCenterDataBaseModel *)model
                                             tableName:(NSString *)tableName {
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ? AND CUSTID = ? AND TYPE = ? AND INDEXCOUNT = ?;", tableName];
    FMResultSet *result = [self executeQuery:
                           sqlStr,
                           model.date,
                           model.custId,
                           model.type,
                           model.index];
    return  result;
}

/**************家长**************/

/***班级列表增改查***/

//班级列表_创建
- (BOOL)puc_child_list_createTableIfNotExists {
    return [self executeUpdate:@"CREATE TABLE IF NOT EXISTS PUC_CHILDLIST(\
            CLASSID       TEXT,\
            CLASSNAME     TEXT,\
            SCHOOLID      TEXT,\
            SCHOOLNAME    TEXT,\
            BADGENUMBER   INTEGER);"];
}

//班级列表_插入
- (BOOL)puc_child_list_insertTableValue:(DWDPickUpCenterListDataBaseModel *)model {
    BOOL result;
    NSString *sqlStr = @"INSERT INTO PUC_CHILDLIST (CLASSID, CLASSNAME, SCHOOLID, SCHOOLNAME, BADGENUMBER) VALUES (?, ?, ?, ?, ?);";
        result = [self executeUpdate:
                  sqlStr,
                  model.classId,
                  model.className,
                  model.schoolId,
                  model.schoolName,
                  @(1)];
    return result;
}

//班级列表_更新
//更新badge number
- (BOOL)puc_child_list_updateBadgeNumberWithClassId:(NSNumber *)classId badgeNumber:(long)badgeNumber {
    BOOL result;
    NSString *updateStr = @"UPDATE PUC_CHILDLIST SET BADGENUMBER = ? WHERE CLASSID = ?;";
    
    FMResultSet *resultSet = [self puc_child_list_selectTableWithClassId:classId];
    //取出badge number
    long count;
    if ([resultSet next]) {
        count = [resultSet longForColumn:@"BADGENUMBER"];
    } else {
        return NO;
    }
    //badge number + 1
    count += 1;
    result = [self executeUpdate:
              updateStr,
              @(count),
              classId];
    return result;
}

//班级列表_查询
- (FMResultSet *)puc_child_list_selectTableWithClassId:(NSNumber *)classId {
    NSString *queryStr = @"SELECT * FROM PUC_CHILDLIST WHERE CLASSID = ?;";
    FMResultSet *resultSet = [self executeQuery:queryStr, classId];
    return resultSet;
}

/***班级成员增改查***/
//班级成员_创建
- (BOOL)puc_child_class_createTableIfNotExists:(NSString *)tableName {
    NSString *sql =[NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@ (\
                    CUSTID             INTEGER,\
                    NAME               TEXT,\
                    PHOTOKEY           TEXT,\
                    SCHOOLID           INTEGER,\
                    SCHOOLNAME         TEXT,\
                    CLASSID            INTEGER,\
                    CLASSNAME          TEXT,\
                    CONTEXTUAL         TEXT,\
                    PHOTO              TEXT,\
                    DATE               TEXT,\
                    TIME               TEXT,\
                    RELATION           INTEGER,\
                    PARENTID           INTEGER,\
                    PARENTNAME         TEXT,\
                    PARENTPHOTOKEY     TEXT,\
                    TYPE               INTEGER,\
                    FORMATTIME         TEXT,\
                    TEACHERID          INTEGER,\
                    TEACHERNAME        TEXT,\
                    TEACHERPHOTOKEY    TEXT,\
                    INDEXCOUNT         INTEGER\
                    );", tableName];
    return [self executeUpdate:sql];
}

//班级成员_插入
- (BOOL)puc_child_class_insertTabeleValue:(DWDPickUpCenterDataBaseModel *)model
                                tableName:(NSString *)tableName {
    
    BOOL result = NO;
    
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", tableName];
    result = [self executeUpdate:
              sqlStr,
              model.custId,
              model.name,
              model.photokey,
              model.schoolId,
              model.schoolName,
              model.classId,
              model.className,
              model.contextual,
              model.photo,
              model.date,
              model.time,
              model.relation,
              model.parent.custId,
              model.parent.name,
              model.parent.photokey,
              model.type,
              model.formatTime,
              model.teacher.custId,
              model.teacher.name,
              model.teacher.photokey,
              model.index];
    return result;
}

@end
