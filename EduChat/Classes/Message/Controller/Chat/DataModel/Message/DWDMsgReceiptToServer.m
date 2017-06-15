//
//  DWDMsgReceiptToServer.m
//  EduChat
//
//  Created by Superman on 16/7/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMsgReceiptToServer.h"

@implementation DWDMsgReceiptToServer

- (instancetype)initWithMsgId:(NSString *)msgId toUser:(NSNumber *)toUser{
    if (self = [super init]) {
        _msgId = msgId;
        _toUser = toUser;
    }
    return self;
}

@end
