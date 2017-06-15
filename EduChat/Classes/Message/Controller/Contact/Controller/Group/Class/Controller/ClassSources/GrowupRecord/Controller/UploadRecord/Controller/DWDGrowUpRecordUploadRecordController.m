//
//  DWDGrowUpRecordUploadRecordController.m
//  EduChat
//
//  Created by Superman on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGrowUpRecordUploadRecordController.h"
#import "DWDChooseAlbumViewController.h"

#import "DWDChooseAlbumModel.h"

#import "DWDPlaceholderTextView.h"

#import <Masonry.h>
#import "JFImagePickerController.h"

@interface DWDGrowUpRecordUploadRecordController () <UITextViewDelegate , JFImagePickerDelegate>
@property (weak, nonatomic) IBOutlet DWDPlaceholderTextView *topTextView;
@property (weak, nonatomic) IBOutlet UIView *midContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *midContainerHeightCons;
@property (nonatomic, strong) NSArray *photoMetaArray;

@property (nonatomic , strong) NSMutableArray *imageNames;
@property (weak, nonatomic) IBOutlet UIView *chooseAlbumContainer;

@end

@implementation DWDGrowUpRecordUploadRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DWDRGBColor(245, 245, 245);
    _topTextView.placeholder = @"请输入发布内容";
    _topTextView.delegate = self;
    
    self.title = @"上传";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnClick)];
    
    _chooseAlbumContainer.hidden = YES;
    
    [self setUpMidContainer];
    [self setUpBottomContainer];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.arrSelectImgs.count > 0 || _topTextView.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (NSMutableArray *)imageNames{
    if (!_imageNames) {
        _imageNames = [NSMutableArray array];
    }
    return _imageNames;
}

- (void)dealloc {
    DWDMarkLog(@"upload controller dealloc");
}

- (void)rightBarBtnClick{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    DWDLogFunc;
    [self.view endEditing:YES];
    [self.imageNames removeAllObjects];
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在上传...请稍候";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud show:YES];
    });
    NSMutableArray *photoMetaArray = [NSMutableArray array];
    self.photoMetaArray = photoMetaArray;
    
    dispatch_group_t groupGCD = dispatch_group_create();
    DWDMarkLog(@"Upload Start Upload Pics");
    __block BOOL allsuccess = YES;
    
    WEAKSELF;
    for (int i = 0; i < self.arrSelectImgs.count; i ++) {
        dispatch_group_enter(groupGCD);
        DWDMarkLog(@"Upload Pic:--%d--", i);
        UIImage *image = self.arrSelectImgs[i];
        NSString *imageName = DWDUUID;
        NSString *imageUrlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:imageName];
        DWDPhotoMetaModel *model = [DWDPhotoMetaModel new];
        model.width = image.size.width;
        model.height = image.size.height;
        model.photoKey = imageUrlStr;
        DWDMarkLog(@"photoKey:%@", imageUrlStr);
        
        [self.imageNames addObject:imageUrlStr];
        [photoMetaArray addObject:model];
        
        [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:imageName progressBlock:^(CGFloat progress) {
        } success:^{
            DWDMarkLog(@"Upload Pic:--%d-- Success", i);
            dispatch_group_leave(groupGCD);
        } Failed:^(NSError *error) {
            DWDMarkLog(@"Upload Pic:--%d-- Failed", i);
            dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [hud showText:@"上传失败" afterDelay:1.5f];
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            });
            allsuccess = NO;
            dispatch_group_leave(groupGCD);
        }];
        if (allsuccess == NO) {
            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            return;
        }
    }
    
    dispatch_group_notify(groupGCD, dispatch_get_main_queue(), ^{
        DWDMarkLog(@"Upload Pics End");
        if (photoMetaArray.count == weakSelf.arrSelectImgs.count) {
            //上传到服务器
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            if (weakSelf.topTextView.text.length) {
                [params setObject:weakSelf.topTextView.text forKey:@"content"];
            }
            if (weakSelf.imageNames.count) {
                [params setObject:weakSelf.imageNames forKey:@"photos"];
            }
            [params setObject:[DWDCustInfo shared].custId forKey:@"custId"];
            [params setObject:[NSNumber numberWithLongLong:weakSelf.myClassAlbumId] forKey:@"albumId"];
            
            weakSelf.arrSelectImgs = nil;
            [[HttpClient sharedClient] postApi:@"AlbumRestService/addEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                DWDLog(@"上传成功!发送动态到服务器成功");
                // 通知代理
                if ([weakSelf.rightBarBtnDelegate respondsToSelector:@selector(DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:text:logId:)]) {
                    [weakSelf.rightBarBtnDelegate DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:weakSelf.photoMetaArray text:_topTextView.text logId:responseObject[@"data"][@"logId"]];

                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud showText:@"上传成功" afterDelay:1.5f];
                    [JFImagePickerController clear];
                    if (weakSelf.rightBarBtnDelegate && [weakSelf.rightBarBtnDelegate respondsToSelector:@selector(growupRecordUploadControllerShouldRemoveImagesCache)]) {
                        [weakSelf.rightBarBtnDelegate growupRecordUploadControllerShouldRemoveImagesCache];
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud showText:[error localizedDescription] afterDelay:1.5f];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                });
            }];
            
        }
    });
   
