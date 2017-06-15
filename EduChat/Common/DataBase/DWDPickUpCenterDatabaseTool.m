//
//  DWDPickUpCenterClient.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterDatabaseTool.h"

#import "DWDPickUpCenterDataBaseModel.h"
#import "DWDPickUpCenterJsonDataModel.h"
#import "DWDPickUpCenterListDataBaseModel.h"

#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDPickUpCenterStudentsCountModel.h"

#import "DWDRecentChatDatabaseTool.h"

#import "NSString+extend.h"
#import "NSDate+dwd_dateCategory.h"

#import <FMDB.h>
#import <YYModel.h>

@implementation DWDPickUpCenterDatabaseTool
{
    BOOL needSub;
}


DWDSingletonM(Manager)

#pragma mark - Public Method
- (instancetype)init {
    
    self = [super init];
    [DWDDataBaseHelper sharedManager];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveSystemMessage:)
                                                     name:@"receive_pickupCenter_notification" object:nil];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
//接受系统消息通知
- (void)receiveSystemMessage:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
//    NSString *code = userInfo[@"receive_new_msg_key"][@"code"];
    
//    if (needSub == YES) {
//        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] minusOneNumToRecentChatWithFriendId:@1001 myCusId:[DWDCustInfo shared].custId success:^{
//        } failure:^{
//        }];
//    }
    
    DWDPickUpCenterJsonDataModel *jsonModel = [DWDPickUpCenterJsonDataModel yy_modelWithJSON:userInfo[@"receive_new_msg_key"]];
    //解析数据
    DWDPickUpCenterDataBaseModel *dbModel = jsonModel.entity;
    NSString *time = jsonModel.entity.time;
    dbModel.formatTime = [time formatTimeStringWithString];
    
    DWDPickUpCenterListDataBaseModel *listModel = [DWDPickUpCenterListDataBaseModel new];
    listModel.schoolId = dbModel.schoolId;
    listModel.schoolName = dbModel.schoolName;
    listModel.classId = dbModel.classId;
    listModel.className = dbModel.className;
    BOOL resultBOOL;
    if ([DWDCustInfo shared].isTeacher) {
        //老师

        //查询是否有班级,没有班级进行插入班级列表,完成后进行badgenumber + 1
        [self insertToTeacherListDB:listModel];
        [self plusOneTeacherListlBadgeNumber:dbModel];

        if ([self selectTeacherValueExists:dbModel]) {
            //更新
            [self updateTeacherCurrentStatus:dbModel];
            resultBOOL = YES;
        } else {
            //插入
           resultBOOL = [self insertToTeacherDB:dbModel];
        }
        //发通知
        if ([dbModel.type isEqualToNumber:@1]) {
            //上学
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDPickUpCenterDidUpdateTeacherGoSchool object:nil userInfo:@{@"classId" : dbModel.classId}];
        }
        else if ([dbModel.type isEqualToNumber:@2]) {
            //放学
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDPickUpCenterDidUpdateTeacherLeaveSchool object:nil userInfo:@{@"classId" : dbModel.classId}];
        }
    } else {
        //家长
        
        //查询是否有班级,没有班级进行插入班级列表,完成后进行badgenumber + 1
        [self insertToChildListDB:listModel];
        [self plusOneChildListlBadgeNumber:dbModel.classId];
        
        //插入到孩子数据库
        if ([self insertToChildDB:dbModel]) {
            //插入到孩子列表
            /*
             
             badge number
             
             */
            //发通知
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDPickUpCenterDidUpdateChildInfomation object:nil];
        };
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DWDPickUpCenterDidUpdateListInfomation object:nil];
}

