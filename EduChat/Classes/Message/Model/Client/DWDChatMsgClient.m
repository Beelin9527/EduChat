//
//  DWDChatMsgClient.m
//  EduChat
//
//  Created by apple on 11/18/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "DWDChatMsgClient.h"
#import "UIImage+Utils.h"
#import "HttpClient.h"

#import "DWDChatClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDMessageDatabaseTool.h"

#define DWDChatImageMaxEdgeLength 80

@interface DWDChatMsgClient ()

@property (strong, nonatomic) NSMutableArray *uplaodingImages;
@property (strong, nonatomic) DWDChatClient *chatSocketClient;
@property (strong, nonatomic) DWDChatMsgDataClient *msgDataClient;

@end

@implementation DWDChatMsgClient

- (instancetype)init {
    self = [super init];
    if (self) {
        _uplaodingImages = [[NSMutableArray alloc] initWithCapacity:1];
        _chatSocketClient = [DWDChatClient sharedDWDChatClient];
        _msgDataClient = [DWDChatMsgDataClient sharedChatMsgDataClient];
    }
    return self;
}

- (NSArray *) loadMoreChatMsg {
    return nil;
}

//创建视频数据模型 --fzg
- (DWDVideoChatMsg *)creatVideoMsgFrom:(NSNumber *)from to:(NSNumber *)to observe:(id)observe mp4FileName:(NSString *)mp4fileName chatType:(DWDChatType)chatType
{
    DWDVideoChatMsg *newMsg = [[DWDVideoChatMsg alloc] init];
    
    DWDPhotoMetaModel *photohead = [[DWDPhotoMetaModel alloc] init];
    photohead.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    
    newMsg.fromUser = from;
    newMsg.toUser = to;
    newMsg.msgType = kDWDMsgTypeVideo;
    
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    long long timeStamp = timeInterval * 1000;
    NSNumber *creatTime = [NSNumber numberWithLongLong:timeStamp];
    
    newMsg.createTime = creatTime;
//    newMsg.recording = YES; // 创建时置为录状态
    newMsg.fileKey = mp4fileName;
    newMsg.thumbFileKey = [mp4fileName stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"];
    newMsg.state = DWDChatMsgStateSending;
    newMsg.photohead = photohead;
    newMsg.nickname = [DWDCustInfo shared].custNickname;
    newMsg.chatType = chatType;
//    newMsg.read = YES;
    
    newMsg.observing = YES;
//    [newMsg addObserver:observe forKeyPath:KDWDMsgObservableStateKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    return newMsg;

}


// 创建音频数据模型  ( 在 start speak 方法调用)
- (DWDAudioChatMsg *)creatAudioMsgFrom:(NSNumber *)from to:(NSNumber *)to duration:(NSNumber *)duration observe:(id)observe mp3FileName:(NSString *)mp3fileName chatType:(DWDChatType )chatType{
    
    DWDAudioChatMsg *newMsg = [[DWDAudioChatMsg alloc] init];
    
    DWDPhotoMetaModel *photohead = [[DWDPhotoMetaModel alloc] init];
    photohead.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    
    newMsg.fromUser = from;
    newMsg.toUser = to;
    newMsg.msgType = kDWDMsgTypeAudio;
    
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    long long timeStamp = timeInterval * 1000;
    NSNumber *creatTime = [NSNumber numberWithLongLong:timeStamp];
    
    newMsg.createTime = creatTime;
    newMsg.recording = YES; // 创建时置为录音状态
    newMsg.fileKey = mp3fileName;
    newMsg.state = DWDChatMsgStateSending;
    newMsg.photohead = photohead;
    newMsg.nickname = [DWDCustInfo shared].custNickname;
    newMsg.chatType = chatType;
    newMsg.read = YES;
    
    newMsg.observing = YES;
    
//    [newMsg addObserver:observe forKeyPath:KDWDMsgObservableStateKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    return newMsg;
}

- (DWDImageChatMsg *)creatImageMsgFrom:(NSNumber *)from to:(NSNumber *)to observe:(id)observer chatType:(DWDChatType )chatType{
    
    DWDImageChatMsg *newMsg = [[DWDImageChatMsg alloc] init];
    
    DWDPhotoMetaModel *photohead = [[DWDPhotoMetaModel alloc] init];
    photohead.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    
    newMsg.fromUser = from;
    newMsg.toUser = to;
    newMsg.msgType = kDWDMsgTypeImage;
    
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    long long timeStamp = timeInterval * 1000;
    NSNumber *creatTime = [NSNumber numberWithLongLong:timeStamp];
    newMsg.createTime = creatTime;
    newMsg.chatType = chatType;
    
    newMsg.fileName = DWDUUID;
    NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:newMsg.fileName];
    DWDLog(@"创建的图片模型中, 得到的公开urlstr : %@",urlStr);
    newMsg.fileKey = urlStr;
    
    newMsg.photohead = photohead;
     newMsg.nickname = [DWDCustInfo shared].custNickname;
    
    newMsg.state = DWDChatMsgStateSending;
    
    newMsg.observing = YES;
//    [newMsg addObserver:observer forKeyPath:KDWDMsgObservableStateKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    return newMsg;
}

