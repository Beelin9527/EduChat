//
//  DWDShcoolDataBaseTool.h
//  EduChat
//
//  Created by Beelin on 16/12/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDSchoolModel.h"
@interface DWDSchoolDataBaseTool : NSObject
+(instancetype)sharedSchoolDataBase;

/** 重置表 */
- (void)reCreateTables;

#pragma mark - Insert
- (BOOL)insertSchoolTalbeWithArrayModel:(NSArray <DWDSchoolModel*>*)arrayModel;

#pragma mark - Query
- (NSArray *)querySchoolAndClass;

#pragma mark - Delete
/**
 删除班级
 */
- (void)deleteClassWithClassId:(NSNumber *)classId success:(void(^)())success;
@end
