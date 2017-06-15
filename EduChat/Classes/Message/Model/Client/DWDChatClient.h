//
//  DWDChatClient.h
//  EduChat
//
//  Created by apple on 1/5/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"
#import <GCDAsyncSocket.h>
@interface DWDChatClient : NSObject
DWDSingletonH(DWDChatClient)

@property (strong, nonatomic) GCDAsyncSocket *socket;



//- (void)sendMsg:(NSString *)msg;

- (void)sendData:(NSData *)data;

//链接
- (void)getConnect;
//断开
- (void)disConnect;

//** 移除计时器 */
- (void)removerTimer;

/** 重新链接socket */
- (void)reconnection;

- (BOOL)isConnecting;

@end
