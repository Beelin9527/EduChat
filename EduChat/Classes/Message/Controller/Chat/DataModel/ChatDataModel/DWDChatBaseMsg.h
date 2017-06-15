//
//  DWDChatBaseMsg.h
//  EduChat
//
//  Created by Superman on 16/11/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, DWDChatMsgState) {
    DWDChatMsgStateSending,  //  发送中
    DWDChatMsgStateSended,  //  已经发送
    DWDChatMsgStateError      //  发送出错
};

UIKIT_EXTERN NSString *const kDWDMsgTypeText;
UIKIT_EXTERN NSString *const kDWDMsgTypeImage;
UIKIT_EXTERN NSString *const kDWDMsgTypeAudio;
UIKIT_EXTERN NSString *const kDWDMsgTypeTime;
UIKIT_EXTERN NSString *const kDWDMsgTypeNote;
UIKIT_EXTERN NSString *const kDWDMsgTypeVideo;

UIKIT_EXTERN NSString *const KDWDMsgObservableStateKey;

@interface DWDChatBaseMsg : NSObject


@property (nonatomic) BOOL isGroupChat;
@property (nonatomic) BOOL isMutlSelected;
@property (nonatomic) DWDChatMsgState state;

@property (nonatomic , assign) DWDChatType chatType;

@property (copy, nonatomic) NSString *msgId;

@property (nonatomic , strong) DWDPhotoMetaModel *photohead;

@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *remarkName;

@property (strong, nonatomic) NSNumber *toUser;
@property (strong, nonatomic) NSNumber *fromUser;

@property (strong, nonatomic) NSNumber *createTime;
@property (strong, nonatomic) NSNumber *receivedTime;

@property (nonatomic , strong) NSNumber *badgeCount;

@property (nonatomic , strong) NSNumber *unreadMsgCount;

@property (copy, nonatomic) NSString *msgType;
@property (nonatomic , assign , getter=isObserving) BOOL observing;
@property (nonatomic , assign) BOOL errorToSending;



- (NSString *)getJSONString;

+ (NSArray *)modelPropertyWhitelist;
@end
