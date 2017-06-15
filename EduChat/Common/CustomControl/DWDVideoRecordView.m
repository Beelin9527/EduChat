//
//  DWDVideoRecordView.m
//  EduChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDVideoRecordView.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import "DWDRecentVideoView.h"

#define kDuration 10.0
#define kTrans DWDScreenW/kDuration/60.0

NSString *const VIDEO_FOLDER = @"videoFolder";

typedef NS_ENUM(NSInteger, VideoStatus){
    VideoStatusEnded = 0,
    VideoStatusStarted
};

typedef NS_ENUM(NSInteger, recordViewStyle){
    recordViewStyleNomal,
    recordViewStyleCurrent
};

@interface DWDVideoRecordView ()<AVCaptureFileOutputRecordingDelegate>

{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDevice *_audioDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureDeviceInput *_audioInput;
    AVCaptureMovieFileOutput *_movieOutput;
    AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
}

@property (nonatomic, strong) UIImageView *topListImgV;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIImageView *focusCircle;
@property (nonatomic, strong) UILabel *cancelTipLbl;
@property (nonatomic, strong) UIButton *tapBtn;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIView *videoCover;
@property (nonatomic, strong) UIButton *changeBtn;
@property (nonatomic, strong) UIButton *flashModelBtn;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, assign) CGFloat progressWidth;
@property (nonatomic, assign) VideoStatus status;
@property (nonatomic, assign) recordViewStyle style;
@property (nonatomic, assign) BOOL canSave;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) NSMutableArray *currentVDs;
@property (nonatomic, strong) DWDRecentVideoView *recentVideoView;
@property (nonatomic, strong) NSString *mp4FileName;

@end


@implementation DWDVideoRecordView

//DWDSingletonM(VideoRecordView);

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.w = DWDScreenW;
        self.h = 400.0;
        self.x = 0;
        self.y = DWDScreenH - DWDTopHight;
        self.backgroundColor = DWDRGBColor(53, 54, 55);
        self.layer.masksToBounds = YES;
        
        [self createVideoFolderIfNotExist];
        [self setSubviews];
        [self layout];
    }
    return self;
}

- (void)setSubviews
{
    [self addSubview:self.topListImgV];
    [self addSubview:self.videoView];
    [self addSubview:self.videoCover];
    [self addSubview:self.tapBtn];
    [self addSubview:self.leftBtn];
    [self addSubview:self.rightBtn];
    [self addSubview:self.progressView];
    [self addSubview:self.cancelTipLbl];
    [self addGenstureRecognizer];
}

#pragma mark - 布局
- (void)layout
{
    [self.topListImgV makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(8.5);
        make.width.mas_equalTo(20.0);
        make.height.mas_equalTo(13.0);
    }];
    
    [self.videoView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(30.0);
        make.bottom.equalTo(self).offset(-90.0);
    }];
    
    [self.videoCover makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.videoView);
    }];
    
    [self.tapBtn makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-20.0);
        make.width.height.mas_equalTo(51.0);
    }];
    
    [self.leftBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15.0);
        make.bottom.equalTo(self).offset(-25.0);
        make.width.mas_equalTo(56.0);
        make.height.mas_equalTo(40.0);
    }];
    
    [self.rightBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.bottom.width.height.equalTo(self.leftBtn);
    }];
    
    [self.progressView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoView.mas_bottom);
        make.height.mas_equalTo(2.0);
        make.width.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    [self.cancelTipLbl makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.videoView).offset(-10.0);
        make.width.mas_equalTo(80.0);
        make.height.mas_equalTo(22.0);
    }];
    
}

#pragma mark - 回去授权
- (void)getAuthorization
{
    //此处获取摄像头授权
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:       //已授权，可使用
        {
            DWDLog(@"授权摄像头使用成功");
            [self setupAVCaptureInfo];
            break;
        }
        case AVAuthorizationStatusNotDetermined:    //未进行授权选择
        {
            //则再次请求授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){    //用户授权成功
                    [self setupAVCaptureInfo];
                    return;
                } else {        //用户拒绝授权
                    [self showMsgWithTitle:@"出错了" andContent:@"用户拒绝授权摄像头的使用权,返回上一页.请打开\n设置-->隐私/通用等权限设置"];
                    return;
                }
            }];
            break;
        }
        default:                                    //用户拒绝授权/未授权
        {
            [self showMsgWithTitle:@"出错了" andContent:@"拒绝授权,返回上一页.请检查下\n设置-->隐私/通用等权限设置"];
            break;
        }
    }

}

