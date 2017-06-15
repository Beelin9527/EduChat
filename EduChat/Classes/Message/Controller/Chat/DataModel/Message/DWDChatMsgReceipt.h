//
//  DWDChatMsgReceipt.h
//  EduChat
//
//  Created by apple on 1/8/16.
//  Copyright © 2016 dwd. All rights reserved.
//  回执

#import <Foundation/Foundation.h>

@interface DWDChatMsgReceipt : NSObject

@property (copy, nonatomic) NSString *msgId;
@property (strong, nonatomic) NSNumber *status; //  1成功  0失败  2已经注册  3登录异常 4已经登录
@property (nonatomic , strong) NSNumber *toUser;
@property (nonatomic , assign) DWDChatType chatType;
@property (nonatomic , strong) NSNumber *createTime;

@end
