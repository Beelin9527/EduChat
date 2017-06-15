//
//  DWDAudioChatMsg.h
//  EduChat
//
//  Created by apple on 1/12/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDFileChatMsg.h"

@interface DWDAudioChatMsg : DWDFileChatMsg
@property (strong, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSNumber *fileSize;
@property (nonatomic , assign , getter = isRecording ) BOOL recording;

@property (nonatomic , assign , getter=isRead) BOOL read;
@property (nonatomic , assign , getter=isPlaying) BOOL playing;
@end