- (void)setupAVCaptureInfo
{
    [self addSession];
    
    [_captureSession beginConfiguration];
    
    [self addVideo];
    [self addAudio];
    [self addPreviewLayer];
    
    [_captureSession commitConfiguration];
    
    //开启会话-->注意,不等于开始录制
    [_captureSession startRunning];
    
}

- (void)addSession
{
    _captureSession = [[AVCaptureSession alloc] init];
    //设置视频分辨率
    //注意,这个地方设置的模式/分辨率大小将影响你后面拍摄照片/视频的大小,
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
}

- (void)addVideo
{
    // 获取摄像头输入设备， 创建 AVCaptureDeviceInput 对象

    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    
    [self addVideoInput];
    [self addMovieOutput];
}

- (void)addVideoInput
{
    NSError *videoError;
    
    // 视频输入对象
    // 根据输入设备初始化输入对象，用户获取输入数据
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&videoError];
    if (videoError) {
        DWDLog(@"---- 取得摄像头设备时出错 ------ %@",videoError);
        return;
    }
    
    // 将视频输入对象添加到会话 (AVCaptureSession) 中
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
}

- (void)addMovieOutput
{
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    if ([_captureSession canAddOutput:_movieOutput]) {
        [_captureSession addOutput:_movieOutput];
        AVCaptureConnection *captureConnection = [_movieOutput connectionWithMediaType:AVMediaTypeVideo];
        
        //设置视频旋转方向
        /*
         typedef NS_ENUM(NSInteger, AVCaptureVideoOrientation) {
         AVCaptureVideoOrientationPortrait           = 1,
         AVCaptureVideoOrientationPortraitUpsideDown = 2,
         AVCaptureVideoOrientationLandscapeRight     = 3,
         AVCaptureVideoOrientationLandscapeLeft      = 4,
         } NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;
         */
        //        if ([captureConnection isVideoOrientationSupported]) {
        //            [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        //        }
        
        // 视频稳定设置
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        
        captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;
    }
    
}

- (void)addAudio
{
    NSError *audioError;
    // 添加一个音频输入设备
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //  音频输入对象
    _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:_audioDevice error:&audioError];
    if (audioError) {
        DWDLog(@"取得录音设备时出错 ------ %@",audioError);
        return;
    }
    // 将音频输入对象添加到会话 (AVCaptureSession) 中
    if ([_captureSession canAddInput:_audioInput]) {
        [_captureSession addInput:_audioInput];
    }
}

