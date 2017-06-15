//
//  DWDFriendAcctMsg.h
//  EduChat
//
//  Created by Superman on 16/1/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface DWDFriendAcctMsg : NSObject
@property (nonatomic , strong) NSNumber *msgNum;  // 消息数目
@property (nonatomic , strong) NSNumber *custId;  // 单聊: 就是fromId 群聊 就是 toid

/** * 用户角色类型<br>
 * 4-教师<br>
 * 5-家长<br>
 * 6-学生<br>
 * 7-班级<br>
 * 8-群组 */

@end
