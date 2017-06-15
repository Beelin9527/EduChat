//
//  DWDLIchaoTextVc.m
//  EduChat
//
//  Created by Superman on 16/2/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLIchaoTextVc.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+extend.h"
#import "DWDRelayOnChatController.h"

#import <AVFoundation/AVFoundation.h>
@interface DWDLIchaoTextVc () <AVCaptureVideoDataOutputSampleBufferDelegate , AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic , weak) UIImageView *imageview1;
@property (nonatomic , weak) UIImageView *imageview2;
@property (nonatomic , copy) NSString *urlStr;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , weak) UITextField *field;


@property (nonatomic , strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic , strong) AVCaptureAudioDataOutput *audioOutput;

@end

@implementation DWDLIchaoTextVc

- (void)he{
//    NSString *str = @"[冷汗],[发呆],[发怒],[吐],[呲牙],[哭],[害羞],[尴尬],[得意],[微笑],[惊讶],[抓狂],[撇嘴],[流泪],[睡],[色],[调皮],[酷],[闭嘴],[难过],[偷笑],[傲慢],[再见],[发奋],[可爱],[咒骂],[嘘],[困],[大兵],[惊恐],[憨笑],[折磨],[敲打],[晕],[流汗],[疑问],[白眼],[衰],[饥饿],[骷髅],[亲亲],[可怜],[右哼],[吓],[哈欠],[坏笑],[委屈],[安慰],[左哼],[快哭了],[抠鼻],[擦汗],[敬礼],[潜水],[石化],[糗大了],[鄙视],[阴险],[鬼脸],[鼓掌],[兵乓球],[剑],[加油],[叹气],[心碎],[无语],[梨],[汽车],[灯泡],[爱心],[狂汗],[生病],[示爱],[米饭],[船舵],[菜刀],[萝卜],[赞],[轮船],[飞机],[位子],[保龄球],[信用卡],[刷子],[勋章],[天平],[太阳],[小兵],[激光剑],[炸弹],[码表],[窗子],[篮子],[花],[钱包],[钻石],[锤子],[门],[雨伞],[雪花],[吉他],[唱片],[夜晚],[披萨],[收音机],[望远镜],[牙膏],[牙齿],[牛角包],[甜甜圈],[电话],[秒表],[红酒],[腿肉],[茶杯],[药],[行李箱],[购物袋],[键盘],[饼干],[下雨],[下雪],[不],[冰雹],[多云],[大风],[好],[对],[弱],[强],[手掌],[拳头],[握手],[支持],[溜],[爱你],[胜利],[闪电],[阴天],[雷电]";
//    
//    NSString *str1 = @"expression_angry_big,expression_comeon_big,expression_cry_big,expression_example_big,expression_good_big,expression_hard_big,expression_hi_big,expression_holiday_big,expression_love_big,expression_medicine_big,expression_night_big,expression_omg_big,expression_study_big,expression_tks_big,expression_what_big,expression_wrong_big";
//    
//    NSArray *arr1 = [str componentsSeparatedByString:@","];
//    NSArray *arr2 = [str1 componentsSeparatedByString:@","];
//    
//    NSArray *emotion = @[arr1,arr2];
//    
//    BOOL suc = [emotion writeToFile:@"/Users/apple/Desktop/123456/emotion.plist" atomically:NO];
//    
//    DWDLog(@"%zd" , suc);
    
}

