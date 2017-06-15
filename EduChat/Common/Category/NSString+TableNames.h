//
//  NSString+TableNames.h
//  EduChat
//
//  Created by Superman on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TableNames)

/**
 *  根据传入cusid 创建个人对个人聊天 历史消息表名
 *
 *  @param cusid 跟我聊天的人的cusid
 *
 *  @return tb_c2c_cusid
 */
+ (NSString *)c2cTableNameStringWithCusid:(NSNumber *)cusid;

/**
 *  根据传入cusid 创建个人对多人聊天 历史消息表名
 *
 *  @param cusid 班级的id
 *
 *  @return tb_c2m_cusid
 */
+ (NSString *)c2mTableNameStringWithCusid:(NSNumber *)cusid;
@end
