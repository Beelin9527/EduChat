//
//  DWDIntelligenceMenuDatabaseTool.h
//  EduChat
//
//  Created by Beelin on 16/12/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDIntelligenceMenuModel.h"

@interface DWDIntelligenceMenuDatabaseTool : NSObject
+(instancetype)sharedIntelligenceDataBase;

/** 重置表 */
- (void)reCreateTables;

#pragma mark - Insert
- (BOOL)insertIntelligenceMenuDatabaseWithArrayModel:(NSArray <DWDIntelligenceMenuModel*>*)arrayModel;

#pragma mark - Query
/** 查询班级管理菜单 */
- (NSArray *)queryClassManegerMenuWithClassId:(NSNumber *)classId;

/** 查询班级管理菜单 当无班级情况查询 schoolId -2010000000000*/
- (NSArray *)queryClassManegerMenuWithSchoolId:(NSNumber *)schoolId;

/** 查询移动办公菜单 */
- (NSArray *)queryOfficeMenuWittSchoolId:(NSNumber *)schoolId;


#pragma mark - Delete
/**
 删除班级菜单
 */
- (void)deleteClassMenuWithClassId:(NSNumber *)classId success:(void(^)())success;
@end
