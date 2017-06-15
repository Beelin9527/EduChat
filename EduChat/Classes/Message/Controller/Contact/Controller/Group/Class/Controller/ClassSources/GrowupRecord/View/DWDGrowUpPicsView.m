//
//  DWDGrowUpPicsView.m
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDGrowUpPicsView.h"
#import "DWDPhotoInfoModel.h"
#import "PreviewImageView.h"
#import <Masonry.h>

@interface DWDGrowUpPicsView () 
@property (nonatomic, strong) NSArray *imageArray;

@end

@implementation DWDGrowUpPicsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}


-(void)tapImageView:(UITapGestureRecognizer *)tap{
    
    UIImageView *imageView = (UIImageView *)tap.view;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect startRect = [imageView convertRect:imageView.bounds toView:window];
    [PreviewImageView showPreviewImage:imageView.image startImageFrame:startRect inView:window viewFrame:window.bounds];
}


- (void)setPicsArray:(NSArray *)picsArray {
    _picsArray = picsArray;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *picArray = [NSMutableArray new];
    for (int i = 0; i < picsArray.count; i ++) {
        UIImageView *picView = [UIImageView new];
        picView.userInteractionEnabled = YES;
        picView.contentMode = UIViewContentModeScaleAspectFill;
        picView.clipsToBounds = YES;
        [picView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)]];
        DWDPhotoInfoModel *photo = picsArray[i];
        [picView sd_setImageWithURL:[NSURL URLWithString:photo.photokey] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
        [picArray addObject:picView];
    }
    self.imageArray = picArray;
    
    //图片个数
    CGFloat height = 0;
    if (picsArray.count == 1) {
        height = pxToW(300);
        UIImageView *picView = self.imageArray[0];
        
        [self addSubview:picView];
        [picView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.width.mas_equalTo(pxToW(300));
            make.height.mas_equalTo(pxToW(300));
        }];
        
    }
    else if ((picsArray.count == 2) || (picsArray.count == 4)) {
        if (picsArray.count == 2) {
            height = pxToW(260);
        } else {
            height = pxToW(540);
        }
        CGFloat margin = pxToW(20);
        CGFloat picWidth = pxToW(260);
        CGFloat picHeight = picWidth;
        for (int i =0; i < self.imageArray.count; i ++) {
            
//            UIImageView *picView = [UIImageView new];
            UIImageView *picView = self.imageArray[i];
            [self addSubview:picView];
            [picView makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset((i/2) * (margin + picHeight));
                make.left.equalTo(self).offset((i%2) * (margin + picWidth));
                make.width.mas_equalTo(picWidth);
                make.height.mas_equalTo(picHeight);
            }];
        }
    }
    else {
        if (picsArray.count == 3) {
            height = pxToW(230);
        } else if(picsArray.count == 5) {
            height = pxToW(470);
        } else {
            height = pxToW(710);
        }

        CGFloat margin = pxToW(10);
        CGFloat picWidth = pxToW(230);
        CGFloat picHeight = picWidth;
        for (int i =0; i < self.imageArray.count; i ++) {
//            UIImageView *picView = [UIImageView new];
            UIImageView *picView = self.imageArray[i];
            [self addSubview:picView];
            [picView makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset((i/3) * (margin + picHeight));
                make.left.equalTo(self).offset((i%3) * (margin + picWidth));
                make.width.mas_equalTo(picWidth);
                make.height.mas_equalTo(picHeight);
            }];
        }
    }

    [self updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [super updateConstraints];
}

@end
