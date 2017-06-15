//
//  DWDOfflineMsg.h
//  EduChat
//
//  Created by Superman on 16/1/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDFriendAcctMsg.h"
#import "DWDBaseChatMsg.h"
@interface DWDOfflineMsg : NSObject
@property (nonatomic , strong) DWDFriendAcctMsg *friendAcctMsg;
@property (nonatomic , strong) DWDBaseChatMsg *lastMsg;

@end
