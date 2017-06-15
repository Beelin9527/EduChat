//
//  DWDChatAddFileContainer.h
//  EduChat
//
//  Created by Superman on 16/6/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDImageChatMsg.h"
#import "DWDVideoChatMsg.h"
#import "DWDFileContainerButton.h"
#import "DWDVideoRecordView.h"

@class DWDChatController;

@protocol DWDChatAddFileContainerDelegate <NSObject>

@required
- (void)chatAddFileContainerDidStoreImageToDiskWithMsg:(NSArray *)msgs placeHolderImage:(UIImage *)placeHolderImage;
- (void)chatAddFileContainerUploadImageFailureWithMsg:(DWDImageChatMsg *)imageMsg;

- (void)chatAddFileContainerDidTakePictureFromCameraWithMsg:(NSArray *)msgs;

- (void)videoBtnClick;
- (void)videoRecordCompleteWithMsg:(DWDVideoChatMsg *)videoMsg ThumbImage:(UIImage *)thumbImage;
@end

@interface DWDChatAddFileContainer : UIScrollView
@property (nonatomic , strong) DWDFileContainerButton *photoBtn;
@property (nonatomic , strong) DWDFileContainerButton *takeImageBtn;
@property (nonatomic , strong) DWDFileContainerButton *videoBtn;
@property (nonatomic , weak) DWDChatController *chatVc;
@property (nonatomic , assign) DWDChatType chatType;
@property (nonatomic , strong) NSNumber *toUserId;

@property (nonatomic , strong) DWDVideoRecordView *videoRecordView;

@property (nonatomic , weak) id<DWDChatAddFileContainerDelegate> addFileDelegate;

- (void)uploadVideoWithMsg:(DWDVideoChatMsg *)msg thumbImage:(UIImage *)image;
- (void)uploadImageToAliyunWithImageMsg:(DWDImageChatMsg *)imageMsg;

- (void)sendImage:(UIImage *)image;
@end
