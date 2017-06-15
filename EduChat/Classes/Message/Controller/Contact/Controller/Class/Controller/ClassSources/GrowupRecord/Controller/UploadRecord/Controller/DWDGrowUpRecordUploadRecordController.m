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

@property (nonatomic , strong) NSMutableArray *imageNames;

@end

@implementation DWDGrowUpRecordUploadRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DWDRGBColor(245, 245, 245);
    [_topTextView becomeFirstResponder];
    _topTextView.delegate = self;
    self.title = @"上传";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnClick)];
    [self.navigationItem.rightBarButtonItem setEnabled:self.arrSelectImgs.count > 0 ? YES : NO];
    
    
    
    [self setUpMidContainer];
    [self setUpBottomContainer];
}

- (NSMutableArray *)imageNames{
    if (!_imageNames) {
        _imageNames = [NSMutableArray array];
    }
    return _imageNames;
}

- (void)rightBarBtnClick{
    DWDLogFunc;
    [self.view endEditing:YES];
    if (self.arrSelectImgs.count > 0) {
        // 发送请求,上传图片,传数据到上一个控制器
        // 1. 先上传图片(需要阻塞)
        for (int i = 0; i < self.arrSelectImgs.count; i++) {
            UIImage *image = self.arrSelectImgs[i];
            NSString *imageName = DWDUUID;
            NSString *imageUrlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:imageName];
            DWDLog(@" image url str : %@ ", imageUrlStr);
            
            [[DWDAliyunManager sharedAliyunManager] syncUploadImage:image Name:imageName progressBlock:^(CGFloat progress) {
                
            } success:^{
                
                [self.imageNames addObject:imageUrlStr];
                
                if (i == self.arrSelectImgs.count - 1) {  // 2.最后一张也上传成功 , 发送名称数组到服务器
                    NSDictionary *params;
                    if (_topTextView.text.length > 0) {
                        params = @{@"custId" : [DWDCustInfo shared].custId,
                                   @"albumId" : [NSNumber numberWithLongLong:_myClassAlbumId],
                                   @"content" : _topTextView.text,
                                   @"photos" : self.imageNames}; // string数组;
                    }else{
                        params = @{@"custId" : [DWDCustInfo shared].custId,
                                   @"albumId" : [NSNumber numberWithLongLong:_myClassAlbumId],
                                   @"photos" : self.imageNames};
                    }
                    [[HttpClient sharedClient] postApi:@"AlbumRestService/addEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                        DWDLog(@"上传成功!发送动态到服务器成功");
                        // 通知代理
                        if ([self.rightBarBtnDelegate respondsToSelector:@selector(DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:text:)]) {
                            [self.rightBarBtnDelegate DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:self.imageNames text:_topTextView.text];
                        }
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.labelText = @"上传相册记录失败了!请重试";
                        [hud show:YES];
                        [hud hide:YES afterDelay:1.5];
                    }];
                }
            } Failed:^(NSError *error) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"上传相册记录失败了!请重试";
                [hud show:YES];
                [hud hide:YES afterDelay:1.5];
            }];
        }
        
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"你还没有选择图片,请至少选择一张";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5];
    }
}

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
            imageView.image = self.arrSelectImgs[i];
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

#import <JFImagePicker/JFAssetHelper.h>

#pragma makr - <JFImagePickerDelegate>
- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    
    [self.arrSelectImgs removeAllObjects];
    
    //    __weak DWDClassSourceGrowupRecordViewController *weakSelf = self;
    
    for ( ALAsset *asset in picker.assets) {
        
        // ASSET_PHOTO_ASPECT_THUMBNAIL(挤压高清)  ASSET_PHOTO_THUMBNAIL(等比模糊缩略)  ASSET_PHOTO_FULL_RESOLUTION  ASSET_PHOTO_SCREEN_SIZE
        
        UIImage *image = [[JFAssetHelper sharedAssetHelper] getImageFromAsset:asset type:ASSET_PHOTO_THUMBNAIL];
        
        [self.arrSelectImgs addObject:image];
    }
    
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
    return YES;
}
@end