- (void)addPreviewLayer
{
    [self layoutIfNeeded];
    
    // 通过会话 (AVCaptureSession) 创建预览层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _captureVideoPreviewLayer.frame = CGRectMake(0, -(DWDScreenH - 370), DWDScreenW, DWDScreenH);
//    _captureVideoPreviewLayer.frame = self.videoView.bounds;
    DWDLog(@"%f  %f",self.videoView.w,self.videoView.h);
    /* 填充模式
     Options are AVLayerVideoGravityResize, AVLayerVideoGravityResizeAspect and AVLayerVideoGravityResizeAspectFill. AVLayerVideoGravityResizeAspect is default.
     */
    //有时候需要拍摄完整屏幕大小的时候可以修改这个
//    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 如果预览图层和视频方向不一致,可以修改这个
    _captureVideoPreviewLayer.connection.videoOrientation = [_movieOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
//    _captureVideoPreviewLayer.position = CGPointMake(self.w*0.5,self.videoView.h*0.5);
    
    // 显示在视图表面的图层
    CALayer *layer = self.videoView.layer;
    layer.masksToBounds = YES;
    [self layoutIfNeeded];
    [layer addSublayer:_captureVideoPreviewLayer];
    
}

#pragma mark pop
- (void)showMsgWithTitle:(NSString *)title andContent:(NSString *)content
{
    [[[UIAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

#pragma mark 获取摄像头-->前/后

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark touchs

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DWDLog(@"touch");
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    BOOL condition = [self isInBtnRect:point];
    
    if (condition) {
        [self isFitCondition:condition];
        [self startAnimation];
        self.changeBtn.hidden= self.flashModelBtn.hidden = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    BOOL condition = [self isInBtnRect:point];
    
    [self isFitCondition:condition];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    BOOL condition = [self isInBtnRect:point];
    /*
     结束时候咱们设定有两种情况依然算录制成功
     1.抬手时,录制时长 > 1/5总时长
     2.录制进度条完成时,就算手指超出按钮范围也算录制成功 -- 此时 end 方法不会调用,因为用户手指还在屏幕上,所以直接代码调用录制成功的方法,将控制器切换
     */
    
    if (condition) {
        if (self.progressView.w < DWDScreenW * 0.80) {
            //录制完成
            [self recordComplete];
        }
    }
    
    [self stopAnimation];
    self.changeBtn.hidden = self.flashModelBtn.hidden = NO;
}

- (BOOL)isInBtnRect:(CGPoint)point
{
    CGFloat x = point.x;
    CGFloat y = point.y;
    return  (x>self.tapBtn.x && x<=self.tapBtn.x + self.tapBtn.w) && (y>self.tapBtn.y && y<=self.tapBtn.y + self.tapBtn.h);
}

- (void)isFitCondition:(BOOL)condition
{
    if (condition) {
        self.cancelTipLbl.text = @"上移取消";
        self.cancelTipLbl.backgroundColor = DWDRGBColor(90, 136, 231);
        self.cancelTipLbl.textColor = DWDRGBColor(254, 254, 255);
        self.progressView.backgroundColor =  DWDRGBColor(90, 136, 231);
    }else{
        self.cancelTipLbl.text = @"松手取消";
        self.cancelTipLbl.backgroundColor = [UIColor redColor];
        self.cancelTipLbl.textColor = [UIColor whiteColor];
        self.progressView.backgroundColor = DWDRGBColor(249, 98, 105);
    }
}

- (void)startAnimation
{
    if (self.status == VideoStatusEnded) {
        self.status = VideoStatusStarted;
        [UIView animateWithDuration:0.5 animations:^{
            self.cancelTipLbl.alpha = self.progressView.alpha = 1.0;
            self.tapBtn.alpha = 0.0;
            self.tapBtn.transform = CGAffineTransformMakeScale(2.0, 2.0);
        } completion:^(BOOL finished) {
            [self stopLink];
            [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }];
    }
}

- (void)stopAnimation{
    if (self.status == VideoStatusStarted) {
        self.status = VideoStatusEnded;
        
        [self stopLink];
        [self stopRecord];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.cancelTipLbl.alpha = self.progressView.alpha = 0.0;
            self.tapBtn.alpha = 1.0;
            self.tapBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            self.progressView.w = DWDScreenW;
            self.progressWidth = DWDScreenW;
        }];
    }
}

- (CADisplayLink *)link
{
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh:)];
        self.progressView.w = DWDScreenW;
        self.progressWidth = DWDScreenW;
        [self startRecord];
    }
    return _link;
}

- (void)stopLink
{
    _link.paused = YES;
    [_link invalidate];
    _link = nil;
}

- (void)refresh:(CADisplayLink *)link
{
    if (self.progressWidth <= 0) {
        self.progressWidth = 0;
        [self recordComplete];
        [self stopAnimation];
        return;
    }
    self.progressWidth -= kTrans;
    [self.progressView remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoView.mas_bottom);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(self.progressWidth);
        make.height.mas_equalTo(2.0);
    }];

}

#pragma mark 录制相关

- (void)createVideoFolderIfNotExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            DWDLog(@"创建保存视频文件夹失败");
        }
    }
}

- (NSURL *)outPutFileURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"outPut.mov"]];
}

//mp4路径
- (NSString *)getVideoMergeFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    self.mp4FileName = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".mp4"];
    NSString *fileName = [path stringByAppendingPathComponent:self.mp4FileName];
    
    return fileName;
}

- (void)startRecord
{
    [_movieOutput startRecordingToOutputFileURL:[self outPutFileURL] recordingDelegate:self];
}

- (void)stopRecord
{
    // 取消视频拍摄
    [_movieOutput stopRecording];
}

