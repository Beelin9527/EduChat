//
//  DWDChatVideoCell.m
//  EduChat
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatVideoCell.h"
#import "DWDVideoPlayView.h"
#import "PreviewImageView.h"

@interface DWDChatVideoCell ()

@property (nonatomic, strong) UIImageView      *backgroundImgV;
@property (nonatomic, strong) UIImageView      *thumbImageV;
@property (nonatomic, strong) UIImageView      *videoIcon;
@property (nonatomic, strong) DWDVideoPlayView *videoView;
@property (nonatomic, weak  ) DWDVideoPlayView *fullVideoView;
@property (nonatomic, weak  ) UIImageView      *tempImageV;
@property (nonatomic, assign) CGRect           startRect;

@end

@implementation DWDChatVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self commitInitWithTitles];
        [self setSubviews];
        self.menuTargetView = self.backgroundImgV;
    }
    return self;
}

- (void)setSubviews
{
    self.backgroundImgV = [[UIImageView alloc] init];
    self.backgroundImgV.layer.masksToBounds = YES;
    self.backgroundImgV.userInteractionEnabled = YES;
    [self.contentView addSubview:self.backgroundImgV];
    
    self.thumbImageV = [[UIImageView alloc] init];
    self.thumbImageV.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbImageV.layer.masksToBounds = YES;
    self.thumbImageV.userInteractionEnabled = YES;
    [self.backgroundImgV addSubview:self.thumbImageV];
    
    self.videoView = [[DWDVideoPlayView alloc] init];
    self.videoView.userInteractionEnabled = NO;
    self.videoView.forbidVolume = YES;
    [self.backgroundImgV addSubview:self.videoView];
    
    self.videoIcon = [[UIImageView alloc] init];
    self.videoIcon.hidden = YES;
    self.videoIcon.image = [UIImage imageNamed:@"msg_vedio_paly_ic"];
    self.videoIcon.alpha = 0.8;
    [self.thumbImageV addSubview:self.videoIcon];
    
    UITapGestureRecognizer *tapThumbImgV = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbImgVTap:)];
    [self.thumbImageV addGestureRecognizer:tapThumbImgV];
    
    UITapGestureRecognizer *tapVideoView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoViewTap:)];
    [self.videoView addGestureRecognizer:tapVideoView];
    
    [self.backgroundImgV addGestureRecognizer:self.longPress];
}

- (void)setVideoChatMsg:(DWDVideoChatMsg *)videoChatMsg
{
    _videoChatMsg = videoChatMsg;
    
    [self.videoView stop];
    self.videoView.userInteractionEnabled = NO;
    
    if (self.videoChatMsg.fromType == DWDChatMsgFromTypeSelf) { //自己发的
        
        self.userType = DWDChatCellUserTypeMyself;

        //隐藏图标
        self.videoIcon.hidden = NO;
        //直接加载本地缩略图
        NSString * imagePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder"] stringByAppendingPathComponent:self.videoChatMsg.thumbFileKey];
        self.thumbImageV.image = [UIImage imageWithContentsOfFile:imagePath];
        
    }else {                                                     //别人发的
        
        self.userType = DWDChatCellUserTypeOther;

        //显示图标
        self.videoIcon.hidden = NO;
        //加载网络缩略图
        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:self.videoChatMsg.thumbFileKey.length!=0?self.videoChatMsg.thumbFileKey:[self.videoChatMsg.fileKey stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"]];
        [self.thumbImageV sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
        
    }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        [self buildMyselfNicknameFrame];
        [self buildMyselfAvatarFrame];
        self.backgroundImgV.frame = CGRectMake(60, 10 + nicknameFrame.size.height, DWDChatVideoWidth, DWDChatVideoHeight);
        self.thumbImageV.frame = CGRectMake(2, 2, self.backgroundImgV.w - 12, self.backgroundImgV.h - 4);
        
        UIImage *origin = [UIImage imageNamed:@"bg_show_chats_class_dialogue_pages_normal"];
        UIImage *backgimg = [origin resizableImageWithCapInsets:UIEdgeInsetsMake(origin.size.height * 0.5, origin.size.width * 0.5, origin.size.height * 0.5, origin.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
        self.backgroundImgV.image = backgimg;
    }else{
        [self buildOtherNicknameFrame];
        [self buildOtherAvatarFrame];
        self.backgroundImgV.frame = CGRectMake(60, 10 + nicknameFrame.size.height, DWDChatVideoWidth, DWDChatVideoHeight);
        self.thumbImageV.frame = CGRectMake(10, 2, self.backgroundImgV.w - 12, self.backgroundImgV.h - 4);
        
        UIImage *origin = [UIImage imageNamed:@"bg_show_chats_class_dialogue_pages_normal_other"];
        UIImage *backgimg = [origin resizableImageWithCapInsets:UIEdgeInsetsMake(origin.size.height * 0.5, origin.size.width * 0.5, origin.size.height * 0.5, origin.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
        self.backgroundImgV.image = backgimg;
    }
    self.nicknameLabel.frame = nicknameFrame;
    self.avatarImgView.frame = avatareFrame;
    self.videoView.frame = self.thumbImageV.frame;
    self.sendingIndicator.center = self.backgroundImgV.center;
    self.errorImgView.center = self.backgroundImgV.center;
    self.errorImgView.bounds = CGRectMake(0, 0, 20, 20);
    self.videoIcon.frame = CGRectMake((self.thumbImageV.w - 35) * 0.5, (self.thumbImageV.h - 35) * 0.5, 35, 35);

}

//点击缩略图,预览播放
- (void)handleThumbImgVTap:(UITapGestureRecognizer *)tap
{
    [self loadVideo];
}

//点击视频,全频播放
- (void)handleVideoViewTap:(UITapGestureRecognizer *)tap
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatVideoPlay object:nil];
    UIWindow *windows = [UIApplication sharedApplication].keyWindow;
    _startRect = [self.backgroundImgV convertRect:self.thumbImageV.frame toView:windows];

    UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapBackView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackViewTap:)];
    [backView addGestureRecognizer:tapBackView];
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    
    UIImageView *tempImgV = [[UIImageView alloc] init];
    tempImgV.frame = _startRect;
    tempImgV.contentMode = UIViewContentModeScaleAspectFill;
    tempImgV.layer.masksToBounds = YES;
    tempImgV.image = _thumbImageV.image;
    [backView addSubview:tempImgV];
    _tempImageV = tempImgV;
    
    DWDVideoPlayView *fullVideoView = [[DWDVideoPlayView alloc] init];
    fullVideoView.bounds = CGRectMake(0, 0, DWDScreenW, 300);
    fullVideoView.center = backView.center;
    [backView addSubview:fullVideoView];
    _fullVideoView = fullVideoView;
    
    [_videoView pause];

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        backView.backgroundColor = [UIColor blackColor];
        tempImgV.frame = CGRectMake(0, (DWDScreenH - 300) * 0.5, DWDScreenW, 300);
    } completion:^(BOOL finished) {

        fullVideoView.videoUrl = _videoView.videoUrl;
        [fullVideoView play];
    }];
    
}

