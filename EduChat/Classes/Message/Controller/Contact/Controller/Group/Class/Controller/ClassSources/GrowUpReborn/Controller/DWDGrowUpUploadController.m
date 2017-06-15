//
//  DWDGrowUpUploadController.m
//  EduChat
//
//  Created by KKK on 16/9/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

@import Photos;
#import "DWDGrowUpUploadController.h"

#import "KKAlbumsListController.h"
#import "KKImagePreviewController.h"

#import "KKSelectImageView.h"

#import "DWDGrowUpModel.h"

#import "DWDPhotosHelper.h"

#import <YYTextView.h>

#define BlankErrorCode 7777
#define ViolationWordsCode 7778


@interface DWDGrowUpUploadController () <KKSelectImageViewDelegate, YYTextViewDelegate, KKAlbumsListControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) YYTextView *textView;
@property (nonatomic, weak) KKSelectImageView  *imagesView;


@property (nonatomic, strong) NSArray *photosArray;

@end

@implementation DWDGrowUpUploadController
#pragma mark - Public Method

- (instancetype)initWithPhotosArray:(NSArray<PHAsset *> *)photosArray {
    self = [super init];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.view.backgroundColor = DWDColorBackgroud;
    scrollView.backgroundColor = DWDColorBackgroud;
    scrollView.alwaysBounceVertical = YES;
//    scrollView.delaysContentTouches = NO;
//    scrollView.canCancelContentTouches = NO;
    scrollView.delegate = self;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
    if (photosArray != nil) {
        _photosArray = photosArray;
    }
    [self initSubViews];
    return self;
}
//
//#pragma mark - Life Cycle
//- (void)viewDidLoad {
//    [super viewDidLoad];
//}

#pragma mark - SubViews Layout
- (void)initSubViews {
    CGFloat textViewHeight = 150;
    
    YYTextView *textView = [[YYTextView alloc] initWithFrame:(CGRect){0, 20, DWDScreenW, textViewHeight}];
    textView.backgroundColor = [UIColor whiteColor];    
    textView.font = [UIFont systemFontOfSize:16];
    textView.placeholderFont = [UIFont systemFontOfSize:16];
//    textView.backgroundColor = [UIColor blueColor];
//    textView.delegate = self;
    textView.placeholderText = @"请输入发布内容";
    [_scrollView addSubview:textView];
    _textView = textView;
    
//    /********/
//    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//    numberToolbar.barStyle = UIBarStyleDefault;
//    numberToolbar.items = [NSArray arrayWithObjects:
//                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
//                           [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(textViewWillDone)],
//                           nil];
//    [numberToolbar sizeToFit];
//    textView.inputAccessoryView = numberToolbar;
//    
//    /*******/
    
    KKSelectImageView *imgsView = [[KKSelectImageView alloc] initWithFrame:(CGRect){0, textViewHeight + 40, DWDScreenW, 200}];
//    imgsView.backgroundColor = [UIColor redColor];
    imgsView.eventDelegate = self;
    [_scrollView addSubview:imgsView];
    _imagesView = imgsView;
    
    if (_photosArray != nil) {
        [_imagesView addImagesWithArray:_photosArray];
    }
    
    //rightBarButtonItem
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]
                                           initWithTitle:@"提交"
                                           style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(rightBarButtonItemDidClick)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - Event Response