- (void)abcd{
    
    NSArray *arr = @[@"1"];
    
    NSDictionary *params = @{@"msgIds" : arr,
                             @"tid" : @1,
                             @"cid" : @1,
                             @"type" : @2,
                             @"chatType" : @(1)};
    
    [[DWDWebManager sharedManager] postApi:@"groupchat/deleteMsg" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DWDLog(@"ususususususus  ,,  %@ " , responseObject);
        
        if ([responseObject[@"result"] isEqualToNumber:@1]) {  // 撤销成功
//            DWDNoteChatMsg *note = [DWDNoteChatMsg new];
//            note.noteString = @"你撤回了一条消息";
//            note.fromUser = [DWDCustInfo shared].custId;
//            note.toUser = toUser;
//            note.createTime = msg.createTime;
//            note.msgId = DWDUUID;
//            note.msgType = kDWDMsgTypeNote;
//            note.state = DWDChatMsgStateSended;
            
            // 删除库 存库
//            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageWithFriendId:toUser msgs:@[msg] chatType:chatType success:^{
//                [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:note success:^{
//                    
//                    success(note);
//                    
//                } failure:^(NSError *error) {
//                    
//                }];
//            } failure:^(NSError *error) {
//                
//            }];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [btn addTarget:self action:@selector(abcd) forControlEvents:UIControlEventTouchUpInside];
    btn.center = self.view.center;
    [self.view addSubview:btn];
//    // 配置视频输入
//    AVCaptureSession *captureSession = [AVCaptureSession new];
//    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
//    
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    
//    // 获取用户相机和麦克风使用权限
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//        
//    }];
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//        
//    }];
//    
//    // 判断权限
//    NSString *mediaTypeVidio = AVMediaTypeVideo;
//    NSString *mediaTypeAudio = AVMediaTypeAudio;
//    AVAuthorizationStatus authStatusVidio = [AVCaptureDevice authorizationStatusForMediaType:mediaTypeVidio];
//    AVAuthorizationStatus authStatusAudio = [AVCaptureDevice authorizationStatusForMediaType:mediaTypeAudio];
//    if(authStatusVidio == AVAuthorizationStatusRestricted || authStatusVidio == AVAuthorizationStatusDenied || authStatusAudio == AVAuthorizationStatusRestricted || authStatusAudio == AVAuthorizationStatusDenied){
//        
//        [DWDProgressHUD showText:@"相机和麦克风权限受限,请重试"];
//        return;
//    }
//    
//    NSError *error;
//    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
//    
//    // 设置视频防抖
//    AVCaptureConnection *connection = [AVCaptureConnection new];
//    
//    AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic; // 影院级别防抖
//    if ([device.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {  // 如果此设备支持防抖
//        [connection setPreferredVideoStabilizationMode:stabilizationMode];
//    }
//    
//    
//    dispatch_async(dispatch_queue_create("hello", NULL), ^{
//        if ([captureSession canAddInput:cameraDeviceInput]) {
//            [captureSession addInput:cameraDeviceInput];
//        }
//        
//        [captureSession startRunning];
//    });
//    
//    
//    // 配置音频输入
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    [audioSession setActive:YES error:nil];
//    
//    // 寻找期望的输入端口
//    NSArray* inputs = [audioSession availableInputs];
//    
//    AVAudioSessionPortDescription *builtInMic = nil;
//    for (AVAudioSessionPortDescription* port in inputs) {
//        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
//            builtInMic = port;
//            break;
//        }
//    }
//    
//    // 寻找期望的麦克风
//    for (AVAudioSessionDataSourceDescription* source in builtInMic.dataSources) {
//        if ([source.orientation isEqual:AVAudioSessionOrientationFront]) {  // 前置麦克风
//            [builtInMic setPreferredDataSource:source error:nil];
//            [audioSession setPreferredInput:builtInMic error:&error];
//            break;
//        }
//    }
//    
//    // 配置输出
//    NSString *vedioStr = [NSString stringWithFormat:@"/Documents/%@",[NSUUID UUID].UUIDString];
////    NSURL *vedioURL = [NSURL URLWithString:[NSHomeDirectory() stringByAppendingString:vedioStr]];
//    
//    AVCaptureVideoDataOutput *videooDataOutPut = [AVCaptureVideoDataOutput new];
//    [videooDataOutPut setSampleBufferDelegate:self queue:dispatch_queue_create("video queue", NULL)];
//    _videoOutput = videooDataOutPut;
//    
//    AVCaptureAudioDataOutput *audioDataOutPut = [AVCaptureAudioDataOutput new];
//    [audioDataOutPut setSampleBufferDelegate:self queue:dispatch_queue_create("audio queue", NULL)];
//    _audioOutput = audioDataOutPut;
    
    
//    AVAssetWriterInput *writerInputVideo = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil];
    
//    AVAssetWriterInput *writerInputAudio = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:nil];
}


#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>


/**
 @abstract
 Called once for each frame that is discarded. 丢帧时回调
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

#pragma mark - <AVCaptureAudioDataOutputSampleBufferDelegate>

/**
 @abstract
 Called whenever an AVCaptureVideoDataOutput instance or AVCaptureAudioDataOutput instance outputs a new video frame. 每输出一帧时回调 ,可能是视频帧也可能是音频
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}
@end
