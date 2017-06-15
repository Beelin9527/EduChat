//
//  DWDChatMsgReceipt.m
//  EduChat
//
//  Created by apple on 1/8/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDChatMsgReceipt.h"

@implementation DWDChatMsgReceipt

- (NSString *)description {
    return [NSString stringWithFormat:@"{msgId:%@, status:%@}", self.msgId, self.status];
}

@end
