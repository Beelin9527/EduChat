//
//  DWDZGVideoPlayView.m
//  EduChat
// 123
//  Created by apple on 16/5/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDZGVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import "DWDVideoPlayView.h"

@interface DWDZGVideoPlayView()

@property (nonatomic, assign) CGRect                  startRect;        // 坐标
@property (nonatomic, strong) UIImageView             *coverImgV;       // 封面
@property (nonatomic, strong) UIImageView             *tempImgV;        // 动画
@property (nonatomic, strong) UIImageView             *videoIcon;       // 播放图标
@property (nonatomic, strong) DWDVideoPlayView        *playView;        // 播放视图
@property (nonatomic,   weak) DWDVideoPlayView        *fullPlayView;    // 全频播放
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation DWDZGVideoPlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setSubviews];
        
    }
    return self;
}

- (void)setSubviews
{
    // 封面
    _coverImgV = [[UIImageView alloc] initWithFrame:self.bounds];
    _coverImgV.contentMode = UIViewContentModeScaleAspectFill;
    _coverImgV.layer.masksToBounds = YES;
    _coverImgV.userInteractionEnabled = YES;
    [self addSubview:_coverImgV];
    
    // 播放图标
    _videoIcon = [[UIImageView alloc] init];
    _videoIcon.frame = CGRectMake((self.w - 35) * 0.5, (self.h - 35) * 0.5, 35, 35);
    _videoIcon.image = [UIImage imageNamed:@"msg_vedio_paly_ic"];
    _videoIcon.alpha = 0.8;
    [_coverImgV addSubview:_videoIcon];
    
    // 播放视图
    _playView = [[DWDVideoPlayView alloc] initWithFrame:self.bounds];
    _playView.userInteractionEnabled = NO;
    _playView.forbidVolume = YES;
    [self addSubview:_playView];
    
    // 加载指示
    _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.w/2-15, self.h/2-15, 30, 30)];
    _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _activityView.hidesWhenStopped = YES;
    [self addSubview:_activityView];
    
    // 封面手势
    UITapGestureRecognizer *onTapCover = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCoverTap:)];
    [_coverImgV addGestureRecognizer:onTapCover];
    
    // 点击视频
    UITapGestureRecognizer *tapVideoView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlayViewTap:)];
    [_playView addGestureRecognizer:tapVideoView];
}

#pragma mark - 手势

// 封面 -- 开始播放
- (void)handleCoverTap:(UITapGestureRecognizer *)tap
{
    _videoIcon.hidden = YES;
    [_activityView startAnimating];
    NSString *filePath = [self filePathWithName:_videoNameStr];
    
    if (filePath) {
        
        [_activityView stopAnimating];
        _playView.videoUrl = [NSURL fileURLWithPath:filePath];
        [_playView play];
        _playView.userInteractionEnabled = YES;
    }else {
        
        [[DWDAliyunManager sharedAliyunManager] downloadMp4ObjectAsyncWithObjecName:_videoNameStr compltionBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_activityView stopAnimating];
                NSString * mp4FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder/recive"] stringByAppendingPathComponent:_videoNameStr];
                
                _playView.videoUrl = [NSURL fileURLWithPath:mp4FilePath];
                [_playView play];
                _playView.userInteractionEnabled = YES;
            });
        }];
    }
}

// 视频 -- 全频播放
- (void)handlePlayViewTap:(UITapGestureRecognizer *)tap
{
    [_playView pause];
    _startRect = [self convertRect:self.coverImgV.frame toView:[UIApplication sharedApplication].keyWindow];
    
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor clearColor];
    backView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    UITapGestureRecognizer *tapBackView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackViewTap:)];
    [backView addGestureRecognizer:tapBackView];
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    
    UIImageView *tempImgV = [[UIImageView alloc] init];
    tempImgV.frame = _startRect;
    tempImgV.contentMode = UIViewContentModeScaleAspectFill;
    tempImgV.layer.masksToBounds = YES;
    tempImgV.image = self.coverImgV.image;
    [backView addSubview:tempImgV];
    _tempImgV = tempImgV;
    
    DWDVideoPlayView *fullPlayView = [[DWDVideoPlayView alloc] init];
    fullPlayView.bounds = CGRectMake(0, 0, DWDScreenW, 300);
    fullPlayView.center = backView.center;
    [backView addSubview:fullPlayView];
    _fullPlayView = fullPlayView;

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        backView.backgroundColor = [UIColor blackColor];
        tempImgV.frame = CGRectMake(0, (DWDScreenH - DWDScreenW * 0.8) * 0.5, DWDScreenW, DWDScreenW * 0.8);
    } completion:^(BOOL finished) {
        
        _fullPlayView.videoUrl = _playView.videoUrl;
        [_fullPlayView play];
    }];
}

// 预览 -- 取消预览
- (void)handleBackViewTap:(UITapGestureRecognizer *)tap
{
    [_fullPlayView stop];
    _fullPlayView = nil;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        tap.view.backgroundColor = [UIColor clearColor];
        _tempImgV.frame = _startRect;
    } completion:^(BOOL finished) {
        
        [tap.view removeFromSuperview];
        [_playView play];
    }];
}

#pragma mark - 设置播放的视频

- (void)setVideoNameStr:(NSString *)videoNameStr
{
    _videoNameStr = videoNameStr;
    
    // 设置封面
    NSString *fileName = [_videoNameStr stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"];
    NSString *filePath = [self filePathWithName:fileName];
    if (filePath) {
        _coverImgV.image = [UIImage imageWithContentsOfFile:filePath];
    }else {
        [_coverImgV sd_setImageWithURL:[NSURL URLWithString:[[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:[videoNameStr stringByReplacingOccurrencesOfString:@"mp4" withString:@".png"]]] placeholderImage:nil];
    }
}

- (AVPlayerItem *)getPlayItemWithURLString:(NSString *)urlString
{
    if ([urlString containsString:@"http"]) {
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        return playerItem;
    }else{
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:urlString] options:nil];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        return playerItem;
    }
}

- (AVPlayerItem *)getPlayerItemWithFileName:(NSString *)fileNameString
{
    NSString *filePath = [self filePathWithName:fileNameString];
    __block AVPlayerItem *playerItem;
    
    if (filePath) {
        
        AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
        playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    }else {
        
        [[DWDAliyunManager sharedAliyunManager] downloadMp4ObjectAsyncWithObjecName:fileNameString compltionBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AVAsset *movieAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
                playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
            });
        }];
    }
    return playerItem;
}

- (NSString *)filePathWithName:(NSString *)name
{
    NSString *filePathStr = nil;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *paths = @[@"/Documents/videoFolder",@"/Documents/videoFolder/recive"];
    for (NSString *path in paths) {
        
        NSString *filePath = [[NSHomeDirectory() stringByAppendingString:path] stringByAppendingPathComponent:name];
        if ([file_manager fileExistsAtPath:filePath]) {
            filePathStr = filePath;
            break;
        }
    }
    return filePathStr;
}

@end

