//
//  DWDChatAudioCell.h
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDInteractiveChatCell.h"
@class DWDAudioChatMsg;
@interface DWDChatAudioCell : DWDInteractiveChatCell

@property (nonatomic) NSInteger audioDuration;
@property (strong, nonatomic) UILabel *desLabel;
@property (nonatomic , strong) UIImageView *animateImageView;
@property (nonatomic , strong) UIImageView *redCircleView;
@property (strong, nonatomic) UIImageView *backgroundImageView;

@property (nonatomic , strong) DWDAudioChatMsg *audioMsg;


@end
