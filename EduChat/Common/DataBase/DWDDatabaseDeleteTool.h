//
//  DWDDatabaseDeleteTool.h
//  EduChat
//
//  Created by KKK on 16/11/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDDatabaseDeleteTool : NSObject


/**
 删除数据库中 聊天消息表的所有时间所在行(
 */
+ (void)deleteChatRecordTimeRows;

@end
