//
//  DWDAudioClient.m
//  EduChat
//
//  Created by apple on 11/18/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAudioClient.h"
#import "lame.h"

typedef NS_ENUM(NSInteger, DWDAudioClientStatus) {
    DWDAudioClientStatusNormal,
    DWDAudioClientStatusRecording,
    DWDAudioClientStatusPlaying,
};

@interface DWDAudioClient () <AVAudioPlayerDelegate>

@property (nonatomic , strong) AVAudioSession *audioSession;

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) DWDAudioClientStatus status;

@property (strong, nonatomic) NSMutableArray *sendingAudios;

@property (nonatomic) BOOL isFinishConvert;
@property (nonatomic) BOOL isStopRecorde;

@property (strong, nonatomic) NSString *mp3FileName;

@end

@implementation DWDAudioClient

+ (instancetype)sharedAudioClient {
    
    static id audioClient;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        audioClient = [[self alloc] init];
    });
    
    return audioClient;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _sampleRate = 44100;
        _quality = AVAudioQualityLow;
        
        //start audio session
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];   // 必须在初始化  avplaer 之前初始化 session 否者播放不能成功
        _audioSession = audioSession;
        BOOL success;
        NSError *sessionError;
        
        success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError]; // 会话类型为播放和录音
        
        if (!success) DWDLog(@"error creating session: %@", [sessionError description]);
        
        success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&sessionError]; // 输出类型为扬声器
        
        if (!success) DWDLog(@"error override output audio port: %@", [sessionError description]);
        
        [audioSession setActive:YES error:nil];
        
        if (!success) {
            DWDLog(@"error creating session: %@", [sessionError description]);
            abort();  // 退出程序
        }
        
        //init audio recorder
        NSError *recorderError;
        
            NSURL *tempFile =
            [NSURL fileURLWithPath:[NSTemporaryDirectory()
                   stringByAppendingString:@"VoiceInputFile"]];  // pcm数据输入临时路径
        
        NSDictionary *settings =
        @{AVSampleRateKey:@44100,
          AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
          AVNumberOfChannelsKey:@2,
          AVEncoderAudioQualityKey:[NSNumber numberWithInt:self.quality]};
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:tempFile settings:settings error:&recorderError];  // 根据路径和配置 初始化session
        
        if (recorderError) {
            DWDLog(@"error creating avaudiorecorder: %@", [recorderError description]);
            abort();  // 退出程序
        }
        
        _recorder.meteringEnabled = YES;    //  必须和SESSION的创建在同一个方法里面  不然拿不到这个变化的值
        
        
    }
    return self;
}


// 开始录音
- (void)startRecorderAudioWithTempFile:(NSURL *)tempUrl mp3FileName:(NSString *)mp3FileName{

    self.isFinishConvert = NO;
    self.isStopRecorde = NO;
    
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    self.status = DWDAudioClientStatusRecording;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(recordTimerUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self conventToMp3WithMp3fileName:mp3FileName];
    });
}

- (NSString *)endRecord {
    
    [self.timer invalidate];
    self.timer = nil;
    if (!self.recorder) {
        DWDLog(@"what are you fucking doing? you need start first then you can stop, ok!");
        return nil;
    }
    
    self.status = DWDAudioClientStatusNormal;
    
    [self.recorder stop];
    
    self.isStopRecorde = YES;
    
    while (!self.isFinishConvert) {
        //DWDLog(@"wait convent finish");
    }
    
    return self.mp3FileName;
}

- (void)cancleRecord {
    
    [self.timer invalidate];
    
    if (!self.recorder) {
        DWDLog(@"what are you fucking doing? you need start first then you can stop, ok!");
        return;
    }
    
    self.status = DWDAudioClientStatusNormal;
    
    [self.recorder stop];
    
}

- (void)playAudioWithURL:(NSURL *)audioSource {

    NSError *playerError;
    
    // 第一次播放为什么不能打开
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioSource error:&playerError];
    
    if (playerError) {
        DWDLog(@"error creating player : %@", [playerError description]);
        return;
    }
    
    self.player.delegate = self;
    self.player.meteringEnabled = YES;
    [self.player prepareToPlay];
    [self.player play];
    
    self.status = DWDAudioClientStatusPlaying;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:.2
                                              target:self
                                            selector:@selector(playTimerUpdate)
                                            userInfo:nil
                                             repeats:YES];
}

#pragma mark - avaudioplayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    self.status = DWDAudioClientStatusNormal;
    [self.timer invalidate];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioClientDidFinishPlaying:)]) {
        [self.delegate audioClientDidFinishPlaying:self];
    }
}

#pragma mark - private mehtods  //  pcm ---> mp3
- (void)conventToMp3WithMp3fileName:(NSString *)mp3fileName {
    
    DWDLog(@"convert begin!!");
    
    NSString *cafFilePath = [NSTemporaryDirectory() stringByAppendingString:@"VoiceInputFile"];  // 临时保存录音文件的路径
//    _mp3FileName = [[NSUUID UUID] UUIDString];
//    self.mp3FileName = [self.mp3FileName stringByAppendingString:@".mp3"];
    self.mp3FileName = mp3fileName;
    
    //  mp3 文件的全路径
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:self.mp3FileName];
    
    @try {
        
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSASCIIStringEncoding], "rb");  // pcm无损数据
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");  // 压缩后的mp3
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE * 2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, self.sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        long curpos;
        BOOL isSkipPCMHeader = NO;   // 是否跳过PCM数据的头部
        
        do {
            curpos = ftell(pcm);
            
            long startPos = ftell(pcm);
            
            fseek(pcm, 0, SEEK_END);
            long endPos = ftell(pcm);
            
            long length = endPos - startPos;
            
            fseek(pcm, curpos, SEEK_SET);
            
            
            if (length > PCM_SIZE * 2 * sizeof(short int)) {
                
                if (!isSkipPCMHeader) {
                    //skip audio file header, If you do not skip file header
                    //you will heard some noise at the beginning!!!
                    fseek(pcm, 4 * 1024, SEEK_SET);
                    isSkipPCMHeader = YES;
                    DWDLog(@"skip pcm file header !!!!!!!!!!");
                }
                
                read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite(mp3_buffer, write, 1, mp3);
                //DWDLog(@"read %d bytes", write);
            }
            
            else {
                
                [NSThread sleepForTimeInterval:0.05];
                //DWDLog(@"sleep");
                
            }
            
        } while (!self.isStopRecorde);
        
        read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
        fwrite(mp3_buffer, write, 1, mp3);
        
        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
        fwrite(mp3_buffer, write, 1, mp3);
        DWDLog(@"read %d bytes and flush to mp3 file", write);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        self.isFinishConvert = YES;
    }
    @catch (NSException *exception) {
        DWDLog(@"%@", [exception description]);
    }
    @finally {
        DWDLog(@"convert mp3 finish!!!");
    }
}

- (void)recordTimerUpdate {
    
    [self.recorder updateMeters];  // 更新元数据
    
    float power = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioClient:didRecordingWihtMetering:)]) {
        [self.delegate audioClient:self didRecordingWihtMetering:power];
    }
}

- (void)playTimerUpdate {
    
    [self.player updateMeters];
    
    float power = pow(10, (0.05 * [self.player peakPowerForChannel:0]));
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioClient:didPlayingWihtMetering:)]) {
        [self.delegate audioClient:self didPlayingWihtMetering:power];
    }
}

- (void)endPlay{
    [self.player stop];
    
}

@end