- (DWDPickUpCenterDataBaseModel *)formatDetailDataBase:(FMResultSet *)result {
    DWDPickUpCenterDataBaseModel *dataModel = [[DWDPickUpCenterDataBaseModel alloc] init];

    dataModel.custId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"CUSTID"]];
    dataModel.name = [result stringForColumn:@"NAME"];
    dataModel.photokey = [result stringForColumn:@"PHOTOKEY"];
    dataModel.schoolId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"SCHOOLID"]];
    dataModel.schoolName = [result stringForColumn:@"SCHOOLNAME"];
    dataModel.classId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"CLASSID"]];
    dataModel.className = [result stringForColumn:@"CLASSNAME"];
    dataModel.contextual = [result stringForColumn:@"CONTEXTUAL"];
    dataModel.photo = [result stringForColumn:@"PHOTO"];
    dataModel.date = [result stringForColumn:@"DATE"];
    dataModel.time = [result stringForColumn:@"TIME"];
    dataModel.relation = [NSNumber numberWithInt:[result intForColumn:@"RELATION"]];
    dataModel.formatTime = [result stringForColumn:@"FORMATTIME"];
    dataModel.parent.custId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"PARENTID"]];
    dataModel.parent.name = [result stringForColumn:@"PARENTNAME"];
    dataModel.parent.photokey = [result stringForColumn:@"PARENTPHOTOKEY"];
    
    dataModel.teacher.custId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"TEACHERID"]];
    dataModel.teacher.name = [result stringForColumn:@"TEACHERNAME"];
    dataModel.teacher.photokey = [result stringForColumn:@"TEACHERPHOTOKEY"];
    
    dataModel.index = [NSNumber numberWithInteger:[result intForColumn:@"INDEXCOUNT"]];
    dataModel.type = [NSNumber numberWithInt:[result intForColumn:@"TYPE"]];
    
    return dataModel;
}

- (DWDPickUpCenterListDataBaseModel *)formatListDataBase:(FMResultSet *)result {
    DWDPickUpCenterListDataBaseModel *dataModel = [[DWDPickUpCenterListDataBaseModel alloc] init];
    dataModel.schoolId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"SCHOOLID"]];
    dataModel.schoolName = [result stringForColumn:@"SCHOOLNAME"];
    dataModel.classId = [NSNumber numberWithLongLong:[result longLongIntForColumn:@"CLASSID"]];
    dataModel.className = [result stringForColumn:@"CLASSNAME"];
    dataModel.badgeNumber = [NSNumber numberWithInt:[result intForColumn:@"BADGENUMBER"]];
    return dataModel;
}

- (NSArray *)formatCalendarRequestResult:(FMResultSet *)result {
    NSArray *array = [NSArray yy_modelArrayWithClass:[DWDPickUpCenterStudentsCountModel class] json:[result dataForColumn:@"RESPONSE_ARRAY"]];
//    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[result dataForColumn:@"RESPONSE_ARRAY"]];
    return array;
}


#pragma mark - Advance FMDB Method

#pragma mark - /*      Teacher      */
/* 更新 */
//更新当前状态
- (void)updateTeacherCurrentStatus:(DWDPickUpCenterDataBaseModel *)dataModel {

    
    __block BOOL resultBOOL = NO;
//    TEACHERID          INTEGER,\
//    TEACHERNAME        TEXT,\
//    TEACHERPHOTOKEY    TEXT
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE %@ SET PHOTO = ?, TIME = ?, FORMATTIME = ?,PHOTOKEY = ?, CONTEXTUAL = ?, RELATION = ?, PARENTID = ?, PARENTNAME = ?, PARENTPHOTOKEY = ?, TEACHERID = ?, TEACHERNAME = ?, TEACHERPHOTOKEY = ? WHERE DATE = ? AND TYPE = ? AND CUSTID = ? AND INDEXCOUNT = ?;", [[dataModel.classId stringValue] tableNameStringWithClassId]];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        resultBOOL = [db executeUpdate:sqlStr,dataModel.photo,dataModel.time, dataModel.formatTime, dataModel.photokey, dataModel.contextual, dataModel.relation, dataModel.parent.custId, dataModel.parent.name, dataModel.parent.photokey, dataModel.teacher.custId, dataModel.teacher.name, dataModel.teacher.photokey,
                      dataModel.date, dataModel.type, dataModel.custId, dataModel.index];
    }];
}

