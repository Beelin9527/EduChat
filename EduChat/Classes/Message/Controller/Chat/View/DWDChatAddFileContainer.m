//
//  DWDChatAddFileContainer.m
//  EduChat
//
//  Created by Superman on 16/6/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatAddFileContainer.h"
#import <JFImagePickerController.h>
#import "KKAlbumsListController.h"

#import "DWDChatMsgClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDChatClient.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageTimerManager.h"

#import "DWDChatController.h"

#import "DWDTimeChatMsg.h"

#import <Masonry.h>
#import <YYModel.h>
@import Photos;

@interface DWDChatAddFileContainer() <JFImagePickerDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate , KKAlbumsListControllerDelegate>
@property (nonatomic , strong) DWDChatMsgClient *chatMsgClient;
@property (nonatomic , strong) UIView *topSeperator;
@property (nonatomic , strong) NSMutableArray *imageModelCach;

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic , weak) UINavigationController *imagePikerNav;

@end

@implementation DWDChatAddFileContainer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpSubViews];
        [self setUpConstraints];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setUpSubViews];
    [self setUpConstraints];
}

- (void)setUpSubViews{
    [self addSubview:self.photoBtn];
    [self addSubview:self.takeImageBtn];
    [self addSubview:self.videoBtn];
    [self addSubview:self.topSeperator];
}

- (void)setUpConstraints{
    [_photoBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).offset(20);
        make.top.equalTo(self.top).offset(20);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [_takeImageBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_photoBtn.right).offset(40);
        make.top.equalTo(self.top).offset(20);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [_videoBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_takeImageBtn.right).offset(40);
        make.top.equalTo(self.top).offset(20);
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
    [_topSeperator makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.top.equalTo(self.top);
        make.width.equalTo(self.width);
        make.height.equalTo(@0.5);
    }];
}


#pragma mark - <events>
- (void)photoClick:(UIButton *)btn{
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:_chatVc authorized:^{
//        JFImagePickerController *imgPickerController = [[JFImagePickerController alloc] initWithRootViewController:_chatVc];
//        imgPickerController.pickerDelegate = self;
        
        KKAlbumsListController *albemVc = [[KKAlbumsListController alloc] initWithMaxCount:9];
        albemVc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:albemVc];
        navi.navigationItem.backBarButtonItem.title = @"all albums";
        _imagePikerNav = navi;
        [_chatVc presentViewController:navi animated:YES completion:nil];
        
    }];
}

- (void)takeImageClick:(UIButton *)btn{
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeCamera withController:_chatVc authorized:^{
        UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.delegate = self;
        
        imgPickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        [self.chatVc presentViewController:imgPickerController animated:YES completion:nil];
    }];
}

