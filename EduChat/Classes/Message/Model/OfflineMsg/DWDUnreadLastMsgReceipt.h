//
//  DWDUnreadLastMsgReceipt.h
//  EduChat
//
//  Created by Superman on 16/5/17.
//  Copyright © 2016年 dwd. All rights reserved.
//  最后一条未读的msg收到后的回执   (发给服务端)

#import <Foundation/Foundation.h>

@interface DWDUnreadLastMsgReceipt : NSObject
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , strong) NSNumber *friendCustId;
@property (nonatomic , assign) DWDChatType chatType;
@property (nonatomic , copy) NSString *msgId;

@end
