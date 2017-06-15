//
//  DWDSpeakImageView.m
//  EduChat
//
//  Created by Superman on 16/6/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSpeakImageView.h"
#import <AVFoundation/AVFoundation.h>
#import "DWDChatMsgClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDMessageTimerManager.h"
#import "DWDChatClient.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDTimeChatMsg.h"
#import <YYModel.h>

@interface DWDSpeakImageView() <DWDAudioClientDelegate>

@property (nonatomic , assign) CFTimeInterval audioStartRecodeTime;
@property (nonatomic , assign) CFTimeInterval audioEndRecodeTime;

@property (nonatomic , strong) DWDChatMsgClient *chatMsgClient;
@property (nonatomic , copy) NSString *mp3FileName;

@property (nonatomic , weak) MBProgressHUD *hud;
@property (nonatomic , strong) DWDAudioChatMsg *recordingMsg;

@property (nonatomic , assign) BOOL isCancleSpeakWandering;
@property (nonatomic , assign) BOOL beyondOneMinuteEndRecord;


@property (nonatomic , assign) CFTimeInterval beginTouchTime;

@property (nonatomic , strong) NSMutableArray *modelCach;

@property (nonatomic , strong) NSTimer *timer;


@end
@implementation DWDSpeakImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImage *image = [UIImage imageNamed:@"btn_speak_normal"];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
        _imageView = imageview;
        [self addSubview:imageview];
        
        UILabel *label = [[UILabel alloc] init];
        NSString *str = NSLocalizedString(@"Hold To Speak", nil);
        label.text = str;
        label.textAlignment = NSTextAlignmentCenter;
        [label setTextColor:DWDColorContent];
        [label sizeToFit];
        _label = label;
        [self addSubview:label];
        
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(speakLongpressAction:)];
        longpress.allowableMovement = 0;
        longpress.minimumPressDuration = 1.0;
        longpress.allowableMovement = 50.0;
        [self addGestureRecognizer:longpress];
        
    }
    return self;
}

- (void)afterOneMinRecording{
    if (_recordingMsg && _recordingMsg.recording == YES) {
        [DWDProgressHUD showText:@"只能录1分钟以内的消息"];
        [self normalCancelRecord];
        _beyondOneMinuteEndRecord = YES;
    }
    [_timer invalidate];
    _timer = nil;
}

