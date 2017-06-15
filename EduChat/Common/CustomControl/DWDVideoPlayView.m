//
//  DWDVideoPlayView.m
//  EduChat
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 dwd. All rights reserved.
//  视频播放器

#import "DWDVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>


@interface DWDVideoPlayView ()

{
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    BOOL *_isPlaying;
}

@end

@implementation DWDVideoPlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];

    }
    return self;
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    _videoUrl = videoUrl;
    _playerItem = nil;
    [_player pause];
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    
    _playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    if (_forbidVolume) {
        _player.volume = 0.0;
    }
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_playerLayer];
//    [_player play];
}

- (void)playbackFinished:(NSNotification *)notification
{
    if (notification.object == _playerItem) {
        [_player seekToTime:kCMTimeZero];
        [_player play];
    }
}

- (void)play
{
    [_player play];
}

- (void)stop
{
    _playerItem = nil;
    [_player pause];
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
}

- (void)pause
{
    [_player pause];
    [_player seekToTime:kCMTimeZero];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if (self.handleTapBlock) {
        self.handleTapBlock();
    }
}

- (void)setHandleTapBlock:(void (^)(void))handleTapBlock
{
    _handleTapBlock = handleTapBlock;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

@end
