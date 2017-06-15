//
//  DWDMsgReceiptToServer.h
//  EduChat
//
//  Created by Superman on 16/7/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDMsgReceiptToServer : NSObject
@property (nonatomic , copy) NSString *msgId;
@property (nonatomic , strong) NSNumber *toUser;

- (instancetype)initWithMsgId:(NSString *)msgId toUser:(NSNumber *)toUser;
@end
