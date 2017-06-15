//
//  DWDSpeakImageView.h
//  EduChat
//
//  Created by Superman on 16/6/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDAudioChatMsg.h"
#import "DWDChatController.h"
#import "DWDAudioClient.h"
@protocol DWDSpeakImageViewDelegate <NSObject>

@required
- (void)speakImageViewStartRecordAudio;
- (void)speakImageViewLongpressActionWithMsg:(NSArray *)msgs;
- (void)cancelRecordAndDeleteDatasActionsWithMsg:(DWDAudioChatMsg *)audioMsg;
- (void)uploadAudioMsgFailedWithMsg:(DWDAudioChatMsg *)audioMsg;
@end

@interface DWDSpeakImageView : UIView
@property (nonatomic , strong) UILabel *label;
@property (nonatomic , strong) UIImageView *imageView;

@property (nonatomic , weak) id<DWDSpeakImageViewDelegate> delegate;
@property (nonatomic , assign) NSNumber *toUser;
@property (nonatomic , assign) DWDChatType chatType;

@property (nonatomic , weak) DWDChatController *chatVc;

@property (nonatomic , strong) DWDAudioClient *audioClient;

- (void)uploadAndSendAudioMsg:(DWDAudioChatMsg *)audioMsg mutableChat:(BOOL )isMutableChat;  // 发错错误时 控制器也要使用

@end
