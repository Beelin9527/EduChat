//
//  DWDChatMsgClient.h
//  EduChat
//
//  Created by apple on 11/18/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDBaseChatMsg.h"
#import "DWDTextChatMsg.h"
#import "DWDAudioChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDVideoChatMsg.h"

@interface DWDChatMsgClient : NSObject

- (NSArray *) loadMoreChatMsg;

//- (NSMutableArray *)loadLastedChatMsg;

/*
 * create a text message, save it in sqlite & send it to server
 * text: message content
 * from: id of sender
 * to: id of recevier
 * observe: a observe for state key, use it to update UI
 */


- (DWDTextChatMsg *)sendTextMsg:(NSString *)text from:(NSNumber *)from to:(NSNumber *)to observe:(id)observe mutableChat:(BOOL)isMutableChat chatType:(DWDChatType )chatType;

- (DWDTextChatMsg *)createTextMsgWithText:(NSString *)text from:(NSNumber *)from to:(NSNumber *)to chatType:(DWDChatType )chatType;

- (DWDAudioChatMsg *)creatAudioMsgFrom:(NSNumber *)from to:(NSNumber *)to duration:(NSNumber *)duration observe:(id)observe mp3FileName:(NSString *)mp3fileName chatType:(DWDChatType )chatType;

- (DWDImageChatMsg *)creatImageMsgFrom:(NSNumber *)from to:(NSNumber *)to observe:(id)observer chatType:(DWDChatType )chatType;

- (DWDVideoChatMsg *)creatVideoMsgFrom:(NSNumber *)from to:(NSNumber *)to observe:(id)observe mp4FileName:(NSString *)mp4fileName chatType:(DWDChatType )chatType;

- (void)sendAudioMsg:(DWDAudioChatMsg *)audioMsg mutableChat:(BOOL)isMutableChat;

- (void)sendImageMsg:(DWDImageChatMsg *)imageMsg image:(UIImage *)image progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock mutableChat:(BOOL)isMutableChat;

//- (DWDBaseChatMsg *)sendImgMsg:(UIImage *)image from:(NSString *)from to:(NSString *)to observe:(id)observe;

@end
