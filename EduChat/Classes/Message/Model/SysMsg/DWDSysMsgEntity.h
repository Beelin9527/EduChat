//
//  DWDSysMsgEntity.h
//  EduChat
//
//  Created by Superman on 16/2/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDSysMsgEntity : NSObject
@property (nonatomic , strong) NSNumber *memberId;  // 被触发者操作的人id
@property (nonatomic , strong) NSNumber *custId;  // 触发系统消息的人的id

@property (nonatomic , strong) NSNumber *classId;
@property (nonatomic , strong) NSNumber *groupId;    //群组Id
@property (nonatomic , copy) NSString *nickname;  // 触发系统消息的人的nickname
@property (nonatomic , copy) NSNumber *createTime;  // 触发系统消息的时间
@property (strong, nonatomic) NSArray *members;   //被操作者的nickname、custId

@property (nonatomic, strong) NSNumber *verifyId;  //班级成员加入ID
@property (nonatomic, copy) NSString *verifyNickname; //班级成员加入昵称

@property (nonatomic , copy) NSString *gradeName;  // 班级名称
@property (nonatomic , copy) NSString *schoolName;  // 学校名称

@property (nonatomic , copy) NSString *groupName;   // 群组名称
@property (nonatomic , copy) NSString *custNickname;   // 群修改头像、名称 操作者

@property (nonatomic , copy) NSString *photoKey;  // 班级 / 群组 / 个人 的photokey
@property (nonatomic , copy) NSString *introduce; // 班级 / 群组 介绍

@property (nonatomic , copy) NSString *platform;    // 平台
@property (nonatomic , strong) NSNumber *loginTime; // 登陆时间

/**  撤回消息   **/
@property (nonatomic , copy) NSString *msgId;
@property (nonatomic , strong) NSNumber *type;
@property (nonatomic , assign) DWDChatType chatType;
@property (nonatomic , strong) NSNumber *tid;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , assign) BOOL isRead;

// 还有个createTime

// 删除好友是否需要临时聊天横幅
@property (nonatomic, assign) BOOL smartUserRef;


@end