//    if (self.arrSelectImgs.count > 0) {
//        
//        // 1. 先上传图片
//        for (int i = 0; i < self.arrSelectImgs.count; i++) {
//            
//            UIImage *image = self.arrSelectImgs[i];
//            NSString *imageName = DWDUUID;
//            NSString *imageUrlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:imageName];
//            
//            [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:imageName progressBlock:^(CGFloat progress) {
//            } success:^{
//                DWDPhotoMetaModel *model = [DWDPhotoMetaModel new];
//                model.width = image.size.width;
//                model.height = image.size.height;
//                model.photoKey = imageUrlStr;
//                
//                [self.imageNames addObject:imageUrlStr];
//                [photoMetaArray addObject:model];
//                
//                if (i == self.arrSelectImgs.count - 1) {  // 2.最后一张也上传成功 , 发送名称数组到服务器
//                    NSDictionary *params;
//                    if (_topTextView.text.length > 0) {
//                        params = @{@"custId" : [DWDCustInfo shared].custId,
//                                   @"albumId" : [NSNumber numberWithLongLong:_myClassAlbumId],
//                                   @"content" : _topTextView.text,
//                                   @"photos" : self.imageNames}; // string数组;
//                    }else{
//                        params = @{@"custId" : [DWDCustInfo shared].custId,
//                                   @"albumId" : [NSNumber numberWithLongLong:_myClassAlbumId],
//                                   @"photos" : self.imageNames};
//                    }
//                    DWDMarkLog(@"%@", self.imageNames);
//                    [self requestData:params hud:hud]; // 通知服务器 并隐藏Hud
//                }
//                
//                
//            } Failed:^(NSError *error) {
//                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
//                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
//            }];
//        }
//    }else{
//        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
//                                 @"albumId" : [NSNumber numberWithLongLong:_myClassAlbumId],
//                                 @"content" : _topTextView.text};
//        
//        [self requestData:params hud:hud];
//    }
}

//- (void)requestData:(NSDictionary *)params hud:(MBProgressHUD *)hud{
//    [[HttpClient sharedClient] postApi:@"AlbumRestService/addEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        DWDLog(@"上传成功!发送动态到服务器成功");
//        // 通知代理
//        if ([self.rightBarBtnDelegate respondsToSelector:@selector(DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:text:logId:)]) {
//            [self.rightBarBtnDelegate DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:self.photoMetaArray text:_topTextView.text logId:responseObject[@"data"][@"logId"]];
//        }
//        hud.labelText = @"上传成功!";
//        dispatch_async(dispatch_get_main_queue(), ^{
//        
//            [hud hide:YES afterDelay:1.0];
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.labelText = [error localizedDescription];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:NO];
//            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
//            [hud show:YES];
//            [hud hide:YES afterDelay:1.0];
//        });
//    }];
//}