- (void)recordComplete
{
    self.canSave = YES;
}

//这个在完全退出小视频时调用
- (void)quit
{
    [_captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    DWDLog(@"---- 开始录制 ----");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    DWDLog(@"---- 录制结束 ---%@-%@ ",outputFileURL,captureOutput.outputFileURL);
    
    if (outputFileURL.absoluteString.length == 0 && captureOutput.outputFileURL.absoluteString.length == 0 ) {
        [self showMsgWithTitle:@"出错了" andContent:@"录制视频保存地址出错"];
        return;
    }
    
    if (self.canSave) {
        
        AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:outputFileURL options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
            
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
            NSString *videoPath = [self getVideoMergeFilePathString];
            exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
            //优化网络
            exportSession.shouldOptimizeForNetworkUse = true;
            //转换后的格式
            exportSession.outputFileType = AVFileTypeMPEG4;
            //异步导出
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                // 如果导出的状态为完成
                if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:exportSession.outputURL options:nil];
                        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                        gen.appliesPreferredTrackTransform = YES;
                        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                        NSError *error = nil;
                        CMTime actualTime;
                        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                        CGImageRelease(image);
                        NSData *imagedata=UIImagePNGRepresentation(thumb);
                        NSString *savedImagePath=[videoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".png"];
                        [imagedata writeToFile:savedImagePath atomically:YES];
                        [self pushToPlay:exportSession.outputURL thumbImage:thumb];
                    });
                    
                }else{
                    DWDLog(@"当前压缩进 度:%f",exportSession.progress);
                }
            }];
        }
        self.canSave = NO;
    }
}

- (void)pushToPlay:(NSURL *)url thumbImage:(UIImage *)image
{
    if (self.completionHandler) {
        self.completionHandler(self.mp4FileName, image);
    }
}

-(void)addGenstureRecognizer{
    
    UITapGestureRecognizer *singleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.delaysTouchesBegan = YES;
    
    UITapGestureRecognizer *doubleTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delaysTouchesBegan = YES;
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.videoView addGestureRecognizer:singleTapGesture];
    [self.videoView addGestureRecognizer:doubleTapGesture];
}

-(void)singleTap:(UITapGestureRecognizer *)tapGesture{
    
    DWDLog(@"单击");
    
    CGPoint point= [tapGesture locationInView:self.videoView];
    CGPoint convertPoint = [self.videoView convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    //将UI坐标转化为摄像头坐标,摄像头聚焦点范围0~1
    CGPoint cameraPoint= [_captureVideoPreviewLayer captureDevicePointOfInterestForPoint:convertPoint];
//    CGPoint cameraPoint = CGPointMake(convertPoint.y / DWDScreenH, 1 - convertPoint.x / DWDScreenW);
    [self setFocusCursorAnimationWithPoint:point];
    DWDLog(@"-------------------x=%f,y=%f",convertPoint.x,convertPoint.y);
    DWDLog(@"+++++++++++++++++++x=%f,y=%f",cameraPoint.x,cameraPoint.y);
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        
        /*
         @constant AVCaptureFocusModeLocked 锁定在当前焦距
         Indicates that the focus should be locked at the lens' current position.
         
         @constant AVCaptureFocusModeAutoFocus 自动对焦一次,然后切换到焦距锁定
         Indicates that the device should autofocus once and then change the focus mode to AVCaptureFocusModeLocked.
         
         @constant AVCaptureFocusModeContinuousAutoFocus 当需要时.自动调整焦距
         Indicates that the device should automatically focus when needed.
         */
        //聚焦
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            //聚焦点的位置
            if ([captureDevice isFocusPointOfInterestSupported]) {
                [captureDevice setFocusPointOfInterest:cameraPoint];
            }
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            DWDLog(@"聚焦模式修改为%zd",AVCaptureFocusModeContinuousAutoFocus);
        }else{
            DWDLog(@"聚焦模式修改失败");
        }

        /*
         @constant AVCaptureExposureModeLocked  曝光锁定在当前值
         Indicates that the exposure should be locked at its current value.
         
         @constant AVCaptureExposureModeAutoExpose 曝光自动调整一次然后锁定
         Indicates that the device should automatically adjust exposure once and then change the exposure mode to AVCaptureExposureModeLocked.
         
         @constant AVCaptureExposureModeContinuousAutoExposure 曝光自动调整
         Indicates that the device should automatically adjust exposure when needed.
         
         @constant AVCaptureExposureModeCustom 曝光只根据设定的值来
         Indicates that the device should only adjust exposure according to user provided ISO, exposureDuration values.
         
         */
        //曝光模式
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            //曝光点的位置
            if ([captureDevice isExposurePointOfInterestSupported]) {
                [captureDevice setExposurePointOfInterest:cameraPoint];
            }
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            DWDLog(@"曝光模式修改失败");
        }
    }];
}

