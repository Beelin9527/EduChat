//
//  DWDFriendApplyDataBase.h
//  EduChat
//
//  Created by Gatlin on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//  好友申请 本地库

#import <Foundation/Foundation.h>

@interface DWDFriendApplyDataBaseTool : NSObject
+(instancetype)sharedFriendApplyDataBase;

#pragma mark - Insert
/** 插入表 */
- (void)insertToTableWithMyCustId:(NSNumber *)myCustId friendApplyArray:(NSArray *)friendApplyArray;

#pragma mark - Update
/** 更新状态 */
/**
 * 更新状态
 * @param status 0:未接受 1:已添加 2:拒绝
 */
- (void)updateWithStatus:(NSNumber *)status MyCustId:(NSNumber *)myCustId friendCustId:(NSNumber *)friendCustId;

#pragma mark - Delete
/**
 * 删除某一条数据
 * @param friendCustId
 */
- (void)deleteWithFriendCustId:(NSNumber *)friendCustId  MyCustId:(NSNumber *)myCustId;

#pragma mark - Get
/** 查询数据 获取本地好友申请列表 */
- (NSArray *)getAllFriendsApplyWithMyCustId:(NSNumber *)myCustId;

@end