- (void)videoClick:(UIButton *)btn{
//    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeCamera withController:_chatVc authorized:^{
    [[DWDPrivacyManager shareManger] VideoRecordPrivacyWithController:_chatVc authorized:^{
        [self.addFileDelegate videoBtnClick];
        
        [self.chatVc.view addSubview:self.videoRecordView];
        [self.videoRecordView showVideoRecordViewWithCompletionHandler:^(NSString *mp4FileName, UIImage *thumbImage) {
            
            DWDVideoChatMsg *needSaveMsg = [self.chatMsgClient creatVideoMsgFrom:[DWDCustInfo shared].custId to:self.toUserId observe:self mp4FileName:mp4FileName chatType:self.chatType];
            
            [self.imageModelCach addObject:needSaveMsg];
            
            [self saveMessageToDBWithMessage:needSaveMsg];
            
            [self.addFileDelegate videoRecordCompleteWithMsg:needSaveMsg ThumbImage:thumbImage];
            
            // 发送消息, 40s后判断超时时间
            [[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict setObject:@{@"content" : [needSaveMsg yy_modelToJSONString], @"chatType" : @(_chatType) , @"toUser" : _toUserId} forKey:needSaveMsg.msgId];// 缓存消息内容
            DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
            
            NSTimer *timer = [NSTimer timerWithTimeInterval:40 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : needSaveMsg.msgId , @"toId" : _toUserId , @"chatType" : @(_chatType)} repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; // 加入主运行循环
            
            [timerManager.timerCachDict setObject:timer forKey:needSaveMsg.msgId];  // 缓存超时定时器
            
        }];
        
        self.chatVc.tableViewToBottom.constant = self.videoRecordView.h;
    }];
    
}

- (void)sendImage:(UIImage *)image{
    DWDImageChatMsg *imageMsg = [self.chatMsgClient creatImageMsgFrom:[DWDCustInfo shared].custId to:self.toUserId observe:self.chatVc chatType:self.chatType];
    
    DWDPhotoMetaModel *photoModel = [[DWDPhotoMetaModel alloc] init];
    photoModel.width = image.size.width;
    photoModel.height = image.size.height;
    photoModel.photoKey = imageMsg.fileKey;
    
    imageMsg.photo = photoModel;
    
    [self.imageModelCach addObject:imageMsg];
    
    image = [image fixOrientation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *compressedImage = [image renderAtSize:[imageMsg.photo chatThumbSize]];  // 缩略
        // 处理高清图

        // 发送消息, 40s后判断超时时间
        
        [self saveMessageToDBWithMessage:imageMsg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.addFileDelegate chatAddFileContainerDidTakePictureFromCameraWithMsg:[NSArray arrayWithObject:imageMsg]];
        });
        
        [[SDImageCache sharedImageCache] storeImage:compressedImage forKey:[imageMsg.photo chatThumbPhotoKey] toDisk:YES]; // 存缩略
        [[SDImageCache sharedImageCache] storeImage:image forKey:[imageMsg.fileKey imgKey] toDisk:YES]; // 存高清
        
        [[SDImageCache sharedImageCache] diskImageExistsWithKey:[imageMsg.fileKey imgKey] completion:^(BOOL isInCache) {
            
            if (isInCache) {
                [self uploadImageToAliyunWithImageMsg:imageMsg]; // 上传高清
            }
        }];
        
    });
    
    DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:300 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : imageMsg.msgId , @"toId" : _toUserId , @"chatType" : @(_chatType)} repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]; // 加入主运行循环
    
    [timerManager.timerCachDict setObject:timer forKey:imageMsg.msgId];  // 缓存超时定时器
    
}