//badge number + 1
- (void)plusOneTeacherListlBadgeNumber:(DWDPickUpCenterDataBaseModel *)dataModel {
    
//    CLASSID       INTEGER,\
//    CLASSNAME     TEXT,\
//    SCHOOLID      INTEGER,\
//    SCHOOLNAME    TEXT,\
//    BADGENUMBER   INTEGER);"];
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE PUC_CLASSLIST SET BADGENUMBER = BADGENUMBER + 1, CLASSNAME = ?, SCHOOLNAME = ? WHERE CLASSID = ?;"];
//    NSNumber *badgeNumber = [self badgeNumberWithClassId:classId];
//    NSInteger badge = [badgeNumber integerValue] + 1;
//    badgeNumber = [NSNumber numberWithInteger:badge];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sqlStr, dataModel.className, dataModel.schoolName, dataModel.classId];
    }];
}

//清除某一个班级的badge number 并且清除最近联系人列表的badge number
- (void)subTeacherListBadgeNumberWithClassId:(NSNumber *)classId
                                     subNumber:(NSNumber *)subNumber{
    [self subListBadgeNumber:subNumber withClassId:classId type:@"PUC_CLASSLIST"];
}

/* 查询 */
//查询班级详情
- (NSArray *)selectWhichDate:(NSString *)dateStr
                        type:(NSNumber *)type
                       index:(NSNumber *)index
  teacherDataBaseWithClassId:(NSNumber *)classId {
    
    NSString *tableName = [[classId stringValue] tableNameStringWithClassId];
    NSMutableArray *resultArray = [NSMutableArray new];
    //        SELECT * FROM COMPANY WHERE AGE >= 25
    
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ? AND TYPE = ? AND INDEXCOUNT = ? ORDER BY TIME;", tableName];
//    DWDMarkLog(@"sql:%@, date:%@, type:%@", sqlStr, dateStr, type);
    
    WEAKSELF;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            FMResultSet *result = [db executeQuery:sqlStr, dateStr, type, index];
            while ([result next])
                [resultArray addObject:[weakSelf formatDetailDataBase:result]];
            [result close];
        }
    }];
    
//    NSMutableArray *array = [NSMutableArray new];
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        FMResultSet *result = [db executeQuery:@"SELECT * FROM pucT_8010000001378"];
//        while ([result next]) {
//            [array addObject:[weakSelf formatDetailDataBase:result]];
//        }
//    }];
//    DWDMarkLog(@"%@", array);
    
    return resultArray;
}

//查询时间轴详情
- (NSArray *)selectTimelineWhichDate:(NSString *)dateStr
                                type:(NSNumber *)type
          teacherDataBaseWithClassId:(NSNumber *)classId {
    NSString *tableName = [[classId stringValue] tableNameStringWithClassId];
    NSMutableArray *resultArray = [NSMutableArray new];
    
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ? AND TYPE = ? AND (CONTEXTUAL = ? OR CONTEXTUAL = ? OR CONTEXTUAL = ?) ORDER BY TIME DESC;", tableName];
    WEAKSELF;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            FMResultSet *result = [db executeQuery:sqlStr, dateStr, type, @"Reachschool", @"Getoutschool", @"OffAfterschoolBus"];
            while ([result next])
                [resultArray addObject:[weakSelf formatDetailDataBase:result]];
            [result close];
        }
    }];
    
    return resultArray;
}

//查询列表
- (NSArray *)selectTeacherList {
    NSMutableArray *resultArray = [NSMutableArray new];
    NSString *sqlStr = @"SELECT * FROM PUC_CLASSLIST;";
    WEAKSELF;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr];
        while ([result next]) {
            [resultArray addObject:[weakSelf formatListDataBase:result]];
        }
        [result close];
    }];
    
    return resultArray;
}

