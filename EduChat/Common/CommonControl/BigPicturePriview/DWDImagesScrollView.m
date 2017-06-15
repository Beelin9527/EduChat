//
//  DWDImagesScrollView.m
//  picsSelect
//
//  Created by KKK on 16/4/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDImagesScrollView.h"
#import "DWDImageViewScrollView.h"
#import "DWDPhotoMetaModel.h"
#import "UIView+kkk_personalAdd.h"

#import <objc/runtime.h>

@interface DWDImagesScrollView () <UIScrollViewDelegate, DWDImageViewScrollViewDelegate>
@property (nonatomic, strong) NSArray<DWDPhotoMetaModel *> *photoMetaArray;
@property (nonatomic,weak) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger lastPage;
@property (nonatomic, strong) NSMutableArray *scrollViewsArray;
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, assign) BOOL vcNaviBarHidden;

@end

@implementation DWDImagesScrollView

#pragma mark - Public Method
- (instancetype)initWithPhotoMetaArray:(NSArray<DWDPhotoMetaModel *> *)photoMetaArray {
    self = [super init];
    
    _photoMetaArray = photoMetaArray;
    //设置大的
    self.frame = [UIScreen mainScreen].bounds;
    self.delegate = self;
    self.backgroundColor = [UIColor blackColor];
    self.contentSize = CGSizeMake(DWDScreenW * photoMetaArray.count, DWDScreenH);
    self.pagingEnabled = YES;
    
    //设置小的
    [self.scrollViewsArray removeAllObjects];
    for (int i = 0; i < photoMetaArray.count; i ++) {

        DWDPhotoMetaModel *photoMeta = photoMetaArray[i];
        
        /*
         以宽度为基准边进行缩放
         -   缩放至一个屏幕
         **/
        
        /*
         next
         -  根据宽度比例缩放完毕后
         
         -   高度大于屏幕高度
         -   y = 0 x居中显示
         
         -   高度小于屏幕高度
         -   居中显示
         **/
        CGRect rect = [self calculateRectWithPhotoMeta:photoMeta];
//        photoMeta.photo = [photoMeta.photo imageScaledToSize:rect.size];
        
        DWDImageViewScrollView *scrollView = [[DWDImageViewScrollView alloc] initWithPhotoMeta:photoMeta photoRect:rect];
        [self addSubview:scrollView];
        
//        DWDMarkLog(@"OW:%f OH:%f\n%@", photoMeta.width, photoMeta.height, NSStringFromCGRect(rect));
        scrollView.frame = CGRectMake(DWDScreenW * i, 0, DWDScreenW, DWDScreenH);
        scrollView.contentSize = rect.size;
        scrollView.imgView.frame = rect;
        scrollView.dismissDelegate = self;
        scrollView.containerScrollView = self;
        
        [self.scrollViewsArray addObject:scrollView];
    }
    return self;
}

- (void)presentViewFromImageView:(UIImageView *)imgView
                         atIndex:(NSInteger)index
                     toContainer:(UIView *)containerView {

    _containerView = containerView;
    UIViewController *vcContainer = (UIViewController *)[containerView viewController];
    if ([vcContainer isKindOfClass:[UITableViewController class]]) {
        vcContainer = vcContainer.navigationController;
    }
    _vcNaviBarHidden = vcContainer.navigationController.navigationBar.hidden;
    [vcContainer.navigationController setNavigationBarHidden:YES animated:NO];
    for (DWDImageViewScrollView *scImgView in self.scrollViewsArray) {
        if ([vcContainer isKindOfClass:[UINavigationController class]]) {
            scImgView.viewController = [[(UINavigationController *)vcContainer viewControllers] lastObject];
        } else {
        scImgView.viewController = vcContainer;
        }
    }
//    //tableview需要偏移
    CGFloat offsetY = 0;
//    if ([containerView isKindOfClass:[UITableView class]]) {
//        CGRect frame = self.frame;
//        frame.origin.y = ((UITableView *)containerView).contentOffset.y + 20;
//        offsetY = frame.origin.y;
//        self.frame = frame;
//    }
    //设置pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = _photoMetaArray.count;
    [self.superview addSubview:pageControl];
    _pageControl = pageControl;
    pageControl.hidesForSinglePage = YES;
    pageControl.size = CGSizeMake(100, 20);
    pageControl.center = CGPointMake(self.center.x, CGRectGetMaxY(self.frame) - 30);
    [pageControl addTarget:self action:@selector(pageDidClick:) forControlEvents:UIControlEventValueChanged];
    
    /*
     布局
     **/
    CGRect rect = [self calculateRectWithPhotoMeta:_photoMetaArray[index]];
    rect.origin.y += offsetY;
    
    UIView *limingView = [UIView new];
    limingView.backgroundColor = [UIColor blackColor];
    limingView.alpha = 0.0f;
    limingView.frame = self.frame;
    [vcContainer.view addSubview:limingView];
    
    
    [self setContentOffset:CGPointMake((double)index * DWDScreenW, 0)];
    UIImageView *snapView = [[UIImageView alloc] initWithImage:imgView.image];
    snapView.contentMode = UIViewContentModeScaleAspectFill;
    CGFloat width;
    CGFloat height;
    if (rect.size.width > rect.size.height) {
        height = imgView.bounds.size.height;
        width =  imgView.bounds.size.height / rect.size.height * rect.size.width;
    } else {
        width = imgView.bounds.size.width;
        height = imgView.bounds.size.width / rect.size.width * rect.size.height;
    }
    
    CGRect windowRect = [imgView convertRect:imgView.bounds toView:[UIApplication sharedApplication].keyWindow];
    snapView.frame = CGRectMake(windowRect.origin.x - (width - imgView.bounds.size.width) / 2.0, windowRect.origin.y - (height - imgView.bounds.size.height) / 2.0 + offsetY, width, height);
    [vcContainer.view addSubview:snapView];
    
    // 隐藏status bar
    [self exchangeStatusBar];
    [vcContainer setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut  animations:^{
        //动画
        snapView.frame = rect;
        limingView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            // 移除
            [snapView removeFromSuperview];
            [limingView removeFromSuperview];
            [vcContainer.view addSubview:self];
            [self.superview addSubview:pageControl];
            pageControl.currentPage = index;
            _lastPage = index;
            DWDImageViewScrollView *scrollView = _scrollViewsArray[index];
            [scrollView setNeedsLoadingOriginImage];
        }
    }];
}