#pragma mark - image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    DWDImageChatMsg *imageMsg = [self.chatMsgClient creatImageMsgFrom:[DWDCustInfo shared].custId to:self.toUserId observe:self.chatVc chatType:self.chatType];
    
    DWDPhotoMetaModel *photoModel = [[DWDPhotoMetaModel alloc] init];
    photoModel.width = image.size.width;
    photoModel.height = image.size.height;
    photoModel.photoKey = imageMsg.fileKey;
    imageMsg.photo = photoModel;
    
    [self.imageModelCach addObject:imageMsg];
    
    image = [image fixOrientation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *compressedImage = [image renderAtSize:[imageMsg.photo chatThumbSize]];  // 缩略
        // 处理高清图
        
        // 发送消息, 40s后判断超时时间
        
        [self saveMessageToDBWithMessage:imageMsg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.addFileDelegate chatAddFileContainerDidTakePictureFromCameraWithMsg:[NSArray arrayWithObject:imageMsg]];
        });
        
        [[SDImageCache sharedImageCache] storeImage:compressedImage forKey:[imageMsg.photo chatThumbPhotoKey] toDisk:YES]; // 存缩略
        [[SDImageCache sharedImageCache] storeImage:image forKey:[imageMsg.fileKey imgKey] toDisk:YES]; // 存高清
        
        [[SDImageCache sharedImageCache] diskImageExistsWithKey:[imageMsg.fileKey imgKey] completion:^(BOOL isInCache) {
            
            if (isInCache) {
                [self uploadImageToAliyunWithImageMsg:imageMsg]; // 上传高清
            }
        }];
        
    });
    
    DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:300 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : imageMsg.msgId , @"toId" : _toUserId , @"chatType" : @(_chatType)} repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]; // 加入主运行循环
    
    [timerManager.timerCachDict setObject:timer forKey:imageMsg.msgId];  // 缓存超时定时器
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array{
    
    [_imagePikerNav dismissViewControllerAnimated:YES completion:nil];
    
    for (int i = 0; i < array.count; i++) {
        PHAsset *asset = array[i];
        
        DWDImageChatMsg *imageMsg = [self.chatMsgClient creatImageMsgFrom:[DWDCustInfo shared].custId to:self.toUserId observe:self.chatVc chatType:self.chatType];;
        
        // 发送消息, 300s后判断超时时间
        
        DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:300 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : imageMsg.msgId , @"toId" : _toUserId , @"chatType" : @(_chatType)} repeats:NO];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]; // 加入主运行循环
        
        [timerManager.timerCachDict setObject:timer forKey:imageMsg.msgId];  // 缓存超时定时器
        
        [self saveLocalAssetToSandBox:asset urlStr:imageMsg.fileKey completion:^(UIImage *image , BOOL success) {
            if (success) {
                DWDPhotoMetaModel *photoModel = [[DWDPhotoMetaModel alloc] init];
                photoModel.width = image.size.width;
                photoModel.height = image.size.height;
                photoModel.photoKey = imageMsg.fileKey;
                imageMsg.photo = photoModel;
                
                [self.imageModelCach addObject:imageMsg];  // 先保证不销毁
                
                UIImage *compressedImage;
                // 压缩原图尺寸
                compressedImage = [image renderAtSize:[imageMsg.photo chatThumbSize]];
                
                [self.addFileDelegate chatAddFileContainerDidStoreImageToDiskWithMsg:[NSArray arrayWithObject:imageMsg] placeHolderImage:nil];
                
                
                [[SDImageCache sharedImageCache] storeImage:compressedImage forKey:[imageMsg.photo chatThumbPhotoKey] toDisk:YES]; // 存缩略图
                
                [self saveMessageToDBWithMessage:imageMsg];
                
                [self uploadImageToAliyunWithImageMsg:imageMsg]; // 上传阿里云
                
            }
        }];
    }
}

//存储PHAsset到本地
- (void)saveLocalAssetToSandBox:(PHAsset *)asset urlStr:(NSString *)urlString completion:(void (^)(UIImage *image , BOOL success))completion {
    //用PHAsset处理以及本地图片存储过程
    //PHAsset转化成图片 图片大小自定义
    PHImageRequestOptions *opt = [PHImageRequestOptions new];
    opt.resizeMode = PHImageRequestOptionsResizeModeExact;
    opt.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:(CGSize){asset.pixelWidth, asset.pixelHeight}
                                contentMode:PHImageContentModeAspectFit
                                    options:opt
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  [[SDImageCache sharedImageCache] storeImage:result forKey:[urlString imgKey] toDisk:YES];
                                  //block
                                  [[SDImageCache sharedImageCache] diskImageExistsWithKey:[urlString imgKey] completion:^(BOOL isInCache) {
                                      completion(result,isInCache);
                                  }];
                              }];
    //用sdwebImage存储到本地
}

