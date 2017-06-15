//
//  DWDAliyunManager.m
//  EduChat
//
//  Created by Superman on 16/1/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDAliyunManager.h"

NSString * const endPoint = @"http://oss-cn-hangzhou.aliyuncs.com";
NSString * const kDWDBucketName = @"educhat";

@interface DWDAliyunManager()

@property (nonatomic , strong) NSMutableDictionary *putDict;


@end

@implementation DWDAliyunManager

DWDSingletonM(AliyunManager);

OSSClient * client;

- (NSMutableDictionary *)putDict{
    if (!_putDict) {
        _putDict = [NSMutableDictionary dictionary];
    }
    return _putDict;
}

- (instancetype)init{
    if (self = [super init]) {
        id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:[DWDCustInfo shared].AccessKey
                                                                                                                secretKey:[DWDCustInfo shared].SecretKey];
        OSSClientConfiguration * conf = [OSSClientConfiguration new];
        conf.maxRetryCount = 2;
        conf.timeoutIntervalForRequest = 30;
        conf.timeoutIntervalForResource = 24 * 60 * 60;
        
        client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential clientConfiguration:conf];
        
    }
    return self;
}

// 获取共有URL
- (NSString *)getDownloadURLStringWithObjectName:(NSString *)objectName{
    NSString * publicURL = nil;
    // sign public url
    OSSTask * task = [client presignPublicURLWithBucketName:kDWDBucketName withObjectKey:objectName];
    if (!task.error) {
        publicURL = task.result;
        return publicURL;
    } else {
        DWDLog(@"sign url error: %@", task.error);
        return nil;
    }
    
    
    //    NSString * constrainURL = nil;
    //    // sign constrain url
    //    OSSTask * task = [client presignConstrainURLWithBucketName:kDWDBucketName withObjectKey:objectName
    //                                        withExpirationInterval: 30 * 60];
    //    if (!task.error) {
    //        constrainURL = task.result;
    //        return constrainURL;
    //    } else {
    //        DWDLog(@"error: %@", task.error);
    //        return nil;
    //    }
}

// 根据图片名称 (web url) 异步上传聊天图片
- (void)uploadChatImageWithImageName:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock{
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    NSString *urlStr = [self getDownloadURLStringWithObjectName:name]; // 保存这个上传操作到字典  key为url
//    urlStr = [urlStr stringByAppendingString:@".png"];
    
    [self.putDict setObject:put forKey:urlStr];
    
    // required fields
    put.bucketName = kDWDBucketName;
    put.objectKey = name;
    
    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:[urlStr imgKey]];
    
    put.uploadingFileURL = [NSURL URLWithString:path];
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        
        CGFloat progress = (CGFloat)totalByteSent/totalBytesExpectedToSend;
        progressFinished(progress * 100);
        
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        DWDLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            DWDLog(@"upload object success!");
            successBlock();
        } else {
            DWDLog(@"upload object failed, error: %@" , task.error);
            failedBlock(task.error);
        }
        return nil;
    }];
}

