//
//  DWDChatDataHandler.h
//  EduChat
//
//  Created by Superman on 16/6/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDBaseChatMsg.h"

@class DWDNoteChatMsg;
@interface DWDChatDataHandler : NSObject

+ (instancetype)loadHistoryMsgWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType fetchCount:(NSUInteger)count success:(void (^)(NSMutableArray *handleDatas))success;

+ (instancetype)handlerHistoryMessageWithtoUser:(NSNumber *)toUser chatType:(DWDChatType)chatType success:(void (^)(NSArray *handleDatas))successGET;

+ (instancetype)handlerUnreadMessageWithTouser:(NSNumber *)toUser chatType:(DWDChatType)chatType tableView:(UITableView *)tableView chatDatas:(NSMutableArray *)chatData success:(void (^)(NSMutableArray *handleDatas))successGET;

+ (instancetype)handlerUnreadMessageForEnterAppWithMsg:(DWDBaseChatMsg *)base success:(void (^)(NSArray *handleDatas))successGET;

+ (instancetype)revokeMsgWithMsg:(DWDBaseChatMsg *)msg touser:(NSNumber *)toUser chatType:(DWDChatType)chatType success:(void (^)(NSString *note))success failure:(void (^)(NSError *error))failure;

// new
+ (instancetype)fetchUnreadMsgFromServerWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType msgId:(NSString *)msgId fetchCount:(NSInteger)count success:(void (^)(NSMutableArray *handleDatas))success;

@end
