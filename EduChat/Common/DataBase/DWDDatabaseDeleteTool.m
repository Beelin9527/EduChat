//
//  DWDDatabaseDeleteTool.m
//  EduChat
//
//  Created by KKK on 16/11/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define completeDeleteCustidArray @"completeDeleteCustidArray"

#import "DWDDatabaseDeleteTool.h"

#import "DWDDataBaseHelper.h"
#import <FMDB.h>

@implementation DWDDatabaseDeleteTool

+ (void)deleteChatRecordTimeRows {
    NSArray *completeArray = [[NSUserDefaults standardUserDefaults] objectForKey:completeDeleteCustidArray];
    if (completeArray)
        if ([completeArray containsObject:[DWDCustInfo shared].custId])
            return;
    __block NSArray *tableNamesArray;
    [[DWDDataBaseHelper sharedManager] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT name FROM sqlite_master WHERE type='table';"];
        NSMutableArray *array = [NSMutableArray array];
        while ([result next]) {
            NSString *tableName = [result stringForColumn:@"name"];
            if ([tableName hasPrefix:@"tb_c2c_"] || [tableName hasPrefix:@"tb_c2m_"]) {
                [array addObject:tableName];
            }
        }
        [result close];
        tableNamesArray = array;
    }];

    //now get all useful table names
    //enum table delete time row
    [[DWDDataBaseHelper sharedManager] beginTransactionInDatabase:^(FMDatabase *db, BOOL *rollback) {
        for (NSString *tableName in tableNamesArray) {
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE MSGTYPE = ?;", tableName];
            [db executeUpdate:deleteSql, @"time"];
        }
        if (*rollback == NO) {
            //set plist complete
            if (completeArray == nil) {
                NSMutableArray *newArray = [NSMutableArray arrayWithObject:[DWDCustInfo shared].custId];
                [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:completeDeleteCustidArray];
            } else {
                NSMutableArray *newArray = [completeArray mutableCopy];
                [newArray addObject:[DWDCustInfo shared].custId];
                [[NSUserDefaults standardUserDefaults] setObject:newArray forKey:completeDeleteCustidArray];
            }
        } else {
            //exception
            [db rollback];
        }
    }];
}

@end
