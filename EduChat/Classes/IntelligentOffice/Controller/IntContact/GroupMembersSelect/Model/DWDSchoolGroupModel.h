//
//  DWDSchoolGroupModel.h
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 群组成员的model
@interface DWDSchoolGroupMemberModel : NSObject <NSCopying>

/****
 网络请求中的字段
 ****/
@property (nonatomic, strong) NSNumber *custId; //成员的custId
@property (nonatomic, copy) NSString *memberName; //成员的姓名
@property (nonatomic, copy) NSString *telPhone; //成员的电话
@property (nonatomic, copy) NSString *photoKey; //成员的头像
@property (nonatomic, assign) BOOL isFriend; //成员是否是好友
@property (nonatomic, copy) NSString *characterName;//角色名称(其实是身份

/****
 custom control property
 with black list
 ****/
/********************* extension *********************/
// 用于显示是否打钩(被选中)
@property (nonatomic, assign) BOOL checked;

@end

#pragma mark - 群组的model
@interface DWDSchoolGroupModel : NSObject <NSCopying>

/****
 网络请求中的字段
 ****/
@property (nonatomic, strong) NSNumber *schoolID; //学校ID
@property (nonatomic, copy) NSString *schoolName; //学校名字
@property (nonatomic, strong) NSNumber *groupID; //群组ID
@property (nonatomic, copy) NSString *groupName; //群组名字
@property (nonatomic, strong) NSNumber *serialNumber; //群组序列号, 用于排序(?
@property (nonatomic, strong) NSArray<DWDSchoolGroupMemberModel *> *groupMembers; //成员数组

/****
 custom control property
 with black list
 ****/
/********************* extension *********************/
// 用于显示是否打钩(被选中)
@property (nonatomic, assign) BOOL checked;
// 用于显示是否是扩展状态
@property (nonatomic, assign) BOOL expanded;

@end


