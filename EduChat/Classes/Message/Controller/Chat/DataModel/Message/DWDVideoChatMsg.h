//
//  DWDVideoChatMsg.h
//  EduChat
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDFileChatMsg.h"

#define DWDChatVideoWidth DWDScreenW - 120.0
#define DWDChatVideoHeight (DWDChatVideoWidth) * 3/4

typedef NS_ENUM(NSInteger, DWDChatMsgFromType) {
    DWDChatMsgFromTypeSelf,
    DWDChatMsgFromTypeOther
};

@interface DWDVideoChatMsg : DWDFileChatMsg

@property (nonatomic, assign, getter = isRecording ) BOOL recording;
@property (nonatomic, copy) NSString *thumbFileKey;
@property (nonatomic, assign) DWDChatMsgFromType fromType;

@property (nonatomic, assign) CGRect backgroundViewFrame;


@end
