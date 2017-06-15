//
//  DWDPhotosHelper.m
//  EduChat
//
//  Created by KKK on 16/9/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPhotosHelper.h"

#import "DWDAliyunManager.h"

#import <SDImageCache.h>

@interface DWDPhotosHelper ()
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end

@implementation DWDPhotosHelper

#pragma mark - Public Method
+ (instancetype)defaultHelper {
    static DWDPhotosHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[DWDPhotosHelper alloc] init];
    });
    return helper;
}

- (void)uploadPhotosWithPhotosArray:(NSArray<PHAsset *> *)photos
                         completion:(void (^)(NSArray *photoNames, BOOL success))completionBlock {
    /*
     可以拿到每个图的PHAsset,拿到尺寸 大小 方向,根据情况对图片进行操作
     最后得到两张(一张高清,一张模糊,url用图片类获取)图存到本地,生成ID
     */
    
    if (photos.count == 0) {
        completionBlock([NSArray array], YES);
        return;
    }
    
    
    dispatch_group_t uploadImageGroup = dispatch_group_create();
    
    __block BOOL uploadSuccess = YES;
    NSMutableArray *photoNamesArray = [NSMutableArray array];
    
    for (PHAsset *asset in photos) {
        dispatch_group_enter(uploadImageGroup);
        NSString *uuid = DWDUUID;
        NSString *url = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:uuid];
        [photoNamesArray addObject:url];
        //保存asset到本地
        [self saveLocalAssetToSandBox:asset urlStr:url completion:^(BOOL success) {
            if (success) {
                //保存成功上传到阿里云
                [[DWDAliyunManager sharedAliyunManager] asyncUploadImageWithUUID:uuid progressBlock:^(CGFloat progress) {
                    DWDLog(@"progress:%f of uuid:%@", progress, uuid);
                } success:^{
                    //上传成功
                    dispatch_group_leave(uploadImageGroup);
                } Failed:^(NSError *error) {
                    //上传失败
                    //标示失败
                    uploadSuccess = NO;
                    dispatch_group_leave(uploadImageGroup);
                }];
            } else {
                //保存失败直接gg
                uploadSuccess = NO;
                dispatch_group_leave(uploadImageGroup);
            }
        }];
        if (uploadSuccess == NO) {
            break;
        }
    }
    
    dispatch_group_notify(uploadImageGroup, dispatch_get_main_queue(), ^{
        completionBlock(photoNamesArray, uploadSuccess);
    });
    
}

//把相机照片转化成PHasset
- (void)SaveCaptureImageInfo:(NSDictionary *)info completion:(void (^)(PHAsset *asset, BOOL success,  NSError *error))completionBlock {
    __block PHObjectPlaceholder *placeHolder;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
        placeHolder = request.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError *error) {
        PHFetchResult *assetResult;
        if (success) {
            assetResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[placeHolder.localIdentifier] options:nil];
        }
        completionBlock(assetResult.firstObject, success, error);
    }];
}

//存储PHAsset到本地
- (void)saveLocalAssetToSandBox:(PHAsset *)asset urlStr:(NSString *)urlString completion:(void (^)(BOOL success))completion {
    //用PHAsset处理以及本地图片存储过程
    //PHAsset转化成图片 图片大小自定义
    PHImageRequestOptions *opt = [PHImageRequestOptions new];
    opt.resizeMode = PHImageRequestOptionsResizeModeExact;
    opt.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [self.imageManager requestImageForAsset:asset
                                 targetSize:[self fitSizeWithOriginSize:(CGSize){asset.pixelWidth, asset.pixelHeight}]
                                contentMode:PHImageContentModeAspectFit
                                    options:opt
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  [[SDImageCache sharedImageCache] storeImage:result forKey:[urlString imgKey] toDisk:YES];
                                  //block
                                  [[SDImageCache sharedImageCache] diskImageExistsWithKey:[urlString imgKey] completion:^(BOOL isInCache) {
                                      completion(isInCache);
                                  }];
                              }];
    //用sdwebImage存储到本地
}


#pragma mark - Private Method

- (CGSize)fitSizeWithOriginSize:(CGSize)originSize {
    CGSize newSize = originSize;
    //图片上传规则
    /*
     高 > 宽
     
     if (宽 > 屏幕宽) {
     
        新高 = 屏幕宽 / 宽 * 高
        新宽 = 屏幕宽
     } else {
     //宽 < 屏幕宽度
        if (高 > 屏幕高) {
            if (高 > 2个屏幕高) {
                不变
            } else {
                新高 = 屏幕高
                新宽 = 屏幕高 / 高 * 宽
            }
        } else {
            //高 < 屏幕高
            //宽 < 屏幕宽
     
            不变
        }
     }
     */
    /*
     宽 > 高
     if (高 > 屏幕高) //不可能
     
     if (宽 > 屏幕宽) {
        让新宽 = 屏幕宽度
        新高 = 屏幕宽度 / 宽 * 高
     } else {
        //宽 < 屏幕宽
        //隐藏条件 高 < 屏幕高
        原图显示
     }
     */
    
    if (originSize.height > originSize.width) {
        if (originSize.width > DWDScreenW) {
            newSize.height = DWDScreenW / originSize.width * originSize.height;
            newSize.width = DWDScreenW;
        } else {
            //宽 < 屏幕宽度
            if (originSize.height > DWDScreenH) {
                if (originSize.height > 2 * DWDScreenH) {
                    //不变
                } else {
                    newSize.height = DWDScreenH;
                    newSize.width = DWDScreenH / originSize.height * originSize.width;
                }
            } else {
                //高 < 屏幕高
                //宽 < 屏幕宽
                //不变
            }
        }
    } else {
//        if (originSize.height > DWDScreenH) //不可能
            if (originSize.width > DWDScreenW) {
                newSize.width = DWDScreenW;
                newSize.height = DWDScreenW / originSize.width * originSize.height;
            } else {
                //宽 < 屏幕宽
                //隐藏条件 高 < 屏幕高
//                原图显示
            }
       
    }
    
    newSize.width *= 2;
    newSize.height *= 2;
    
    return newSize;
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
