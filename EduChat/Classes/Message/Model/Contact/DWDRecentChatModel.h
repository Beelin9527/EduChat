//
//  DWDRecentChatModel.h
//  EduChat
//
//  Created by Superman on 16/2/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
/*@"CREATE TABLE tb_recentchatlist (
 myCustId INTEGER,
 custId INTEGER, 
 lastContent TEXT, 
 photoKey TEXT,
 nickname TEXT,
 remarkName TEXT , isFriend INTEGER , 
 lastCreatTime TEXT , 
 type INTEGER , 
 chatType INTEGER, 
 albumId INTEGER , 
 memberCount INTEGER , 
 badgeCount INTEGER);"*/

@interface DWDRecentChatModel : NSObject

@property (nonatomic , strong) NSNumber *myCustId;
@property (nonatomic , strong) NSNumber *custId;     // 用户id
@property (nonatomic , strong) NSNumber *friendId;   // 好友id

@property (nonatomic , copy) NSString *lastContent;  // 最后一条消息的内容
@property (nonatomic , copy) NSString *photoKey;     // 单聊:别人的photokey  群聊:群组/班级的photokey
@property (nonatomic , copy) NSString *nickname;     // 个人nickname 群组/班级 的名字
@property (nonatomic , copy) NSString *remarkName;
@property (nonatomic , strong) NSNumber *isShowNick; //是否显示昵称

@property (nonatomic , assign) BOOL isFriend;

@property (nonatomic , strong) NSNumber *albumId;
@property (nonatomic , strong) NSNumber *memberCount;

@property (nonatomic , copy) NSNumber *lastCreatTime; // 最后更新的时间

@property (nonatomic , strong) NSNumber *badgeCount;
@property (nonatomic , copy) NSString *type;          // 系统消息类型  (表中是integer类型)

@property (nonatomic , assign) DWDChatType chatType;  // 聊天类型

@end