//查询是否有值,更新还是插入
- (BOOL)selectTeacherValueExists:(DWDPickUpCenterDataBaseModel *)dataModel {
    NSString *tableName = [[dataModel.classId stringValue] tableNameStringWithClassId];
    //建表
    if (![self createTeacherTable:tableName])
        return NO;
    
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ? AND CUSTID = ? AND TYPE = ? AND INDEXCOUNT = ?;", [[dataModel.classId stringValue] tableNameStringWithClassId]];
    __block BOOL resultBOOL = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr, dataModel.date, dataModel.custId, dataModel.type, dataModel.index];
        if ([result next]) {
            resultBOOL = YES;
        }
        [result close];
    }];
    return resultBOOL;
}

//查询是否有值,更新还是插入
- (BOOL)selectTeacherListValueExists:(DWDPickUpCenterListDataBaseModel *)dataModel {
    //建表
    
    NSString *sqlStr = @"SELECT * FROM PUC_CLASSLIST WHERE CLASSID = ?";
    __block BOOL resultBOOL = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr, dataModel.classId];
        if ([result next]) {
            resultBOOL = YES;
        }
        [result close];
    }];
    return resultBOOL;
}

//查询当前BadgeNumber
- (NSNumber *)badgeNumberWithClassId:(NSNumber *)classId {
    //    PUC_CLASSLIST SET BADGENUMBER = ? WHERE CLASSID = ?;
    
    __block NSNumber *badgeNumber = [[NSNumber alloc] init];
    NSString *sqlStr;
    if ([DWDCustInfo shared].isTeacher) {
        sqlStr = [NSString stringWithFormat:@"SELECT * FROM PUC_CLASSLIST WHERE CLASSID = ?;"];
    } else {
        sqlStr = [NSString stringWithFormat:@"SELECT * FROM PUC_CHILDLIST WHERE CLASSID = ?;"];
    }
    
    __block BOOL resultBOOL;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr, classId];
        if ([result next]) {
            resultBOOL = YES;
            badgeNumber = [NSNumber numberWithInt:[result intForColumn:@"BADGENUMBER"]];
        }
        [result close];
    }];
    return badgeNumber;
}

/* 存储数据 */

- (BOOL)insertToTeacherDB:(DWDPickUpCenterDataBaseModel *)dataBase {
    NSString *tableName = [[dataBase.classId stringValue] tableNameStringWithClassId];
    //建表
    if (![self createTeacherTable:tableName])
        return NO;
    //插入数据
    __block BOOL result;
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", tableName];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sqlStr, dataBase.custId, dataBase.name, dataBase.photokey,dataBase.schoolId, dataBase.schoolName, dataBase.classId, dataBase.className, dataBase.contextual, dataBase.photo, dataBase.date, dataBase.time, dataBase.relation, dataBase.parent.custId, dataBase.parent.name, dataBase.parent.photokey, dataBase.type, dataBase.formatTime, dataBase.teacher.custId, dataBase.teacher.name, dataBase.teacher.photokey, dataBase.index];
    }];
    return result;
}

- (BOOL)insertToTeacherListDB:(DWDPickUpCenterListDataBaseModel *)dataBase {
    //建表
    if (![self createTeacherListTable])
        return NO;
    if ([self selectTeacherListValueExists:dataBase]) {
        return NO;
    }
    __block BOOL result = NO;
    NSString *sqlStr = @"INSERT INTO PUC_CLASSLIST (CLASSID, CLASSNAME, SCHOOLID, SCHOOLNAME, BADGENUMBER) VALUES (?, ?, ?, ?, ?);";
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sqlStr, dataBase.classId, dataBase.className, dataBase.schoolId, dataBase.schoolName, @0];
    }];
    return result;
}

/* 建表 */
- (BOOL)createTeacherTable:(NSString *)tableName {
    //建以班级id为表名的表
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
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
            result = [db executeUpdate:sql];
        } else
            result = YES;
    }];
    //成功或者已存在就返回YES
    return result;
}

- (BOOL)createTeacherListTable {
    //建以班级id为表名的表
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"PUC_CLASSLIST"])
            result = [db executeUpdate:@"CREATE TABLE PUC_CLASSLIST(\
                      CLASSID       INTEGER,\
                      CLASSNAME     TEXT,\
                      SCHOOLID      INTEGER,\
                      SCHOOLNAME    TEXT,\
                      BADGENUMBER   INTEGER);"];
        else
            result = YES;
    }];
    //成功或者已存在就返回YES
    return result;
}