#pragma mark - <JFImagePickerControllerDelegate>
/** 选择照片 */
- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    
    NSArray *images = [picker imagesWithType:ASSET_PHOTO_FULL_RESOLUTION];  // 取出所有的高清图
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [JFImagePickerController clear];
    
    for (int i = 0; i < images.count; i++) {
        
        UIImage *image = images[i]; // 高清图
        
        DWDImageChatMsg *imageMsg = [self.chatMsgClient creatImageMsgFrom:[DWDCustInfo shared].custId to:self.toUserId observe:self.chatVc chatType:self.chatType];;
        
        DWDPhotoMetaModel *photoModel = [[DWDPhotoMetaModel alloc] init];
        photoModel.width = image.size.width;
        photoModel.height = image.size.height;
        photoModel.photoKey = imageMsg.fileKey;
        
        imageMsg.photo = photoModel;
        
        [self.imageModelCach addObject:imageMsg];  // 先保证不销毁
        
        // 发送消息, 300s后判断超时时间
        
        DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:300 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : imageMsg.msgId , @"toId" : _toUserId , @"chatType" : @(_chatType)} repeats:NO];
        
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode]; // 加入主运行循环
        
        [timerManager.timerCachDict setObject:timer forKey:imageMsg.msgId];  // 缓存超时定时器
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *compressedImage;
            // 压缩原图尺寸
            compressedImage = [image renderAtSize:[imageMsg.photo chatThumbSize]];
            
            [self.addFileDelegate chatAddFileContainerDidStoreImageToDiskWithMsg:[NSArray arrayWithObject:imageMsg] placeHolderImage:nil];
            
            
            [[SDImageCache sharedImageCache] storeImage:compressedImage forKey:[imageMsg.photo chatThumbPhotoKey] toDisk:YES]; // 存缩略图
            
            
            [self saveMessageToDBWithMessage:imageMsg];
            
            __block UIImage *fixOrientationFullImage = [image fixOrientation];  // 高清
            
            NSData *fullImageData = [NSData new];
            
            fullImageData = UIImageJPEGRepresentation(fixOrientationFullImage, 1.0);
            
            [[SDImageCache sharedImageCache] storeImageDataToDisk:fullImageData forKey:[imageMsg.fileKey imgKey]];  // 存高清原图
            
            [[SDImageCache sharedImageCache] diskImageExistsWithKey:[imageMsg.fileKey imgKey] completion:^(BOOL isInCache) {  // 上传高清即可
                if (isInCache) {  // 释放内存
                    fixOrientationFullImage = nil;
                }
                
                [self uploadImageToAliyunWithImageMsg:imageMsg];
                
            }];
        });
        
    }
    
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
    [JFImagePickerController clear];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <共有方法>
- (void)uploadVideoWithMsg:(DWDVideoChatMsg *)msg thumbImage:(UIImage *)image{
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:[msg.fileKey stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"] progressBlock:^(CGFloat progress) {
        
    } success:^{
        
        [[DWDAliyunManager sharedAliyunManager] uploadMP4AsyncWithFileName:msg.fileKey success:^{
            
            if (self.chatType == DWDChatTypeGroup || self.chatType == DWDChatTypeClass) {
                [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeVideoForO2M:msg]];// 群聊
            }else{
                [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeVideoForO2O:msg]];// 单聊
            }
            
            [self.imageModelCach removeObject:msg];
            
        } Failed:^(NSError *error) {
            
        }];
        
    } Failed:^(NSError *error) {
        
    }];
}

- (void)uploadImageToAliyunWithImageMsg:(DWDImageChatMsg *)imageMsg{
    [[DWDAliyunManager sharedAliyunManager] uploadChatImageWithImageName:imageMsg.fileName progressBlock:^(CGFloat progress) {
        // 进度
        DWDLog(@"上传图片进度 : %f" , progress);
    } success:^{
        DWDLog(@"上传图片成功!!!!");
        
        [self.imageModelCach removeObject:imageMsg];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.chatType == DWDChatTypeClass || self.chatType == DWDChatTypeGroup) {
                [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeImageForO2M:imageMsg]];  // 发图片消息到服务器
            }else{
                [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeImageForO2O:imageMsg]];
            }
        });
        
        // 移除上传操作缓存
        [[DWDAliyunManager sharedAliyunManager] cancelAndRemovePutOperationWithURLString:imageMsg.fileKey];
        
    } Failed:^(NSError *error) {
        
        imageMsg.state = DWDChatMsgStateError;
        
        if (![[error localizedDescription] isEqualToString:@"cancelled"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DWDProgressHUD showText:@"发送图片失败" afterDelay:1.0];
            });
            
        }
        imageMsg.state = DWDChatMsgStateError;  // 发送失败  更新UI
        
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateMsgStateToState:DWDChatMsgStateError WithMsgId:imageMsg.msgId toUserId:_toUserId chatType:self.chatType success:^{
            DWDLog(@"上传失败 ,更新消息状态为失败");
            
            [self.addFileDelegate chatAddFileContainerUploadImageFailureWithMsg:imageMsg];
            
        } failure:^(NSError *error) {
            
        }];
        
    }];
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
                // 发通知 刷新会话控制器 (不用再发通知 , 凡是pop回去msgVc都会整体数据库加载)
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"update_tb_recentChatList_success" object:nil];
            } failure:^{
                
            }];
        }
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

