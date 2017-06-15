//
//  DWDBaseChatMsg.m
//  EduChat
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <YYModel/YYModel.h>

#import "DWDBaseChatMsg.h"
#import "DWDMessageDatabaseTool.h"

NSString *const kDWDMsgTypeText = @"text";
NSString *const kDWDMsgTypeImage = @"image";
NSString *const kDWDMsgTypeAudio = @"voice";
NSString *const kDWDMsgTypeTime = @"time";;
NSString *const kDWDMsgTypeNote = @"note";
NSString *const kDWDMsgTypeVideo = @"video";

NSString *const KDWDMsgObservableStateKey = @"state";  // 每个消息对应一种状态 

@interface DWDBaseChatMsg () <NSCopying>

@end

@implementation DWDBaseChatMsg

- (id)copyWithZone:(NSZone *)zone{
    
    DWDBaseChatMsg *base = [[[self class] allocWithZone:zone] init];
    base.isGroupChat = self.isGroupChat;
    base.isMutlSelected = self.isMutlSelected;
    base.state = self.state;
    base.chatType = self.chatType;
    base.msgId = self.msgId;
    base.photohead = self.photohead;
    base.nickname = self.nickname;
    base.remarkName = self.remarkName;
    base.toUser = self.toUser;
    base.fromUser = self.fromUser;
    base.createTime = self.createTime;
    base.receivedTime = self.receivedTime;
    base.badgeCount = self.badgeCount;
    base.unreadMsgCount = self.unreadMsgCount;
    base.msgType = self.msgType;
    base.observing = self.observing;
    base.errorToSending = self.errorToSending;
    return base;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.msgId = [NSUUID UUID].UUIDString;
    }
    
    return self;
}

- (NSString *)description {
    [super description];
    
    return [NSString stringWithFormat:@"msgId:%@, toUser:%@, fromUser:%@, cteateTime:%@, msgType:%@, state:%zd , photohead:%@ , nickname:%@ , chatType:%zd", self.msgId,self.toUser, self.fromUser, self.createTime, self.msgType , self.state , self.photohead , self.nickname , self.chatType ];
    
}

- (NSString *)getJSONString {
    return [self yy_modelToJSONString];
}

+ (NSArray *)modelPropertyWhitelist {
    
    return @[@"msgId", @"toUser", @"fromUser", @"createTime", @"msgType" , @"photohead" , @"nickname" , @"chatType"];
}


@end
