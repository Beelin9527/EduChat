//
//  DWDRecentVideoCell.m
//  EduChat
//
//  Created by apple on 16/5/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRecentVideoCell.h"
#import "DWDVideoPlayView.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

NSString *const NOTI_EDITRECENTVIDEO = @"editRecentVideo";
NSString *const NOTI_CANCELEDITRECENTVIDEO = @"cancelEditRecentVideo";

@interface DWDRecentVideoCell ()


@property (nonatomic, weak) UIButton *deleteBtn;
@property (nonatomic, weak) UIView *backView;

@end

@implementation DWDRecentVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor greenColor];
        [self setSubviews];
        [self registNotification];
    }
    return self;
}

- (void)setSubviews
{
    UIView *backView = [[UIView alloc] init];
    backView.frame = CGRectMake(5.0, 5.0, (DWDScreenW - 40)/3.0, 80.0);
    backView.backgroundColor = DWDRGBColor(53, 54, 55);
    backView.layer.cornerRadius = 8.0;
    backView.layer.masksToBounds = YES;
    backView.hidden = YES;
    [self addSubview:backView];
    _backView = backView;
    
    UIImageView *addIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_small_video_add"]];
    addIcon.frame = CGRectMake((backView.w - 23) * 0.5, (backView.h - 23) * 0.5, 23, 23);
    [backView addSubview:addIcon];
    
    UIImageView *thumbImageV = [[UIImageView alloc] init];
    thumbImageV.frame = CGRectMake(5.0, 5.0, (DWDScreenW - 40)/3.0, 80.0);
    thumbImageV.contentMode = UIViewContentModeScaleAspectFill;
    thumbImageV.layer.cornerRadius = 8.0;
    thumbImageV.layer.masksToBounds = YES;
    [self addSubview:thumbImageV];
    _thumbImageV = thumbImageV;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(1.0, 1.0, 18.0, 18.0);
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"msg_small_video_delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    deleteBtn.hidden = YES;
    [self addSubview:deleteBtn];
    _deleteBtn = deleteBtn;
}

- (void)registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editState:) name:NOTI_EDITRECENTVIDEO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelEditState:) name:NOTI_CANCELEDITRECENTVIDEO object:nil];
}

- (void)editState:(NSNotification *)notification
{
    if (_isLastCell) {
        
        [self performSelector:@selector(transformToEditState) withObject:nil afterDelay:0.3];
    }else {
        
        [self transformToEditState];
    }
}

- (void)transformToEditState
{
    self.deleteBtn.hidden = NO;
    self.deleteBtn.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.2 animations:^{
        self.thumbImageV.transform = CGAffineTransformMakeScale(0.875, 0.875);
        self.deleteBtn.transform = CGAffineTransformIdentity;
    }];
}

- (void)cancelEditState:(NSNotification *)notification
{
    self.deleteBtn.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.thumbImageV.transform = CGAffineTransformIdentity;
    }];
}

- (void)deleteBtnAction:(UIButton *)sender
{
    if (self.deleteBlock) {
        self.deleteBlock(self.videoUrl);
    }
}

- (void)setIsLastCell:(BOOL)isLastCell
{
    if (isLastCell) {
        _isLastCell = isLastCell;
        self.thumbImageV.image = nil;
        self.backView.hidden = NO;
    }else {
        _isLastCell = isLastCell;
        self.backView.hidden = YES;
    }
}

- (void)thumbImgVScaleAnimate
{
    [UIView animateWithDuration:0.1 animations:^{
        _thumbImageV.transform = CGAffineTransformMakeScale(0.92, 0.92);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            _thumbImageV.transform = CGAffineTransformMakeScale(1.05, 1.05);
        } completion:^(BOOL finished) {
            _thumbImageV.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    _videoUrl = videoUrl;
    self.isLastCell = NO;
    NSString *thumbPath = [[videoUrl absoluteString] stringByReplacingOccurrencesOfString:@".mp4" withString:@".png"];
    thumbPath = [thumbPath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
    _thumbImageV.image = [UIImage imageWithContentsOfFile:thumbPath];
}

@end