#pragma mark - <getters>

- (DWDFileContainerButton *)photoBtn{
    if (!_photoBtn) {
        UIImage *image = [UIImage imageNamed:@"ic_image_class_dialogue_pages_normal"];
        NSString *str = NSLocalizedString(@"photo", nil);
        _photoBtn = [DWDFileContainerButton buttonWithImage:image title:str];
        [_photoBtn setTitle:str forState:UIControlStateNormal];
        [_photoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_photoBtn.titleLabel setFont:DWDFontContent];
        [_photoBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_photoBtn addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (DWDFileContainerButton *)takeImageBtn{
    if (!_takeImageBtn) {
        UIImage *image = [UIImage imageNamed:@"ic_shooting_class_chat_normal"];
        NSString *str = NSLocalizedString(@"TakeImg", nil);
        _takeImageBtn = [DWDFileContainerButton buttonWithImage:image title:str];
        [_takeImageBtn setImage:[UIImage imageNamed:@"ic_shooting_class_chat_press"] forState:UIControlStateHighlighted];
        [_takeImageBtn setTitle:str forState:UIControlStateNormal];
        [_takeImageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_takeImageBtn.titleLabel setFont:DWDFontContent];
        [_takeImageBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_takeImageBtn addTarget:self action:@selector(takeImageClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takeImageBtn;
}

- (DWDFileContainerButton *)videoBtn{
    if (!_videoBtn) {
        UIImage *image = [UIImage imageNamed:@"ic_small_video_class_dialogue_pages_normal"];
        NSString *str = NSLocalizedString(@"Video", nil);
        _videoBtn = [DWDFileContainerButton buttonWithImage:image title:str];
        [_videoBtn setTitle:str forState:UIControlStateNormal];
        [_videoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_videoBtn.titleLabel setFont:DWDFontContent];
        [_videoBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_videoBtn addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}

- (UIView *)topSeperator{
    if (!_topSeperator) {
        _topSeperator = [UIView new];
        _topSeperator.backgroundColor = DWDRGBColor(231, 231, 231);
    }
    return _topSeperator;
}

- (DWDChatMsgClient *)chatMsgClient{
    if (!_chatMsgClient) {
        _chatMsgClient = [[DWDChatMsgClient alloc] init];
    }
    return _chatMsgClient;
}

- (DWDVideoRecordView *)videoRecordView
{
    if (!_videoRecordView) {
        _videoRecordView = [[DWDVideoRecordView alloc] init];
        WEAKSELF;
        [_videoRecordView setDissmisBlock:^{
            weakSelf.chatVc.tableViewToBottom.constant = DWDToolBarHeight;
        }];
    }
    return _videoRecordView;
}

- (NSMutableArray *)imageModelCach{
    if (!_imageModelCach) {
        _imageModelCach = [NSMutableArray array];
    }
    return _imageModelCach;
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        PHCachingImageManager *imageManager = [PHCachingImageManager new];
        //        imageManager.allowsCachingHighQualityImages = NO;
        _imageManager = imageManager;
    }
    return _imageManager;
}
@end
