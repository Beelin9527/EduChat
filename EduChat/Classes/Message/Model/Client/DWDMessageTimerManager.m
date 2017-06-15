//
//  DWDMessageTimerManager.m
//  EduChat
//
//  Created by Superman on 16/4/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMessageTimerManager.h"
#import "DWDMessageDatabaseTool.h"
@implementation DWDMessageTimerManager

DWDSingletonM(MessageTimerManager)

- (NSMutableDictionary *)timerCachDict{
    if (!_timerCachDict) {
        _timerCachDict = [NSMutableDictionary dictionary];
    }
    return _timerCachDict;
}

- (void)judgeSendingError:(NSTimer *)timer{
    
    NSDictionary *dict = timer.userInfo;
    
    DWDChatMsgState state = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchMessageSendingStateWithToId:dict[@"toId"] MsgId:dict[@"msgId"] chatType:[dict[@"chatType"] integerValue]];
    
    if (state != DWDChatMsgStateSending) {  // 表示发送成功了, 移除定时器缓存
        // 2.更改完数据库 , 移除定时器缓存
        [timer invalidate];
        [self.timerCachDict removeObjectForKey:dict[@"msgId"]];
        return;
    }
    
    // 40s 后 还是sending 那么就超时 , 改为error
    if (state == DWDChatMsgStateSending) {
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateMsgStateToState:DWDChatMsgStateError WithMsgId:dict[@"msgId"] toUserId:dict[@"toId"] chatType:[dict[@"chatType"] longValue] success:^{
            
            DWDLog(@"定时器到时 修改消息发送状态为 state : error");
            // 1.发通知 让chatVc 刷新UI
            [[NSNotificationCenter defaultCenter] postNotificationName:@"message_timeout_notification" object:nil userInfo:timer.userInfo];
            // 2.更改完数据库 , 移除定时器缓存
            [timer invalidate];
            [self.timerCachDict removeObjectForKey:dict[@"msgId"]];
            
        } failure:^(NSError *error) {
            
        }];
    }
}
@end