// 创建文本模型发送文本消息
- (DWDTextChatMsg *)sendTextMsg:(NSString *)text from:(NSNumber *)from to:(NSNumber *)to observe:(id)observe mutableChat:(BOOL)isMutableChat chatType:(DWDChatType )chatType{
    
    DWDTextChatMsg *newMsg = [[DWDTextChatMsg alloc] init];
    
    DWDPhotoMetaModel *photohead = [[DWDPhotoMetaModel alloc] init];
    photohead.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    
    newMsg.fromUser = from;
    newMsg.toUser = to;
    
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    long long timeStamp = (long long)timeInterval * 1000;
    NSNumber *creatTime = [NSNumber numberWithLongLong:timeStamp];
    newMsg.createTime = creatTime;
    newMsg.msgType = kDWDMsgTypeText;
    newMsg.state = DWDChatMsgStateSending;
    newMsg.content = text;
    newMsg.photohead = photohead;
    
    newMsg.nickname = [DWDCustInfo shared].custNickname;
    newMsg.chatType = chatType;
    
    newMsg.observing = YES;
    
    //[self mockUploadingMsg:newMsg withObserve:observe];
//    [newMsg addObserver:observe forKeyPath:KDWDMsgObservableStateKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    DWDLog(@"newMst is %@", newMsg);
    
    if (isMutableChat) {
        [self.chatSocketClient sendData:[self.msgDataClient makePlainTextForO2M:newMsg]];
    }else{
        [self.chatSocketClient sendData:[self.msgDataClient makePlainTextForO2O:newMsg]];
    }
    return newMsg;
}

- (DWDTextChatMsg *)createTextMsgWithText:(NSString *)text from:(NSNumber *)from to:(NSNumber *)to chatType:(DWDChatType )chatType{
    __block DWDTextChatMsg *newMsg = [[DWDTextChatMsg alloc] init];
    
    DWDPhotoMetaModel *photohead = [[DWDPhotoMetaModel alloc] init];
    photohead.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    
    newMsg.fromUser = from;
    newMsg.toUser = to;
    
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    long long timeStamp = (long long)timeInterval * 1000;
    NSNumber *creatTime = [NSNumber numberWithLongLong:timeStamp];
    newMsg.createTime = creatTime;
    newMsg.msgType = kDWDMsgTypeText;
    newMsg.state = DWDChatMsgStateSending;
    newMsg.content = text;
    newMsg.photohead = photohead;
    
    newMsg.nickname = [DWDCustInfo shared].custNickname;
    newMsg.chatType = chatType;
    
    return newMsg;
}

// 发送语音消息 (在end speak 方法调用)
- (void)sendAudioMsg:(DWDAudioChatMsg *)audioMsg mutableChat:(BOOL)isMutableChat{
    
    // 置发送状态为发送中
    audioMsg.state = DWDChatMsgStateSending;
    
    // 沙盒中获取语音消息的mp3文件  转成data  发送
//    NSData *audioSource = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", audioMsg.fileKey]]];
//    DWDLog(@"mp3: %@", audioMsg.fileKey);
//    DWDLog(@"upload audioSource here, data length is %lu kb", (unsigned long)audioSource.length / 1024);
    
    // 上传语音二进制 OSS
    // 给定音频文件名, 到沙河获取MP3文件 , 发送到阿里
    [[DWDAliyunManager sharedAliyunManager] uploadMP3AsyncWithFileName:audioMsg.fileKey success:^{
        
        // 上传阿里云成功 , 通过socket发送模型数据给对方
        if (isMutableChat) {
            [self.chatSocketClient sendData:[self.msgDataClient makeAudioForO2M:audioMsg]];
        }else{
            [self.chatSocketClient sendData:[self.msgDataClient makeAudioForO2O:audioMsg]];
        }
        
        DWDLog(@"上传语音到阿里云成功!");
        
        [[DWDAliyunManager sharedAliyunManager] cancelAndRemovePutOperationWithURLString:audioMsg.fileKey];
        
    } Failed:^(NSError *error) {
        DWDLog(@"error : %@",error);
        audioMsg.state = DWDChatMsgStateError;
    }];
}