- (void)handleBackViewTap:(UITapGestureRecognizer *)tap
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    [_fullVideoView stop];
    _fullVideoView = nil;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        tap.view.backgroundColor = [UIColor clearColor];
        _tempImageV.frame = _startRect;
    } completion:^(BOOL finished) {
        
        [tap.view removeFromSuperview];
        [_videoView play];
    }];
}

- (void)loadVideo
{
    self.videoIcon.hidden = YES;
    [self.contentView bringSubviewToFront:self.sendingIndicator];
    self.sendingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    [self playVideo];
}

- (void)playVideo
{
    NSString *mp4FilePath = [self is_file_exist:self.videoChatMsg.fileKey];
    
    if (mp4FilePath) {
        
        NSURL *mp4URL = [NSURL fileURLWithPath:mp4FilePath];
        [self.sendingIndicator stopAnimating];
        self.videoView.videoUrl = mp4URL;
        [self.videoView play];
        self.videoView.userInteractionEnabled = YES;
    }else {
        
        [[DWDAliyunManager sharedAliyunManager] downloadMp4ObjectAsyncWithObjecName:self.videoChatMsg.fileKey compltionBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.sendingIndicator stopAnimating];
                NSString * mp4FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder/recive"] stringByAppendingPathComponent:self.videoChatMsg.fileKey];
                NSURL *mp4URL = [NSURL fileURLWithPath:mp4FilePath];
                self.videoView.videoUrl = mp4URL;
                [self.videoView play];
                self.videoView.userInteractionEnabled = YES;
            });
        }];
    }
}

- (void)UIPrepareForNormalStatus {
    
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
  
    if (self.userType == DWDChatCellUserTypeMyself) {
       
        //班级暂时取消撤销
        if (self.chatType == DWDChatTypeClass) {
             self.menuTitles = @[@"Relay" , @"Delete"];
        }else{
            self.menuTitles = @[@"Relay" , @"Delete", @"Revoke"];
        }

    }else{
          self.menuTitles = @[@"Delete", @"Revoke"];
    }
    self.thumbImageV.userInteractionEnabled = YES;
}

- (void)UIPrepareForSendingDataStatus {
    
    [self.contentView bringSubviewToFront:self.sendingIndicator];
    self.sendingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.errorImgView.hidden = YES;
    [self.videoView stop];
    self.thumbImageV.userInteractionEnabled = NO;
    self.videoIcon.hidden = YES;
    
    self.menuTitles = @[@"Delete"];
}

- (void)UIPrepareForErrorStatus {
    
    [self.contentView bringSubviewToFront:self.errorImgView];
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = NO;
    [self.videoView stop];
    self.thumbImageV.userInteractionEnabled = NO;
    self.videoIcon.hidden = YES;
    
    self.menuTitles = @[@"Delete"];
}

- (CGFloat)getHeight
{
    return self.isShowNickname ? DWDChatVideoHeight + 2 * DWDCellPadding + [self getNicknameSize].height :  DWDChatVideoHeight + 2 * DWDCellPadding;
}

- (NSString *)get_filename:(NSString *)name
{
    return [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder/recive"] stringByAppendingPathComponent:name];
}

- (NSString *)is_file_exist:(NSString *)name
{
//    BOOL isExist = NO;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *paths = @[@"/Documents/videoFolder",@"/Documents/videoFolder/recive"];
    for (NSString *path in paths) {
        
        NSString *filePath = [[NSHomeDirectory() stringByAppendingString:path] stringByAppendingPathComponent:name];
        if ([file_manager fileExistsAtPath:filePath]) {
//            isExist = YES;
            return filePath;
//            break;
        }
    }
    return nil;
//    return isExist;
}

@end