//设置焦距
-(void)doubleTap:(UITapGestureRecognizer *)tapGesture{
    
    DWDLog(@"双击");
    
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if (captureDevice.videoZoomFactor == 1.0) {
            CGFloat current = 2.5;
            if (current < captureDevice.activeFormat.videoMaxZoomFactor) {
                [captureDevice rampToVideoZoomFactor:current withRate:10];
            }
        }else{
            [captureDevice rampToVideoZoomFactor:1.0 withRate:10];
        }
    }];
}

//光圈动画
-(void)setFocusCursorAnimationWithPoint:(CGPoint)point{
    self.focusCircle.center = point;
    self.focusCircle.transform = CGAffineTransformIdentity;
    self.focusCircle.alpha = 0.2;
    
    [UIView animateKeyframesWithDuration:0.8 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:2/8.0 animations:^{
            
            self.focusCircle.transform=CGAffineTransformMakeScale(0.5, 0.5);
            self.focusCircle.alpha = 1.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:3/8.0 relativeDuration:1/8.0 animations:^{
            
            self.focusCircle.alpha = 0.5;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:4/8.0 relativeDuration:1/8.0 animations:^{
            
            self.focusCircle.alpha = 1.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:5/8.0 relativeDuration:1/8.0 animations:^{
            
            self.focusCircle.alpha = 0.5;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:6/8.0 relativeDuration:1/8.0 animations:^{
            
            self.focusCircle.alpha = 1.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:7/8.0 relativeDuration:1/8.0 animations:^{
            
            self.focusCircle.alpha = 0.0;
        }];
        
    } completion:^(BOOL finished) {
        
    }];
}

//光圈
- (UIImageView *)focusCircle{
    if (!_focusCircle) {
        _focusCircle = [[UIImageView alloc] init];
        _focusCircle.frame = CGRectMake(0, 0, 120.0, 120.0);
        _focusCircle.image = [UIImage imageNamed:@"msg_small_video_enlarge"];
        [self.videoView addSubview:_focusCircle];
    }
    return _focusCircle;
}

//更改设备属性前一定要锁上
-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    //也可以直接用_videoDevice,但是下面这种更好
    AVCaptureDevice *captureDevice= [_videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        DWDLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [_captureSession beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [_captureSession commitConfiguration];
    }
}


#pragma mark - 加载子控件
- (UIImageView *)topListImgV
{
    if (!_topListImgV) {
        _topListImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_small_video_list"]];
    }
    return _topListImgV;
}

- (UIView *)videoView
{
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
    }
    return _videoView;
}

- (UIView *)videoCover
{
    if (!_videoCover) {
        _videoCover = [[UIView alloc] init];
        _videoCover.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:54.0/255.0 blue:55.0/255.0 alpha:0.98];
//        _videoCover = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        
        UIImageView *cameraIcon = [[UIImageView alloc] init];
        cameraIcon.frame = CGRectMake((DWDScreenW - 52.5) * 0.5, (280.0 - 34.0) * 0.5, 52.5, 34.0);
        cameraIcon.contentMode = UIViewContentModeScaleAspectFill;
        cameraIcon.image = [UIImage imageNamed:@"msg_small_video_ic"];
        [_videoCover addSubview:cameraIcon];
    }
    return _videoCover;
}

- (UIButton *)tapBtn
{
    if (!_tapBtn) {
        _tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapBtn setBackgroundImage:[UIImage imageNamed:@"msg_small_video_recording"] forState:UIControlStateNormal];
        _tapBtn.userInteractionEnabled = NO;
    }
    return _tapBtn;
}

