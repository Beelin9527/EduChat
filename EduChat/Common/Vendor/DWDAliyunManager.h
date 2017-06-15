//
//  DWDAliyunManager.h
//  EduChat
//
//  Created by Superman on 16/1/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"
#import <AliyunOSSiOS/OSSService.h>
#import "NSString+extend.h"

@class PHAsset;

@interface DWDAliyunManager : NSObject
DWDSingletonH(AliyunManager);


// 上传图片  异步
- (void)uploadImage:(UIImage *)image Name:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock;

// 根据图片名称 (web url) 异步上传聊天图片
- (void)uploadChatImageWithImageName:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock;

// 上传图片  同步
- (void)syncUploadImage:(UIImage *)image Name:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock;

/* 
 上传图片 根据图片路径
 PHAsset 专用
 压缩图片 以及存储图片到本地的操作
 在上一步进行
 */
- (void)asyncUploadImageWithUUID:(NSString *)uuid progressBlock:(void (^)(CGFloat progress))progressFinished success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock;


// 下载图片
- (void)downloadImageWithName:(NSString *)name progressBlock:(void (^)(CGFloat progress))progressFinished completionBlock:(void (^)(UIImage *downloadImage))completion Failed:(void(^)(NSError *error))failedBlock;

// 音频
- (void)uploadMP3AsyncWithFileName:(NSString *)mp3fileName success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock;

- (void)downloadMp3ObjectAsyncWithObjecName:(NSString *)mp3fileName compltionBlock:(void (^)())mp3DownloadFinished;

/**
 *  上传视频 异步
 *
 *  @param mp4fileName  文件名
 *  @param successBlock 成功回调
 *  @param failedBlock  失败回调
 */
- (void)uploadMP4AsyncWithFileName:(NSString *)mp4fileName  success:(void (^)())successBlock Failed:(void(^)(NSError *error))failedBlock;

/**
 *  下载视频 异步
 *
 *  @param mp4fileName         文件名
 *  @param mp3DownloadFinished 完成回调
 */
- (void)downloadMp4ObjectAsyncWithObjecName:(NSString *)mp4fileName compltionBlock:(void (^)())mp3DownloadFinished;


// 获取公开URL
- (NSString *)getDownloadURLStringWithObjectName:(NSString *)objectName;

/** 移除上传操作*/
- (void)cancelAndRemovePutOperationWithURLString:(NSString *)urlString;
- (void)removeAllPutOperation;

/** 获取文件在沙盒中的路径 */
- (NSString *)get_filename:(NSString *)name;

/** 判断某个名字的文件是否存在于沙盒 */
- (BOOL)is_file_exist:(NSString *)name;
@end