/** 长按触发 */
- (void)speakLongpressAction:(UILongPressGestureRecognizer *)longpress{
    switch (longpress.state) {
        case UIGestureRecognizerStateBegan:{
            if (_timer) {
                [_timer invalidate];
            }
            
            DWDAudioChatMsg *audioMsg;
            audioMsg = [self.chatMsgClient creatAudioMsgFrom:[DWDCustInfo shared].custId to:self.toUser duration:@3 observe:_chatVc mp3FileName:_mp3FileName chatType:self.chatType];
            audioMsg.recording = YES;
            _recordingMsg = audioMsg;
            
            _timer = [NSTimer timerWithTimeInterval:59.0 target:self selector:@selector(afterOneMinRecording) userInfo:nil repeats:NO];
            
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
            
            [self.modelCach addObject:audioMsg];
            
            [self saveMessageToDBWithMessage:audioMsg];
            
            if ([self.delegate respondsToSelector:@selector(speakImageViewLongpressActionWithMsg:)]) { // 通知控制器刷新界面
                [self.delegate speakImageViewLongpressActionWithMsg:[NSArray arrayWithObject:audioMsg]];
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (_beyondOneMinuteEndRecord) return;
            // 手指位置不同 , 展示不同图片
            if ([longpress locationInView:self].y < -10) {  // 上滑可以取消
                _isCancleSpeakWandering = YES;
                self.hud.labelText = @"松开手指取消";
                UIImageView *custImgView = (UIImageView *)self.hud.customView;
                custImgView.image = [UIImage imageNamed:@"ic_revocation_popup_window_parents_dialogue_pages"];
            }else if ([longpress locationInView:self].y >= -10){
                _isCancleSpeakWandering = NO;
                self.hud.labelText = @"正在录音";
                UIImageView *custImgView = (UIImageView *)self.hud.customView;
                custImgView.image = [UIImage imageNamed:@"ic_volume_popup_window_one"];
            }
        }
            
            break;
        case UIGestureRecognizerStateEnded:{
            [_hud hide:YES];
            if (_beyondOneMinuteEndRecord){
                _beyondOneMinuteEndRecord = NO;
                return;
            }
            // 结束录音 , 并且可以再次创建Model
            [self.audioClient cancleRecord];
            
            if ([longpress locationInView:self].y < -10){ // 松手时 小于-10
                [self cancelRecordAndDeleteDatas];
            }else{
                [self normalCancelRecord]; // 正常结束录音  修改模型状态
            }
        }
            
            break;
        case UIGestureRecognizerStateCancelled:{  // 被电话打断
            [self cancelRecordAndDeleteDatas];
        }
            break;
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    DWDLog(@"begin");
    _beginTouchTime = CACurrentMediaTime();
    
    if ([self.delegate respondsToSelector:@selector(speakImageViewStartRecordAudio)]) {
        [self.delegate speakImageViewStartRecordAudio]; // 结束控制器的语音播放
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud = hud;
    hud.labelText = @"正在录音";
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_volume_popup_window_one"]];
    // 按下按钮  即开始创建语音模型并插入刷新表格
    self.audioStartRecodeTime = CACurrentMediaTime();
    
    NSURL *tempUrl =
    [NSURL fileURLWithPath:[NSTemporaryDirectory()
                            stringByAppendingString:@"VoiceInputFile"]];  // pcm数据输入临时路径
    
    NSString *mp3FileName = [[NSUUID UUID] UUIDString];
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    
    _mp3FileName = mp3FileName;
    
    [self.audioClient startRecorderAudioWithTempFile:tempUrl mp3FileName:mp3FileName];  // 此mp3文件名  不含路径
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    DWDLog(@"end");
        if (CACurrentMediaTime() - _beginTouchTime <= 1) {
            self.hud.labelText = @"时间太短!不能录音";
        }else{
            self.hud.labelText = @"录音不成功,请重新录音发送";
        }
        
        [self.hud hide:YES afterDelay:1.0];
        [self.audioClient endRecord];
}

- (void)cancelRecordAndDeleteDatas{
    self.hud.tintColor = [UIColor whiteColor];
    [self.audioClient cancleRecord];
    _recordingMsg.recording = NO;
    if ([self.delegate respondsToSelector:@selector(cancelRecordAndDeleteDatasActionsWithMsg:)]) {
        [self.delegate cancelRecordAndDeleteDatasActionsWithMsg:_recordingMsg];
    }
    self.audioStartRecodeTime = 0;  // 重置录音起始时间
    [self.hud hide:YES];
}

- (void)normalCancelRecord{
    [self.hud hide:YES];
    
    [self.audioClient cancleRecord];
    
    self.audioEndRecodeTime = CACurrentMediaTime();
    
    _recordingMsg.recording = NO;
    _recordingMsg.fileName = [self.audioClient endRecord];  // 结束录音并返回mp3文件名
    _recordingMsg.fileKey = _recordingMsg.fileName;
    _recordingMsg.duration = [NSNumber numberWithDouble:(self.audioEndRecodeTime - self.audioStartRecodeTime)];
    
    [self saveMessageToDBWithMessage:_recordingMsg];
    
    // 不小于1秒的语音  上传服务器
    [self sendAudioMsgWithMsg:_recordingMsg];
    
    // 发送消息, 40s后判断超时时间
    
    [[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict setObject:@{@"content" : [_recordingMsg yy_modelToJSONString], @"chatType" : @(_chatType) , @"toUser" : _toUser} forKey:_recordingMsg.msgId];// 缓存消息内容
    
    DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:40 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : _recordingMsg.msgId , @"toId" : _toUser, @"chatType" : @(_chatType)} repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; // 加入主运行循环
    
    [timerManager.timerCachDict setObject:timer forKey:_recordingMsg.msgId];  // 缓存超时定时器
    
}

- (void)sendAudioMsgWithMsg:(DWDAudioChatMsg *)audioMsg{
    if (self.chatType == DWDChatTypeGroup || self.chatType == DWDChatTypeClass) {
        [self uploadAndSendAudioMsg:audioMsg mutableChat:YES];   // send 群聊
    }else{
        [self uploadAndSendAudioMsg:audioMsg mutableChat:NO];   // send 单聊
    }
}

- (void)uploadAndSendAudioMsg:(DWDAudioChatMsg *)audioMsg mutableChat:(BOOL )isMutableChat{
    // 置发送状态为发送中
    audioMsg.state = DWDChatMsgStateSending;
    NSNumber *toId = _toUser;
    DWDChatType chatType = self.chatType;
    
    [[DWDAliyunManager sharedAliyunManager] uploadMP3AsyncWithFileName:audioMsg.fileKey success:^{
        
        // 上传阿里云成功 , 通过socket发送模型数据给对方
        
        if (isMutableChat) {
            [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeAudioForO2M:audioMsg]];
        }else{
            [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeAudioForO2O:audioMsg]];
        }
        
        [self.modelCach removeObject:audioMsg];
        
        [[DWDAliyunManager sharedAliyunManager] cancelAndRemovePutOperationWithURLString:audioMsg.fileKey];
        
        DWDLog(@"上传语音到阿里云成功! 发送模型数据到服务器");
        
    } Failed:^(NSError *error) {
        
        [DWDProgressHUD showText:@"发送语音失败" afterDelay:1.0];
        audioMsg.state = DWDChatMsgStateError;
        
        // 上传失败 更新消息发送状态为失败
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateMsgStateToState:DWDChatMsgStateError WithMsgId:audioMsg.msgId toUserId:toId chatType:chatType success:^{
            
            if ([self.delegate respondsToSelector:@selector(uploadAudioMsgFailedWithMsg:)]) {
                [self.delegate uploadAudioMsgFailedWithMsg:_recordingMsg];
            }
            
        } failure:^(NSError *error) {
            
        }];
    }];
}