- (DWDPickUpCenterDataBaseModel *)selectLastDataWithClassId:(NSNumber *)classId {
    
    NSString *tableName = [[classId stringValue] tableNameStringWithClassId];
    //        SELECT * FROM COMPANY WHERE AGE >= 25
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ? ORDER BY TIME DESC LIMIT 1;", tableName];
    __block DWDPickUpCenterDataBaseModel *data;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            FMResultSet *result = [db executeQuery:sqlStr, [NSDate dateString:[NSDate date]]];
            if (result.next) {
                data = [self formatDetailDataBase:result];
            } else {
                data = nil;
            }
            [result close];
        }
    }];
    return data;
}

#pragma mark - /*      Child      */
//查询班级详情
- (NSArray *)selectWhichDate:(NSString *)dateStr
    ChildDataBaseWithClassId:(NSNumber *)classId {
    NSString *tableName = [[classId stringValue] tableNameStringWithChildId];
    NSMutableArray *resultArray = [NSMutableArray new];
    
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ? ORDER BY TIME DESC;", tableName];
    //    DWDMarkLog(@"sql:%@, date:%@, type:%@", sqlStr, dateStr, type);
    
    WEAKSELF;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            FMResultSet *result = [db executeQuery:sqlStr, dateStr];
            while ([result next])
                [resultArray addObject:[weakSelf formatDetailDataBase:result]];
            [result close];
        }
    }];
    /*
     真机取数据
     **/
    NSMutableArray *array = [NSMutableArray new];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM ? WHRER YTPE = 1", tableName];
        while ([result next]) {
            [array addObject:[weakSelf formatDetailDataBase:result]];
        }
    }];
    DWDMarkLog(@"%@", array);
    
    return resultArray;
}

//查询列表
- (NSArray *)selectChildList {
    NSMutableArray *resultArray = [NSMutableArray new];
    NSString *sqlStr = @"SELECT * FROM PUC_CHILDLIST;";
    WEAKSELF;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr];
        while ([result next]) {
            [resultArray addObject:[weakSelf formatListDataBase:result]];
        }
        [result close];
    }];
    
    return resultArray;
}

//查询是否有值,更新还是插入
- (BOOL)selectChildListValueExists:(DWDPickUpCenterListDataBaseModel *)dataModel {
    //建表
    
    NSString *sqlStr = @"SELECT * FROM PUC_CHILDLIST WHERE CLASSID = ?";
    __block BOOL resultBOOL = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:sqlStr, dataModel.classId];
        if ([result next]) {
            resultBOOL = YES;
        }
        [result close];
    }];
    return resultBOOL;
}

//badge number + 1
- (void)plusOneChildListlBadgeNumber:(NSNumber *)classId {
    
    NSString *sqlStr = [NSString stringWithFormat:@"UPDATE PUC_CHILDLIST SET BADGENUMBER = ? WHERE CLASSID = ?;"];
    NSNumber *badgeNumber = [self badgeNumberWithClassId:classId];
    NSInteger badge = [badgeNumber integerValue] + 1;
    badgeNumber = [NSNumber numberWithInteger:badge];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sqlStr, badgeNumber, classId];
    }];
}

//clear badge number
- (void)subChildListBadgeNumberWithClassId:(NSNumber *)classId
                                   subNumber:(NSNumber *)subNumber {
    
    [self subListBadgeNumber:subNumber withClassId:classId type:@"PUC_CHILDLIST"];
}

