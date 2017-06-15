//
//  FMDatabase+dwd_sql.h
//  EduChat
//
//  Created by KKK on 16/8/23.
//  Copyright © 2016年 dwd. All rights reserved.
//


/***********************************
 
 没用到
 
 ***********************************/

 /*
  
  不管是增删改,最终都是要通过一定的方法,不暴露内部逻辑
  
  进行一步
  <收到socket消息>→<把消息传过来>→<存入数据库>
  的操作
  
  **/


#import <FMDB/FMDB.h>

@class DWDPickUpCenterListDataBaseModel;
@class FMResultSet;
@class DWDPickUpCenterDataBaseModel;

@interface FMDatabase (dwd_sql)

#pragma mark - 接送中心

/**
 *  离线消息根据通道分发后,在数据库事务中对接送中心数据进行存储
 *
 *  @param data 离线接送中心消息
 */
- (void)puc_saveOfflineSocketData:(NSData *)data;

/**************教师**************/
/***班级列表增改查***/
//班级列表_创建
- (BOOL)puc_teacher_list_createTableIfNotExists;
//班级列表_插入
- (BOOL)puc_teacher_list_insertTableValue:(DWDPickUpCenterListDataBaseModel *)model;
/*
 班级列表_更新
 班级列表只需要更新badgeNumber
 **/
- (BOOL)puc_teacher_list_updateBadgeNumberWithClassId:(NSNumber *)classId
                                          badgeNumber:(long)badgeNumber;
//班级列表_查询
- (FMResultSet *)puc_teacher_list_selectTableWithClassId:(NSNumber *)classId;

/***班级成员增改查***/
//班级成员_创建
- (BOOL)puc_teacher_class_createTableIfNotExists:(NSString *)tableName;
//班级成员_插入
- (BOOL)puc_teacher_class_insertTableValue:(DWDPickUpCenterDataBaseModel *)model
                                 tableName:(NSString *)tableName;
//班级成员_查询
- (FMResultSet *)puc_teacher_selectClassTableWithModel:(DWDPickUpCenterDataBaseModel *)model
                                             tableName:(NSString *)tableName;


/**************家长**************/
/***班级列表增改查***/
//班级列表_创建
- (BOOL)puc_child_list_createTableIfNotExists;
//班级列表_插入
- (BOOL)puc_child_list_insertTableValue:(DWDPickUpCenterListDataBaseModel *)model;
//班级列表_更新
- (BOOL)puc_child_list_updateBadgeNumberWithClassId:(NSNumber *)classId
                                        badgeNumber:(long)badgeNumber;
//班级列表_查询
- (FMResultSet *)puc_child_list_selectTableWithClassId:(NSNumber *)classId;

/***班级成员增改查***/
//班级成员_创建
- (BOOL)puc_child_class_createTableIfNotExists:(NSString *)tableName;
//班级成员_插入
- (BOOL)puc_child_class_insertTabeleValue:(DWDPickUpCenterDataBaseModel *)model
                               tableName:(NSString *)tableName;
@end