#pragma mark - audio client delegate methods  //  录音定时器

- (void)audioClient:(DWDAudioClient *)client didRecordingWihtMetering:(CGFloat)metering {
    
    if (self.isCancleSpeakWandering) return;
    
    DWDLog(@"current %f", metering);
    
    UIImage *showOne;
    
    if (metering < 0.1) {
        showOne = [UIImage imageNamed:@"ic_volume_popup_window_one"];
    } else if (metering < 0.2) {
        showOne = [UIImage imageNamed:@"ic_volume_popup_window_tow"];
    } else if (metering < 0.3) {
        showOne = [UIImage imageNamed:@"ic_volume_popup_window_three"];
    } else if (metering < 0.4) {
        showOne = [UIImage imageNamed:@"ic_volume_popup_window_four"];
    } else {
        showOne = [UIImage imageNamed:@"ic_volume_popup_window_five"];
    }
    
    UIImageView *customView = (UIImageView *)self.hud.customView;
    if (showOne) {
        customView.image = showOne;
    }
}

- (void)audioClient:(DWDAudioClient *)client didPlayingWihtMetering:(CGFloat)metering {
    
}

- (void)audioClientDidFinishPlaying:(DWDAudioClient *)client {
    
}

- (void)audioClientDidCancleRecord:(DWDAudioClient *)client {
    DWDLog(@"do animation thing here!");
}

#pragma mark - <私有方法>
- (void)saveMessageToDBWithMessage:(DWDBaseChatMsg *)msg{
    // 存消息模型到本地
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        DWDLog(@"历史消息保存成功");
        NSNumber *friendId;
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发的
            friendId = msg.toUser;
        }else{  //  别人发的
            if (self.chatType == DWDChatTypeClass || self.chatType == DWDChatTypeGroup) {
                friendId = msg.toUser;
            }else{
                friendId = msg.fromUser;
            }
        }
        
        if (([msg.msgType isEqualToString:kDWDMsgTypeText] || [msg.msgType isEqualToString:kDWDMsgTypeAudio] || [msg.msgType isEqualToString:kDWDMsgTypeImage] || [msg.msgType isEqualToString:kDWDMsgTypeVideo]) && [msg.fromUser isEqual:[DWDCustInfo shared].custId]) {
            
            //插一个数据到会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:msg FriendCusId:friendId myCusId:[DWDCustInfo shared].custId success:^{
                
            } failure:^{
                
            }];
        }
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

#pragma mark - getters
- (DWDAudioClient *)audioClient{
    if (!_audioClient) {
        _audioClient = [DWDAudioClient sharedAudioClient];
        _audioClient.delegate = self;
    }
    return _audioClient;
}

- (DWDChatMsgClient *)chatMsgClient{
    if (!_chatMsgClient) {
        _chatMsgClient = [[DWDChatMsgClient alloc] init];
    }
    return _chatMsgClient;
}

- (NSMutableArray *)modelCach{
    if (!_modelCach) {
        _modelCach = [NSMutableArray array];
    }
    return _modelCach;
}

@end
