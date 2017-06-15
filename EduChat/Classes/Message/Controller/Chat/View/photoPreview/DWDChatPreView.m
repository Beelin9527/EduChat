//
//  DWDChatPreView.m
//  EduChat
//
//  Created by Superman on 16/9/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatPreView.h"
#import "DWDChatPreViewCell.h"
#import "DWDImageChatMsg.h"

#import <objc/runtime.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface DWDChatPreView () <UICollectionViewDataSource , UICollectionViewDelegate , DWDChatPreViewCellDelegate >

@property (nonatomic , strong) NSArray *imageMsgs;
@property (nonatomic , weak) UIPageControl *pageControl;
@property (nonatomic , assign) NSUInteger tapImageIndex;

@property (nonatomic , strong) CAShapeLayer *progressLayer;
@property (nonatomic , assign) CGFloat lastContentOffSetX;

@end

@implementation DWDChatPreView

static NSString *ID = @"DWDChatPreViewCell";

+ (instancetype)showPreViewWithImageMsgs:(NSArray *)imageMsgs tapIndex:(NSUInteger)index inView:(UIView *)view{
    
    DWDChatPreView *preView = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds imageMsgs:imageMsgs tapIndex:index inView:(UIView *)view];
    
    return preView;
}

- (instancetype)initWithFrame:(CGRect)frame imageMsgs:(NSArray *)imageMsgs tapIndex:(NSUInteger)index inView:(UIView *)view{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self registerClass:[DWDChatPreViewCell class] forCellWithReuseIdentifier:ID];
        self.collectionViewLayout = layout;
        self.pagingEnabled = YES;
        self.contentOffset = CGPointMake(DWDScreenW * index, 0);
        
        _imageMsgs = imageMsgs;
        _tapImageIndex = index;
        
        self.dataSource = self;
        self.delegate = self;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        _progressLayer = layer;
        _progressLayer.frame = CGRectMake(0, 0, 40, 40);
        _progressLayer.cornerRadius = 20;
        _progressLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500].CGColor;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(_progressLayer.bounds, 7, 7) cornerRadius:(40 / 2 - 7)];
        _progressLayer.path = path.CGPath;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.lineWidth = 4;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd = 0;
        _progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
        
        [view addSubview:self];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect frame = _progressLayer.frame;
    frame.origin = CGPointMake((self.frame.size.width - _progressLayer.bounds.size.width) / 2.0, (self.frame.size.height - _progressLayer.bounds.size.width) / 2.0);
    frame.size = CGSizeMake(40, 40);
    _progressLayer.frame = frame;
}

#pragma mark - Private Method
- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

/*
 宽度缩放至一个屏幕
 比例
 currentHeight = originHeight * originWidth / screenWidth;
 **/

- (CGRect)calculateRectWithPhotoMeta:(DWDPhotoMetaModel *)photoMeta {
    CGRect frame = CGRectZero;
    
    frame.size.width = DWDScreenW;
    frame.size.height = photoMeta.height * (DWDScreenW / photoMeta.width);
    if (frame.size.height == 0 || isnan(frame.size.height)) {
        frame.size.height = frame.size.width;
    }
    //判断是居中还是顶头
    frame.origin.x = 0;
    if (frame.size.height > DWDScreenH)
        frame.origin.y = 0;
    else
        frame.origin.y = (DWDScreenH - frame.size.height) / 2.0;
    return frame;
}

#pragma mark - <UICollectionViewDataSource , UICollectionViewDelegate>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageMsgs.count;
}

- (DWDChatPreViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    __block DWDChatPreViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[DWDChatPreViewCell alloc] init];
        cell.indexPath = indexPath;
    }
    
    DWDImageChatMsg *imageMsg = _imageMsgs[indexPath.row];
    CGRect rect = [self calculateRectWithPhotoMeta:imageMsg.photo];  //把选中的图片 缩放到一个屏幕大小的图片尺寸
    cell.preViewCellDelegate = self;
    cell.imageMsg = imageMsg;
    
    WEAKSELF;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[imageMsg.fileKey imgKey]] placeholderImage:[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[imageMsg.photo chatThumbPhotoKey]] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (!weakSelf) return;
        CGFloat progress = receivedSize / (float)expectedSize;
        progress = progress < 0.01 ? 0.01 : progress > 1 ? 1 : progress;
        weakSelf.progressLayer.hidden = NO;
        weakSelf.progressLayer.strokeEnd = progress;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.progressLayer.hidden = YES;
    }];
    
    cell.imageView.frame = rect;
    [cell.scrollView setContentSize:CGSizeMake(0, rect.size.height)];
    
    return cell;
}


#pragma mark - <DWDChatPreViewCellDelegate>
- (void)preViewCellImageViewTap{
    // 通知VC 回复状态栏
    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatPreViewCellImageViewTap object:nil userInfo:nil];
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)preViewCellImageRelayToSomeOne{
    // 通知VC 回复状态栏
    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatPreViewCellDidRelayToSomeone object:nil userInfo:nil];
    
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    _lastContentOffSetX = scrollView.contentOffset.x;
    // 上一个item scrollview的contentsize 归零  imageview归位
    NSUInteger index = scrollView.contentOffset.x / DWDScreenW;
    DWDChatPreViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:ID forIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell.scrollView setContentSize:CGSizeZero];
    cell.imageView.center = cell.center;
    
}

@end