- (void)sendImageMsg:(DWDImageChatMsg *)imageMsg image:(UIImage *)image progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock mutableChat:(BOOL)isMutableChat{
    imageMsg.state = DWDChatMsgStateSending;
    
    // 高清图片在这里已经存入到本地  传image的file name 进去 (UUID) 在内部生成阿里云的URL
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:imageMsg.fileName progressBlock:^(CGFloat progress) {
        progressFinished(progress);
        
    } success:^{
        
        if (isMutableChat) {
            [self.chatSocketClient sendData:[self.msgDataClient makeImageForO2M:imageMsg]];  // 发图片消息到服务器
        }else{
            [self.chatSocketClient sendData:[self.msgDataClient makeImageForO2O:imageMsg]];
        }
        
        DWDLog(@"上传图片到阿里云成功! , 正在发送图片模型到服务器..");
        successBlock();
        
    } Failed:^(NSError *error) {
        
        imageMsg.state = DWDChatMsgStateError;
        failedBlock(error);
    }];
}

// 上传二进制语音 , 应上传阿里云 (需改成OSS)
//- (void)uploadingMsg:(DWDBaseChatMsg *)msg data:(NSData *)data {
//    
//    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:@"http://static1.squarespace.com/static/52f9cb07e4b0eea0230b9862/t/5334304de4b0e2f3d74172e1/1395929166328/?format=500w"]
//                                                        options:0
//                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize)
//     {
//         DWDLog(@"downloaded %ld%%", receivedSize / expectedSize * 100);
//     }
//                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
//     {
//         if (image && finished)
//         {
//             msg.createTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
//             msg.state = DWDChatMsgStateSended;
//             
//             [self.chatSocketClient sendData:[self.msgDataClient makeAudioForO2O:msg]];
//         }
//         
//     }];
//    
//}


- (NSString *)getCurrentDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    return [dateFormatter stringFromDate:now];
}

/*
//- (void)cancleRecordAudio:(DWDChatMsg *)audioMsg {


//delete audiomsg in local database
//remove mp3 file in local cache
//NSFileManager *defaultManager = [NSFileManager defaultManager];
//[defaultManager removeItemAtPath:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", audioMsg.attachment]] error:nil];
//}

- (DWDChatMsg *)sendImgMsg:(UIImage *)image from:(NSString *)from to:(NSString *)to observe:(id)observe {
    
    image = [image rotateImage:image];
    
    CGSize drawSize = CGSizeZero;
    if (image.size.width < image.size.height) {
        
        if (image.size.width > DWDChatImageMaxEdgeLength) {
            CGFloat k = ceil(image.size.width / DWDChatImageMaxEdgeLength);
            drawSize = CGSizeMake(DWDChatImageMaxEdgeLength,
                                  image.size.height / k);
        }
        
    } else {
        
        if (image.size.height > DWDChatImageMaxEdgeLength) {
            CGFloat k = ceil(image.size.height / DWDChatImageMaxEdgeLength);
            drawSize = CGSizeMake(image.size.width / k, DWDChatImageMaxEdgeLength);
        }
    }
    
    UIImage *thumb = [image renderAtSize:drawSize];
    
    DWDChatMsg *imgMsg = [[DWDChatMsg alloc] init];
    imgMsg.from = from;
    imgMsg.to = to;
    imgMsg.type = @"image";
    imgMsg.status = @"sending";
    
    imgMsg.createDate = [self getCurrentDateString];
    imgMsg.attachmentDes = [NSString stringWithFormat:@"%d,%d", (int)drawSize.width, (int)drawSize.height];
    imgMsg.attachment = [[NSUUID UUID] UUIDString];
    
    NSData *imgData = UIImagePNGRepresentation(thumb);
    [imgData writeToFile:[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", imgMsg.attachment]] atomically:YES];
    [self mockUploadingMsg:imgMsg withObserve:observe];
    
    return imgMsg;
}
*/
@end
