//
//  DWDDataBaseHelper.m
//  EduChat
//
//  Created by KKK on 16/3/28.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDDataBaseHelper.h"
#import <FMDB.h>

@implementation DWDDataBaseHelper
{
    FMDatabaseQueue* queue;
}

DWDSingletonM(Manager);

- (instancetype)init {
    self = [super init];
    if(self){
        queue = [FMDatabaseQueue databaseQueueWithPath:DWDDatabasePath];
    }
    return self;
}


-(void) inDatabase:(void(^)(FMDatabase *db))block
{
    [queue inDatabase:^(FMDatabase *db){
        block(db);
    }];
}

- (void)beginTransactionInDatabase:(void (^)(FMDatabase *, BOOL *))block {
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        block(db, rollback);
    }];
}

-(void)resetDB {
    queue = [FMDatabaseQueue databaseQueueWithPath:DWDDatabasePath];
}

@end