// 根据图片名称 (web url) 异步上传图片
- (void)uploadImage:(UIImage *)image Name:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock{
    DWDMarkLog(@"originImageSize:%@", NSStringFromCGSize(image.size));
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    NSString *urlStr = [self getDownloadURLStringWithObjectName:name]; // 保存这个上传操作到字典  key为url
    
    [self.putDict setObject:put forKey:urlStr];
    
    // required fields
    put.bucketName = kDWDBucketName;
    put.objectKey = name;
    
    /**
     第一步:
     图片压缩
     */
#warning <image compress>
    
    //    @autoreleasepool {
    //        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //            UIImage *newImage = image;
    //            CGFloat maxSize = 50.0f;
    //            CGFloat maxCompress = 0.7f;
    //            CGFloat currentCompress = 1.0f;
    //
    //            CGFloat picMaxSize = 1024.0f;
    //
    //            /**
    //             大于50K则压缩
    //             最大压缩比例0.7
    //             */
    //            NSData *imageData = UIImageJPEGRepresentation(image, currentCompress);
    //            CGFloat imageSize = (float)imageData.length / 1024.0f;
    //            DWDMarkLog(@"Origin File size is : %.2f KB",imageSize);
    //            //        if (![[HttpClient sharedClient].reachabilityManager isReachableViaWiFi])
    //
    //            if (imageSize > picMaxSize) {
    //                /**
    //
    //                 图片还是很大 并且 图片的宽高有一项比屏幕高度还要大
    //                 说明光压是不行的,还要"缩"
    //
    //                 缩的准则:
    //                 如果图片的长边,大于屏幕的长边的时候,让图片的长边缩至屏幕长边
    //                 并且宽度按照长度比例缩放
    //
    //                 */
    //                CGFloat width;
    //                CGFloat height;
    //                width = image.size.width * 0.9;
    //                height = image.size.height * 0.9;
    //                int maxCount = 0;
    //                while (UIImageJPEGRepresentation(newImage, 1).length / picMaxSize > picMaxSize && maxCount < 10) {
    //                    DWDMarkLog(@"size:%.2f KB", UIImageJPEGRepresentation(newImage, 1).length / 1024.0f);
    //                    UIGraphicsBeginImageContext((CGSize){width - 0.5f, height - 0.5f});
    //                    [newImage drawInRect:(CGRect){0, 0, width, height}];
    //                    newImage = UIGraphicsGetImageFromCurrentImageContext();
    //                    UIGraphicsEndImageContext();
    //                    width *= 0.9;
    //                    height *= 0.9;
    //                    maxCount ++;
    //                }
    //                imageSize = UIImageJPEGRepresentation(newImage, 1).length / 1024.0f;
    //
    //                while (imageSize > maxSize && currentCompress > maxCompress) {
    //                    currentCompress -= 0.1f;
    //                    imageData = UIImageJPEGRepresentation(newImage, currentCompress);
    //                    imageSize = imageData.length / 1024.0f;
    //                    DWDMarkLog(@"Compressing File size is : %.2f KB", imageSize);
    //                    newImage = [UIImage imageWithData:imageData];
    //                }
    //
    //            }
    
    /**
     第二步:
     存入本地
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        UIImage *newImage;
        @autoreleasepool {
            newImage = [UIImage imageWithData:UIImageJPEGRepresentation([image fixOrientation], 0.8)];
        }
        
        //            DWDPhotoMetaModel *model = [DWDPhotoMetaModel new];
        //            model.photoKey = urlStr;
        //            model.height = newImage.size.height;
        //            model.width = newImage.size.width;
        //            [[SDImageCache sharedImageCache] storeImage:[newImage renderAtSize:[model thumbSize]] forKey:[model thumbPhotoKey]];
        [[SDImageCache sharedImageCache] storeImage:newImage forKey:[urlStr imgKey] toDisk:YES];
        [[SDImageCache sharedImageCache] diskImageExistsWithKey:[urlStr imgKey] completion:^(BOOL isInCache) {
            if (isInCache) {
                DWDMarkLog(@"本地存储图片成功!");
                
                NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:[urlStr imgKey]];
                //        put.uploadingFileURL = [NSURL fileURLWithPath:path];
                //        NSString *pathStr = [[SDImageCache sharedImageCache] cachePathForKey:[urlStr imgKey] inPath:[NSBundle mainBundle] ];
                put.uploadingFileURL = [NSURL URLWithString:path];
                DWDMarkLog(@"urlKey:%@", [urlStr imgKey]);
                DWDMarkLog(@"uploadingFileURL:%@", put.uploadingFileURL);
                
                //    put.uploadingData = UIImageJPEGRepresentation(newImage, currentCompress);
                DWDMarkLog(@"Compressed File size is : %.2f KB",(float)UIImageJPEGRepresentation(image, 1).length/1024.0f);
                put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                    
                    CGFloat progress = (CGFloat)totalByteSent/totalBytesExpectedToSend;
                    progressFinished(progress * 100);
                    
                };
                
                
                OSSTask * putTask = [client putObject:put];
                
                [putTask continueWithBlock:^id(OSSTask *task) {
                    DWDLog(@"objectKey: %@", put.objectKey);
                    if (!task.error) {
                        DWDLog(@"upload object success!");
                        successBlock();
                    } else {
                        DWDLog(@"upload object failed, error: %@" , task.error);
                        failedBlock(task.error);
                    }
                    return nil;
                }];
            }
            
        }];
        
    });
    //});
    
    //    }
}

- (void)asyncUploadImageWithUUID:(NSString *)uuid progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock {
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    NSString *urlStr = [self getDownloadURLStringWithObjectName:uuid]; // 保存这个上传操作到字典  key为url
    
    [self.putDict setObject:put forKey:urlStr];
    
    // required fields
    put.bucketName = kDWDBucketName;
    put.objectKey = uuid;
    


    [[SDImageCache sharedImageCache] diskImageExistsWithKey:[urlStr imgKey] completion:^(BOOL isInCache) {
        if (isInCache) {
            DWDMarkLog(@"本地存储图片成功!");
            
            NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:[urlStr imgKey]];
            
            put.uploadingFileURL = [NSURL URLWithString:path];
            
            //    put.uploadingData = UIImageJPEGRepresentation(newImage, currentCompress);
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                
                CGFloat progress = (CGFloat)totalByteSent/totalBytesExpectedToSend;
                progressFinished(progress * 100);
                
            };
            
            if ([DWDCustInfo shared].AccessKey == nil) {
                [[HttpClient sharedClient] getApi:@"SysConfigRestService/getEntity" params:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                    DWDLog(@"SysConfigRestService/getEntity : %@" , responseObject[@"data"]);
                    
                    [DWDCustInfo shared].AccessKey = responseObject[@"data"][@"accessKeyId"];
                    [DWDCustInfo shared].SecretKey = responseObject[@"data"][@"accessKeySecret"];
                    [DWDCustInfo shared].ossUrl = responseObject[@"data"][@"ossUrl"];
                    
                    
                    OSSTask * putTask = [client putObject:put];
                    
                    [putTask continueWithBlock:^id(OSSTask *task) {
                        DWDLog(@"objectKey: %@", put.objectKey);
                        if (!task.error) {
                            DWDLog(@"upload object success!");
                            successBlock();
                        } else {
                            DWDLog(@"upload object failed, error: %@" , task.error);
                            failedBlock(task.error);
                        }
                        return nil;
                    }];
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    DWDLog(@"error : %@",error);
                    
                }];
            } else {
                
                OSSTask * putTask = [client putObject:put];
                
                [putTask continueWithBlock:^id(OSSTask *task) {
                    DWDLog(@"objectKey: %@", put.objectKey);
                    if (!task.error) {
                        DWDLog(@"upload object success!");
                        successBlock();
                    } else {
                        DWDLog(@"upload object failed, error: %@" , task.error);
                        failedBlock(task.error);
                    }
                    return nil;
                }];
            }
            

        }
    }];
        
    //});
    
    //    }
}


// 同步上传
- (void)syncUploadImage:(UIImage *)image Name:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock{
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    // required fields
    put.bucketName = kDWDBucketName;
    put.objectKey = name;
    
    put.uploadingData = UIImagePNGRepresentation(image);
    
    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        CGFloat progress = (CGFloat)totalByteSent/totalBytesExpectedToSend;
        progressFinished(progress * 100);
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask waitUntilFinished]; // 阻塞直到上传完成
    
    if (!putTask.error) {
        DWDLog(@"upload object success!");
        successBlock();
    } else {
        DWDLog(@"upload object failed, error: %@" , putTask.error);
        failedBlock(putTask.error);
    }
}


// 根据图片名称(web url) 下载图片
- (void)downloadImageWithName:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished completionBlock:(void (^)(UIImage *downloadImage))completion Failed:(void(^)(NSError *error))failedBlock{
    __block UIImage *downloadImage;
    
    
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    // required
    request.bucketName = kDWDBucketName;
    request.objectKey = name;
    
    //optional
    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        CGFloat progress = totalBytesWritten/totalBytesExpectedToWrite;
        progressFinished(progress);
    };
    // NSString * docDir = [self getDocumentDirectory];
    // request.downloadToFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"downloadfile"]];
    
    OSSTask * getTask = [client getObject:request];
    
    [getTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            DWDLog(@"download object success!");
            OSSGetObjectResult * getResult = task.result;
            DWDLog(@"download dota length: %tu", [getResult.downloadedData length]);
            downloadImage = [UIImage imageWithData:getResult.downloadedData];
            
            completion(downloadImage);
            
        } else {
            DWDLog(@"download object failed, error: %@" ,task.error);
            failedBlock(task.error);
        }
        return nil;
    }];
}

// 异步上传音频文件到OSS
- (void)uploadMP3AsyncWithFileName:(NSString *)mp3fileName success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock{
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    NSString *urlStr = [self getDownloadURLStringWithObjectName:mp3fileName];
    
    [self.putDict setObject:put forKey:urlStr];
    
    // required fields
    put.bucketName = kDWDBucketName;
    put.objectKey = mp3fileName;
    NSString * mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3fileName];
    put.uploadingFileURL = [NSURL fileURLWithPath:mp3FilePath];
    
    // optional fields
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        DWDLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        DWDLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            
            DWDLog(@"upload mp3 object success!");
            successBlock();
            
        } else {
            
            DWDLog(@"upload object failed, error: %@" , task.error);
            failedBlock(task.error);
            
        }
        return nil;
    }];
}

// 异步下载音频文件到OSS
- (void)downloadMp3ObjectAsyncWithObjecName:(NSString *)mp3fileName compltionBlock:(void (^)())mp3DownloadFinished{
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    // required
    request.bucketName = kDWDBucketName;
    request.objectKey = mp3fileName;
    
    NSString * mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3fileName];
    request.downloadToFileURL = [NSURL fileURLWithPath:mp3FilePath];
    
    //optional
    //    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
    //        DWDLog(@"%lld, %lld, %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    //    };
    // NSString * docDir = [self getDocumentDirectory];
    // request.downloadToFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"downloadfile"]];
    
    
    OSSTask * getTask = [client getObject:request];
    
    [getTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            DWDLog(@"下载mp3文件成功!");
            // 下载成功  通知聊天控制器
            mp3DownloadFinished();
            
        } else {
            DWDLog(@"download object failed, error: %@" ,task.error);
        }
        return nil;
    }];
}

#pragma mark - 上传视频 add by fzg
- (void)uploadMP4AsyncWithFileName:(NSString *)mp4fileName success:(void (^)())successBlock Failed:(void (^)(NSError *))failedBlock
{
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    NSString *urlStr = [self getDownloadURLStringWithObjectName:mp4fileName];
    
    [self.putDict setObject:put forKey:urlStr];
    
    // required fields
    put.bucketName = kDWDBucketName;
    put.objectKey = mp4fileName;
    NSString * mp4FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder"] stringByAppendingPathComponent:mp4fileName];
    put.uploadingFileURL = [NSURL fileURLWithPath:mp4FilePath];
    
    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        DWDLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        DWDLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            
            DWDLog(@"upload mp4 object success!");
            successBlock();
            
        } else {
            
            DWDLog(@"upload object failed, error: %@" , task.error);
            failedBlock(task.error);
            
        }
        return nil;
    }];
    
}

- (void)downloadMp4ObjectAsyncWithObjecName:(NSString *)mp4fileName compltionBlock:(void (^)())mp3DownloadFinished
{
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    // required
    request.bucketName = kDWDBucketName;
    request.objectKey = mp4fileName;
    
    NSString * mp4FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/videoFolder/recive"] stringByAppendingPathComponent:mp4fileName];
    request.downloadToFileURL = [NSURL fileURLWithPath:mp4FilePath];
    
    //optional
    //    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
    //        DWDLog(@"%lld, %lld, %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    //    };
    // NSString * docDir = [self getDocumentDirectory];
    // request.downloadToFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"downloadfile"]];
    
    
    OSSTask * getTask = [client getObject:request];
    
    [getTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            DWDLog(@"下载mp4文件成功!");
            // 下载成功  通知聊天控制器
            mp3DownloadFinished();
            
        } else {
            DWDLog(@"download object failed, error: %@" ,task.error);
        }
        return nil;
    }];
}


- (NSString *)get_filename:(NSString *)name
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
            stringByAppendingPathComponent:name];
}

- (BOOL)is_file_exist:(NSString *)name
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:[self get_filename:name]];
}

/** 移除上传操作*/
- (void)cancelAndRemovePutOperationWithURLString:(NSString *)urlString{
    
    OSSPutObjectRequest *put = [self.putDict objectForKey:urlString];
    
    [put cancel];
    
    [self.putDict removeObjectForKey:urlString];
}

- (void)removeAllPutOperation{
    NSArray *puts = [self.putDict allValues];
    
    for (OSSPutObjectRequest *put in puts) {
        [put cancel];
    }
    
    [self.putDict removeAllObjects];
}

@end