- (void)rightBarButtonItemDidClick {
    //正确性验证
    NSError *error = [self checkCorrection];
    if ( error != nil) {
        //show error text
        [self showErrorHudWithString:error.domain];
        return;
    }
    
    //验证通过
    //post request
    WEAKSELF;
    MBProgressHUD *waitingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    waitingHud.labelText = @"正在上传";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[DWDPhotosHelper defaultHelper] uploadPhotosWithPhotosArray:_photosArray completion:^(NSArray *photoNames, BOOL success) {
        
        if (success) {
            //上传成功
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            if (weakSelf.textView.text.length) {
                [params setObject:weakSelf.textView.text forKey:@"content"];
            }
            if (photoNames.count) {
                [params setObject:photoNames forKey:@"photos"];
            }
            [params setObject:[DWDCustInfo shared].custId forKey:@"custId"];
            [params setObject:weakSelf.albumId forKey:@"albumId"];
            
            /**
             
             ##################################################################
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             ##################################################################
             
             
             
             上传时写错api,通知的api写成了这里的api
             
             已让后端在AlbumRestService/addEntity api中
             判断是否有字段值 type
             如果有字段值type,自动转移到 新增通知api
             
             此方法为无奈之举
             改动 通知 或者 新增成长记录参数时
             切记 切记
             */
            [[HttpClient sharedClient] postGrowUpRecordWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
                //上传成长记录成功
                [waitingHud hide:YES];
                [weakSelf showErrorHudWithString:@"上传成功"];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(growUpUploadController:didCompleteUploadWithRecord:)]) {
                    DWDGrowUpModel *model = [weakSelf createModelWithPhotoNames:photoNames logId:responseObject[@"data"][@"logId"]];
                    [weakSelf.delegate growUpUploadController:weakSelf didCompleteUploadWithRecord:model];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                DWDLog(@"上传成长记录成功");
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                //成功 破费
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [waitingHud hide:YES];
                //上传成长记录失败 服务器问题
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showErrorHudWithString:@"网络请求失败"];
                    weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                });
                DWDLog(@"上传成长记录成功失败,原因是:%@", error);
            }];
            
        } else {
            //上传失败
            //reason : 上传图片失败
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
                [waitingHud hide:YES afterDelay:1.0f];
                [weakSelf showErrorHudWithString:@"新增成长记录失败"];
            });
        }
    }];
}

#pragma mark - KKSelectImageViewDelegate
- (void)selectImageView:(KKSelectImageView *)view didClickAddImagesButtonWithMaxCount:(NSUInteger)maxCount {
    KKAlbumsListController *vc = [[KKAlbumsListController alloc] initWithMaxCount:(9 -_photosArray.count)];
    vc.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationItem.backBarButtonItem.title = @"所有相册";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:navi animated:YES completion:nil];
    });
}

- (void)selectImageViewDidChangedPhotosArray:(NSArray<PHAsset *> *)photosArray {
    _photosArray = photosArray;
}

#pragma mark - KKAlbumsListControllerDelegate
- (void)listControllerShouldCancel:(KKAlbumsListController *)listController {
    [listController dismissViewControllerAnimated:YES completion:nil];
}

- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array {
    [listController dismissViewControllerAnimated:YES completion:^{
        if (_imagesView && [_imagesView respondsToSelector:@selector(addImagesWithArray:)]) {
            [_imagesView addImagesWithArray:array];
        }
    }];
}

#pragma mark - Private Method
- (NSError *)checkCorrection {
    NSError *error = nil;
    
    if ([_textView.text trim].length == 0 && _photosArray.count == 0) {
        error = [NSError errorWithDomain:@"请输入内容" code:BlankErrorCode userInfo:nil];
    }
    
    return error;
}

- (void)showErrorHudWithString:(NSString *)string {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5f];
}

- (DWDGrowUpModel *)createModelWithPhotoNames:(NSArray *)photoNames logId:(NSNumber *)logId {
    //先建好数组 拼好图片数组
    NSMutableArray *photosArray = [NSMutableArray array];
    for (int i = 0; i < _photosArray.count; i ++) {
        DWDPhotoMetaModel *model = [DWDPhotoMetaModel new];
        PHAsset *asset = _photosArray[i];
        CGSize photoSize = [[DWDPhotosHelper defaultHelper] fitSizeWithOriginSize:(CGSize){asset.pixelWidth, asset.pixelHeight}];
        model.photoKey = photoNames[i];
        model.width = photoSize.width;
        model.height = photoSize.height;
        DWDGrowUpModelPhoto *photoModel = [[DWDGrowUpModelPhoto alloc] init];
        photoModel.photo = model;
        [photosArray addObject:photoModel];
    }
    //剩下
    DWDGrowUpModel *model = [DWDGrowUpModel new];
    model.author.addTime = [NSString stringWithFormat:@"%@",[NSDate date]];
    model.author.photoKey = [DWDCustInfo shared].custThumbPhotoKey;
    model.author.name = [DWDCustInfo shared].custNickname;
    model.record.albumId = _albumId;
    model.record.logId = logId;
    model.record.content = _textView.text;
    model.photos = photosArray;
    
    return model;
}

@end
