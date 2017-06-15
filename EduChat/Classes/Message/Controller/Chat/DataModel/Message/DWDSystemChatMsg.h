//
//  DWDSystemChatMsg.h
//  EduChat
//
//  Created by apple on 2/28/16.
//  Copyright © 2016 dwd. All rights reserved.
//

//
//@interface DWDBaseChatMsg : NSObject
//
//@property (nonatomic) BOOL isGroupChat;
//@property (nonatomic) BOOL isMutlSelected;
//@property (nonatomic) DWDChatMsgState state;
//
//@property (copy, nonatomic) NSString *msgId;
//
//@property (nonatomic , copy) NSString *photoKey;
//@property (nonatomic , copy) NSString *nickName;
//
//
//@property (strong, nonatomic) NSNumber *chatSessionId;
//@property (strong, nonatomic) NSNumber *toUser;
//@property (strong, nonatomic) NSNumber *fromUser;
//
//@property (strong, nonatomic) NSNumber *createTime;
//@property (strong, nonatomic) NSNumber *receivedTime;
//
//@property (copy, nonatomic) NSString *msgType;
//@property (nonatomic , assign , getter=isObserving) BOOL observing;



#import "DWDBaseChatMsg.h"

@interface DWDSystemChatMsg : DWDBaseChatMsg

@property (nonatomic, strong) NSNumber *custId;
//来自群组/班级的id
@property (nonatomic, strong) NSNumber *groupId;
//显示内容
@property (nonatomic, copy) NSString *content;


//验证信息
@property (nonatomic, copy) NSString *verifyInfo;
//验证状态
@property (nonatomic, assign) BOOL verifyState;

@end