#pragma mark - Private Method
- (CGRect)calculateRectWithPhotoMeta:(DWDPhotoMetaModel *)photoMeta {
    CGRect frame = CGRectZero;
    /*
     宽度缩放至一个屏幕
     比例
     currentHeight = originHeight * originWidth / screenWidth;
     **/
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

- (NSInteger)indexofScrollViewWithContentOffset:(CGPoint)contentOffset {
    
    return (contentOffset.x + 5) / DWDScreenW;
}

- (DWDImageViewScrollView *)currentScrollViewWithContentOffset:(CGPoint)contentOffset {
    
    return self.scrollViewsArray[[self indexofScrollViewWithContentOffset:contentOffset]];
}

#pragma mark - Event Response
- (void)pageDidClick:(UIPageControl *)pageControl {
    [UIView animateWithDuration:0.25f animations:^{
        self.contentOffset = CGPointMake(pageControl.currentPage * DWDScreenW, 0);
    }];
    
}

#pragma mark - DWDImageViewScrollViewDelegate
- (void)imageViewScrollViewDidTapToDismiss:(DWDImageViewScrollView *)imageViewScrollView {
    [[[_containerView viewController] navigationController] setNavigationBarHidden:_vcNaviBarHidden animated:NO];
    [self exchangeStatusBar];
    [[_containerView viewController] setNeedsStatusBarAppearanceUpdate];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        imageViewScrollView.alpha = 0.0f;
        self.alpha = 0.0f;
        self.pageControl.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [[SDWebImageManager sharedManager] cancelAll];
            [self.pageControl removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[SDWebImageManager sharedManager] cancelAll];
    [[self currentScrollViewWithContentOffset:scrollView.contentOffset] setNeedsLoadingOriginImage];
    
    NSInteger currentPage = [self indexofScrollViewWithContentOffset:scrollView.contentOffset];
    if (currentPage != _lastPage) {
        DWDImageViewScrollView *scrollView = _scrollViewsArray[_lastPage];
        scrollView.zoomScale = 1;
        _lastPage = currentPage;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    NSInteger currentPage = (x + DWDScreenW / 2.0f) / DWDScreenW;
    if (currentPage != _pageControl.currentPage) {
        _pageControl.currentPage = currentPage;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSInteger index = [self indexofScrollViewWithContentOffset:scrollView.contentOffset];
    DWDImageViewScrollView *scroll = _scrollViewsArray[index];
    if (scroll.delegate && [scroll.delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
       return [scroll.delegate viewForZoomingInScrollView:scroll];
    } else {
        return nil;
    }
}

#pragma mark - Setter / Getter
- (NSMutableArray *)scrollViewsArray {
    if (!_scrollViewsArray) {
        _scrollViewsArray = [NSMutableArray array];
    }
    return _scrollViewsArray;
}
@end

#import "UIViewController+kkk_status_bar_swizzling.h"

@implementation DWDImagesScrollView (swizzling)

//切换status bar的hidden 状态
- (void)exchangeStatusBar {
    UIViewController *vc = [_containerView viewController];
    Class class = object_getClass((id)vc);
    SEL originSEL;
    SEL swizzlingSEL = @selector(kk_hideStatusBar);
    if (class_respondsToSelector(class, @selector(prefersStatusBarHidden))) {
        originSEL = @selector(prefersStatusBarHidden);
    } else {
        return;
    }
    Method originMethod = class_getInstanceMethod(class, originSEL);
    Method swizzlingMethod = class_getInstanceMethod(class, swizzlingSEL);
    
    BOOL addMethod = class_addMethod(class, originSEL, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    
    if (addMethod) {
    class_replaceMethod(class, swizzlingSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, swizzlingMethod);
    }
    /*打印方法列表*/
//    unsigned int count1;
//    Method *list1 = class_copyMethodList(class, &count1);
//    for (unsigned int i = 0; i < count1; i ++) {
//        //        printf("%s", (Method)(list[i])->method_name);
//        printf("\n%d %s\n", i, sel_getName(method_getName(list1[i])));
//    }
}

@end