- (BOOL)insertToChildDB:(DWDPickUpCenterDataBaseModel *)dataBase {
    NSString *tableName = [[dataBase.classId stringValue] tableNameStringWithChildId];
    
    if (![self createChildTable:tableName])
        return NO;

    __block BOOL result = NO;

    
    NSString *checkExistsSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE CUSTID = ? AND CONTEXTUAL = ? AND DATE = ? AND TIME = ?;", tableName];
    
    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", tableName];
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:checkExistsSql, dataBase.custId, dataBase.contextual, dataBase.date, dataBase.time];
        if (set.next) {
            [set close];
            result = NO;
            return;
        }
        [set close];
        result = [db executeUpdate:sqlStr, dataBase.custId, dataBase.name, dataBase.photokey,dataBase.schoolId, dataBase.schoolName, dataBase.classId, dataBase.className, dataBase.contextual, dataBase.photo, dataBase.date, dataBase.time, dataBase.relation, dataBase.parent.custId, dataBase.parent.name, dataBase.parent.photokey, dataBase.type, dataBase.formatTime, dataBase.teacher.custId, dataBase.teacher.name, dataBase.teacher.photokey, dataBase.index];
    }];
    return result;
}

- (BOOL)insertToChildListDB:(DWDPickUpCenterListDataBaseModel *)dataBase {
    //建表
    if (![self createChildListTable])
        return NO;
    //插入数据
    if ([self selectChildListValueExists:dataBase]) {
        return NO;
    }
    //不存在就插入数据 badgenumber + 1
    __block BOOL result = NO;
    NSString *sqlStr = @"INSERT INTO PUC_CHILDLIST (CLASSID, CLASSNAME, SCHOOLID, SCHOOLNAME) VALUES (?, ?, ?, ?);";
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:sqlStr, dataBase.classId, dataBase.className, dataBase.schoolId, dataBase.schoolName];
    }];
    return result;
}

- (BOOL)createChildTable:(NSString *)tableName {
    //建以班级id为表名的表
    __block BOOL result = NO;
    //成功或者已存在就返回YES
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (![db tableExists:tableName]) {
            
            NSString *sql =[NSString stringWithFormat: @"CREATE TABLE %@ (\
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
            result = [db executeUpdate:sql];
        } else
            result = YES;
    }];
    
    return result;
}

- (BOOL)createChildListTable {
    //建以PUC_CHILDLIST为表名的表
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"PUC_CHILDLIST"])
            result = [db executeUpdate:@"CREATE TABLE PUC_CHILDLIST(\
                      CLASSID       TEXT,\
                      CLASSNAME     TEXT,\
                      SCHOOLID      TEXT,\
                      SCHOOLNAME    TEXT,\
                      BADGENUMBER   INTEGER);"];
        else
            result = YES;
    }];
    //成功或者已存在就返回YES
    return result;
}

#pragma mark - /* total students 日历中学生的数据库缓存 */

/**
 依据模型 : DWDPickUpCenterStudentsCountModel
 */
/**
 捋逻辑:
 当你进入日历时面临一个抉择,是发请求还是不发请求?
 
 在helper中判断
 首先取数据,如果没有数据就发嘛
 收到数据之后判断 complete 如果complete 获取数据的成功block里存
 如果不是完整数据(根据complete的值) 不要存,每次都发请求就好了哈
 发请求记得取消前面的请求
 
 */
#pragma mark - Public Method
- (void)insertCalendarRequest:(NSArray *)data date:(NSString *)date withClassId:(NSNumber *)classId {
    //插入数据到缓存表
    NSString *tableName = [classId.stringValue tableCalendarNameString];
    if ([self createCalendarRequsetWithTableName:tableName]) {
            //插入数据
            NSString *sqlStr =[NSString stringWithFormat:@"INSERT INTO %@ VALUES (?, ?);", tableName];
//        NSData *blobData = [NSKeyedArchiver archivedDataWithRootObject:data];
        NSData *blobData = [data yy_modelToJSONData];
            [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
                if ([db tableExists:tableName]) {
                [db executeUpdate:sqlStr, date, blobData];
                }
            }];
    }
}