- (UIButton *)leftBtn
{
    if (!_leftBtn) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.layer.masksToBounds = YES;
        leftBtn.layer.cornerRadius = 10.0;
        leftBtn.backgroundColor = [UIColor blackColor];
        leftBtn.contentMode = UIViewContentModeScaleAspectFill;
        [leftBtn addTarget:self action:@selector(leftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        NSString *thumbPath = [[[self.currentVDs lastObject] absoluteString] stringByReplacingOccurrencesOfString:@".mp4" withString:@".png"];
        thumbPath = [thumbPath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
        [leftBtn setImage:[UIImage imageWithContentsOfFile:thumbPath] forState:UIControlStateNormal];
        _leftBtn = leftBtn;
    }
    return _leftBtn;
}

- (UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setImage:[UIImage imageNamed:@"msg_small_video_close"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

- (UIView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = DWDRGBColor(90, 136, 231);
        _progressView.alpha = 0.0;
    }
    return _progressView;
}

- (UILabel *)cancelTipLbl
{
    if (!_cancelTipLbl) {
        _cancelTipLbl = [[UILabel alloc] init];
        _cancelTipLbl.backgroundColor = DWDRGBColor(90, 136, 231);
        _cancelTipLbl.textColor = DWDRGBColor(254, 254, 255);
        _cancelTipLbl.font = [UIFont systemFontOfSize:14];
        _cancelTipLbl.textAlignment = NSTextAlignmentCenter;
        _cancelTipLbl.text = @"上移取消";
        _cancelTipLbl.alpha = 0.0;
    }
    return _cancelTipLbl;
}

- (NSMutableArray *)currentVDs
{
    if (!_currentVDs) {
        _currentVDs = [NSMutableArray arrayWithCapacity:0];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *array = [fm contentsOfDirectoryAtPath:path error:&error];
        DWDLog(@"%@",array);
        
        for (NSString * vd in array) {
            if ([vd hasSuffix:@".mp4"]) {
                NSString *VDPath = [path stringByAppendingPathComponent:vd];
                NSURL *VDURL = [NSURL fileURLWithPath:VDPath];
                [_currentVDs addObject:VDURL];
            }
        }
    }
    return _currentVDs;
}

- (DWDRecentVideoView *)recentVideoView
{
    if (!_recentVideoView) {
        _recentVideoView = [[DWDRecentVideoView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, self.h)];
         WEAKSELF;
        _recentVideoView.block = ^(DWDRecentVideoViewHandleType type, NSString *mp4FileName, UIImage *thumbImage){
            if (type == DWDRecentVideoViewHandleTypeDismiss) {
                [weakSelf dismissCamera];
            }else if (type == DWDRecentVideoViewHandleTypeSendVideo){
                if (weakSelf.completionHandler) {
                    weakSelf.completionHandler(mp4FileName, thumbImage);
                }
            }else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.2 animations:^{
                        weakSelf.videoCover.alpha = 0;
                    }];
                });
            }
        };
    }
    return _recentVideoView;
}

#pragma mark - 左右按钮事件
- (void)leftBtnAction:(UIButton *)sender
{
    [self addSubview:self.recentVideoView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.recentVideoView showRecentVideo];
        self.videoCover.alpha = 1;
    });
}


- (void)rightBtnAction:(UIButton *)sender
{
    [self dismissCamera];
}

- (void)dismissCamera
{
    [UIView animateWithDuration:0.4 animations:^{
        self.y = DWDScreenH - DWDTopHight;
    } completion:^(BOOL finished) {
        [self quit];
        [self.recentVideoView removeFromSuperview];
        self.recentVideoView = nil;
        self.videoCover.alpha = 1;
    }];
    if (self.dissmisBlock) {
        self.dissmisBlock();

    }
}


- (void)showVideoRecordViewWithCompletionHandler:(void (^)(NSString *, UIImage *))handler
{
    self.completionHandler = handler;
    
    if (self.y == DWDScreenH - DWDTopHight) {
        [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.y -= self.h;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                self.videoCover.alpha = 0;
            }];
            [self performSelector:@selector(getAuthorization) withObject:nil afterDelay:0.1 inModes:@[NSDefaultRunLoopMode]];
        }];
    }
    
}

@end
