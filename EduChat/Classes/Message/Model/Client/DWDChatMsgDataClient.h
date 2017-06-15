//
//  DWDChatMsgMaker.h
//  EduChat
//
//  Created by apple on 1/5/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDBaseChatMsg.h"
#import "DWDTextChatMsg.h"
#import "DWDAudioChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDVideoChatMsg.h"
#import "DWDJPSHEnterBackgroundModel.h"
#import "DWDMsgReceiptToServer.h"

#import "DWDSingleton.h"

typedef NS_ENUM(NSUInteger, DWDMsgType) {
    
    DWDMsgTypePlainTextO2OUpload,
    DWDMsgTypePlainTextO2ODownload,
    
    DWDMsgTypePlainTextO2MUpload,
    DWDMsgTypePlainTextO2MDownload,
    
    DWDMsgTypeMediaO2OUpload,
    DWDMsgTypeMediaO2ODownload,
    
    DWDMsgTypeMediaO2MUpload,
    DWDMsgTypeMediaO2MDownload,
    
    DWDMsgTypeClientLogin,
    DWDMsgTypeClientLoginout,
    
    DWDMsgTypeVirginUpload,
    DWDMsgTypeVirginDownload,   // 第一次的上行下行
    
    DWDMsgTypeSysMsg,   // 系统消息
    
    DWDMsgTypeRevoke,
    
    DWDMsgTypeUnknow,
    
    DWDMsgTypeJPUSHEnterBackground,
    
    DWDMsgTypeTextO2OReceiptToServer,
    DWDMsgTypeTextO2MReceiptToServer,
    DWDMsgTypeFileO2OReceiptToServer,
    DWDMsgTypeFileO2MReceiptToServer,
    
    DWDMsgTypeSysMsgReceiptToServer,
    
    DWDReceiptServerToApp,
    DWDReceiveHeart,
    DWDReceiveHeartReplyReceived,
};

#define DWDReceiveNewChatMsgNotification @"receive_new_chat_msg_notification"
#define DWDReceiveLoginReceiptNotification @"receive_login_receipt_notification"
#define DWDReceiveLogoutReceiptNotification @"receive_logout_receipt_notification"
#define DWDReceiveOfflineChatMsgNotification @"receive_offline_chat_msg_notification"
#define DWDReceiveSysMsgNotification @"receive_sys_msg_notification"
#define DWDReceivePickUpCenterNotification @"receive_pickupCenter_notification"
#define DWDShouldReloadRecentChatData @"save_message_success_notification"
#define DWDReceiveNewChatMsgReceiptNotification @"receive_new_chat_msg_receipt_notification"
#define DWDReceiveIntelligentMsgNotification @"receive_intelligent_notification"

#define DWDReceiveNewChatMsgKey @"receive_new_msg_key"

@interface DWDChatMsgDataClient : NSObject

@property (nonatomic , strong) NSMutableDictionary *sendingMsgCachDict;
@property (nonatomic , strong) NSMutableArray *receiveMessageCach;
@property (nonatomic , strong) NSMutableArray *receiveSysMsgCach;
@property (nonatomic , strong) NSMutableArray *receivePickUpCenterCach;



@property (nonatomic , strong) DWDBaseChatMsg *relayingMsg;

+ (instancetype)sharedChatMsgDataClient;

// 1对1  1对多  文本
- (NSData *)makePlainTextForO2O:(DWDTextChatMsg *)msgObj;

- (NSData *)makePlainTextForO2M:(DWDTextChatMsg *)msgObj;

// 1对1  1对多  音频
- (NSData *)makeAudioForO2O:(DWDAudioChatMsg *)msgObj;

- (NSData *)makeAudioForO2M:(DWDAudioChatMsg *)msgObj;

// 1对1  1对多  图片
- (NSData *)makeImageForO2O:(DWDImageChatMsg *)msgObj;

- (NSData *)makeImageForO2M:(DWDImageChatMsg *)msgObj;

// 1对1  1对多  视频 --fzg
- (NSData *)makeVideoForO2O:(DWDVideoChatMsg *)msgObj;

- (NSData *)makeVideoForO2M:(DWDVideoChatMsg *)msgObj;

//Xcom 登录
- (NSData *)makeMsgClientLoginData:(NSString *)userName pwd:(NSString *)pwd;

//Xcom 退出
- (NSData *)makeMsgClientLogoutData:(NSNumber *)custId;

- (void)parseChatMsgFromDataAndPostSomeNotification:(NSData *)data;

// 系统消息 Command:0x9100(上行，移动端发出) 0x9101(下行，服务端发出)
- (DWDMsgType)parseChatMsgDataType:(unsigned char []) typeBytes;

- (NSData *)makeOfflineFetchData;

// JPUSH 进入后台
- (NSData *)makeJPSHUObject:(DWDJPSHEnterBackgroundModel *)msgObj;

// 给后台回执  o2o 文本
- (NSData *)makeO2OTextReceiptToServer:(DWDMsgReceiptToServer *)msgObj;
// 给后台回执  o2M 文本
- (NSData *)makeO2MTextReceiptToServer:(DWDMsgReceiptToServer *)msgObj;
// 给后台回执  o2o 文件
- (NSData *)makeO2OFileReceiptToServer:(DWDMsgReceiptToServer *)msgObj;
// 给后台回执  o2m 文件
- (NSData *)makeO2MFileReceiptToServer:(DWDMsgReceiptToServer *)msgObj;
// 给后台回执  系统消息
- (NSData *)makeSysMsgReceiptToServer:(NSDictionary *)msgObj;

// 给后台 心跳回执
- (NSData *)makeHeartReceiptToServer:(NSDictionary *)msgObj;

- (Byte)getCheckMark:(unsigned char[])bytes len:(long)len;

@end
