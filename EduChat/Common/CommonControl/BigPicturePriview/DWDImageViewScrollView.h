//
//  DWDImageViewScrollView.h
//  picsSelect
//
//  Created by KKK on 16/4/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDImageViewScrollView;
@class DWDImagesScrollView;
@protocol DWDImageViewScrollViewDelegate <NSObject>
@optional
/**
 *  用于dismiss整个大图预览view的代理
 */
- (void)imageViewScrollViewDidTapToDismiss:(DWDImageViewScrollView *)imageViewScrollView;
@end

@interface DWDImageViewScrollView : UIScrollView

@property (nonatomic, strong) DWDPhotoMetaModel *photoMeta;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, weak) DWDImagesScrollView *containerScrollView;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, weak) id<DWDImageViewScrollViewDelegate> dismissDelegate;

- (instancetype)initWithPhotoMeta:(DWDPhotoMetaModel *)photoMeta photoRect:(CGRect)rect;
- (void)setNeedsLoadingOriginImage;

@end