- (void)setUpMidContainer{
    DWDLogFunc;
    [_midContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    DWDLog(@"%zd**********",self.arrSelectImgs.count);
    if (self.arrSelectImgs.count == 9) {
        CGFloat imageX;
        CGFloat imageY;
        CGFloat imageW = pxToW(160);
        CGFloat imageH = pxToH(160);
        int row;
        int col;
        int totleCol = 4;
        for (int i = 0; i < self.arrSelectImgs.count; i ++) {
            row = i / totleCol;
            col = i % totleCol;
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = self.arrSelectImgs[i];
            imageView.clipsToBounds = YES;
            [_midContainer addSubview:imageView];
            imageX = pxToW(20) + col * (imageW + pxToW(24));
            imageY = row * (imageH + pxToH(20));
            imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
            if (i == self.arrSelectImgs.count - 1) {
                self.midContainerHeightCons.constant = CGRectGetMaxY(imageView.frame) + pxToH(10);
            }
        }
    }else{
        for (int i = 0; i < self.arrSelectImgs.count + 1; i ++) {
            CGFloat imageX;
            CGFloat imageY;
            CGFloat imageW = pxToW(160);
            CGFloat imageH = pxToH(160);
            int row;
            int col;
            int totleCol = 4;
            row = i / totleCol;
            col = i % totleCol;
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            
            imageView.clipsToBounds = YES;
            [_midContainer addSubview:imageView];
            imageX = pxToW(20) + col * (imageW + pxToW(24));
            imageY = row * (imageH + pxToH(20));
            imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
            if (i == self.arrSelectImgs.count) {
                imageView.image = [UIImage imageNamed:@"btn_add_image_new_record_normal"];
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBtnTap:)]];
                self.midContainerHeightCons.constant = CGRectGetMaxY(imageView.frame) + pxToH(10);
            }else{
                imageView.image = self.arrSelectImgs[i];
            }
        }
    }
}

// 最后一张+号图片点击
- (void)addBtnTap:(UITapGestureRecognizer *)tap{
    
    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:nil];
    picker.pickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:UIKeyboardWillShowNotification]) {
////        dispatch_sync(dispatch_get_main_queue(), ^{
////        });
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.navigationController.navigationBar setHidden:NO];
//        });
//    }
//}

#import <JFImagePicker/JFAssetHelper.h>

#pragma mark - <JFImagePickerDelegate>
- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    
    [self.arrSelectImgs removeAllObjects];
    
    //    __weak DWDClassSourceGrowupRecordViewController *weakSelf = self;
    
    self.arrSelectImgs = [[picker imagesWithType:ASSET_PHOTO_SCREEN_SIZE] mutableCopy];
    
    [self setUpMidContainer];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUpBottomContainer{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBottomCell:)];
    [_bottomContainer addGestureRecognizer:tap];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)tapBottomCell:(UITapGestureRecognizer *)tap{
    
    DWDChooseAlbumViewController *chooseAlbumVc = [[DWDChooseAlbumViewController alloc] init];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        DWDChooseAlbumModel *chooseAlbumModel = [[DWDChooseAlbumModel alloc] init];
        chooseAlbumModel.name = [NSString stringWithFormat:@"%d",i];
        [arr addObject:chooseAlbumModel];
    }
    
    chooseAlbumVc.members = arr;
    [self.navigationController pushViewController:chooseAlbumVc animated:YES];
    DWDLogFunc;
}
#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [textView setNeedsDisplay];
    
    if (text.length == 0) { // 删除操作
        if (textView.text.length == range.length) { // 全删
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

@end