- (NSArray *)selectCalendarWithDate:(NSString *)date withClassId:(NSNumber *)classId{
    //查询数据
    __block NSArray *array;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ?;", [classId.stringValue tableCalendarNameString]];
        if ([db tableExists:[classId.stringValue tableCalendarNameString]]) {
            FMResultSet *set = [db executeQuery:sqlStr, date];
            if (set.next) {
                array = [self formatCalendarRequestResult:set];
            } else {
                array = nil;
            }
            [set close];
        }
    }];
    return array;
}
#pragma mark - Private Method
//- (BOOL)isCalendarRequestDataExist:(DWDPickUpCenterStudentsCountModel *)data withClassId:(NSNumber *)classId {
//    //确认数据是否存在
//    __block BOOL result = NO;
//    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
//        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE DATE = ?;", [classId.stringValue tableCalendarNameString]];
//        FMResultSet *set = [db executeQuery:sqlStr];
//        if (set.next) {
//            result = YES;
//        } else {
//            result = NO;
//        }
//        [set close];
//    }];
//    return result;
//}

- (BOOL)createCalendarRequsetWithTableName:(NSString *)tableName {
    //创建日历请求数据缓存表
    __block BOOL result = NO;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        if ([db tableExists:tableName]) {
            result = YES;
        } else {
            NSString *sql = [NSString stringWithFormat:\
                             @"CREATE TABLE %@ (\
                             DATE               TEXT,\
                             RESPONSE_ARRAY     BLOB\
                             );", tableName];
            result = [db executeUpdate:sql];
        }
    }];
    return result;
}

- (void)subListBadgeNumber:(NSNumber *)subNumber
               withClassId:(NSNumber *)classId
                      type:(NSString *)type {
    NSString *sqlStr_puc = [NSString stringWithFormat:@"UPDATE %@ SET BADGENUMBER = ? WHERE CLASSID = ?;", type];
    NSString *sqlStr_rec = [NSString stringWithFormat:@"UPDATE TB_RECENTCHATLIST SET BADGECOUNT = ? WHERE CUSTID = ?;"];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        NSInteger badgecount;
        FMResultSet *set = [db executeQuery:@"SELECT * FROM tb_recentchatlist WHERE CUSTID = ?;", @1001];
        if (set.next) {
            badgecount = [set intForColumn:@"BADGECOUNT"];
            DWDLog(@"%zd", badgecount);
        }
        [set close];
        
        [db executeUpdate:sqlStr_puc, @0, classId];
        [db executeUpdate:sqlStr_rec, @((badgecount - [subNumber integerValue]) > 0 ? (badgecount - [subNumber integerValue]) : 0), @1001];
        
        set = [db executeQuery:@"SELECT * FROM TB_RECENTCHATLIST WHERE CUSTID = ?;", @1001];
        if (set.next) {
            NSInteger badgecount = [set intForColumn:@"badgeCount"];
            DWDLog(@"%zd", badgecount);
        }
        [set close];
    }];
}


//#pragma mark - Public Method
//- (void)insertValueToTotalStudentsTabel:(DWDTeacherGoSchoolStudentDetailModel *)data withClassId:(NSNumber *)classId {
//    
//}
//
//- (DWDTeacherGoSchoolStudentDetailModel *)getTotalStudentsValueWithDate:(NSString *)date index:(NSNumber *)index type:(NSNumber *)type {
//    DWDTeacherGoSchoolStudentDetailModel *data;
//    
//    return data;
//}
//
//#pragma mark - Private Method
//- (BOOL)createTotalStudentsTabelWithClassId:(NSNumber *)classId {
//    return YES;
//}
//
//- (BOOL)ifTotalStudentsValue:(DWDTeacherGoSchoolStudentDetailModel *)data existsWithDate:(NSString *)date classId:(NSNumber *)classId {
//    return YES;
//}

#pragma mark - Badge Count
- (void)badgeNumberNeedSub {
    needSub = YES;
}

- (void)badgeNumberDontNeedSub {
    needSub = NO;
}

- (int)getBadgeNumberWithClassId:(NSNumber *)classId listTableName:(NSString *)tableName {
    
    __block int badgeNumber = 0;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE CLASSID = ?;", tableName];
    
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
     FMResultSet *set = [db executeQuery:sql, classId];
        if (set.next) {
            badgeNumber = [set intForColumn:@"BADGENUMBER"];
        }
        [set close];
    }];
    
    return badgeNumber;
}


@end
