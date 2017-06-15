//
//  DWDFaceView.m
//  EduChat
//
//  Created by Gatlin on 16/1/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDFaceView.h"

@interface DWDFaceView ()<UIScrollViewDelegate>

@property (strong, nonatomic) DWDFacePageView *facePageView;
@property (strong, nonatomic) DWDFaceMenuView *faceMenuView;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray *arrFacePageViews;
@property (strong, nonatomic) NSArray *allFaceArray;
@end

@implementation DWDFaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDLineH)];
        line.backgroundColor = DWDColorSeparator;
        [self addSubview:line];
        
        _allFaceArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"]];
        
       // NSArray *arr1 = [arrFace copy];
        
//        NSArray *arr2 = [arrFace copy];
//        NSArray *arr3 = [arrFace copy];
//        NSArray *arr4 = [arrFace copy];
//        NSMutableArray *arr = [NSMutableArray array];
//        [arr addObjectsFromArray:arr1];
//        [arr addObjectsFromArray:arr2];
//        [arr addObjectsFromArray:arr3];
//        [arr addObjectsFromArray:arr4];

        [self addSubview:self.facePageView];
        [self addSubview:self.faceMenuView];
        [self addSubview:self.pageControl];

    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
    CGRect fra = frame;
    fra.size.height = 200;
    frame = fra;
    [super setFrame:frame];
}

- (void)createFacePageView:(NSArray *)array
{
    DWDFacePageView *facePageView = [[DWDFacePageView alloc]initWithArrayFace:array];
    [self.arrFacePageViews addObject:facePageView];
    
}
#pragma mark - Getter
- (NSMutableArray *)arrFacePageViews
{
    if (!_arrFacePageViews) {
        _arrFacePageViews = [NSMutableArray array];
    }
    return _arrFacePageViews;
}
- (DWDFaceMenuView *)faceMenuView
{
    if (!_faceMenuView) {
        _faceMenuView = [[DWDFaceMenuView alloc]initWithFrame:CGRectMake(0, 160 , self.bounds.size.width , 40)];
        [_faceMenuView setDelegate:self];
    }
    return _faceMenuView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(DWDScreenW/2 - 100, 140, 200, 20)];
        _pageControl.numberOfPages = 7;
        _pageControl.currentPageIndicatorTintColor = DWDColorMain;
        _pageControl.pageIndicatorTintColor = DWDColorSeparator;
    }
    return _pageControl;
}
- (DWDFacePageView *)facePageView
{
    if (!_facePageView) {
        _facePageView = [[DWDFacePageView alloc]initWithArrayFace:self.allFaceArray];
        _facePageView.frame = CGRectMake(0, 0, self.bounds.size.width, 160);
        _facePageView.delegateFace = self;
        _facePageView.delegate = self;
        [_facePageView setPagingEnabled:YES];
        [_facePageView setShowsHorizontalScrollIndicator:NO];
        [_facePageView setShowsVerticalScrollIndicator:NO];

        [_facePageView setContentSize:CGSizeMake(7 * self.bounds.size.width, 160)];
    }
    return _facePageView;
}

#pragma DWDFacePage Delegate
- (void)facePageView:(DWDFacePageView *)facePageView didSelectPace:(NSString *)paceName
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceView:didSelectPace:)]) {
        
        [self.delegate faceView:self didSelectPace:paceName];
    }
}

- (void)facePageViewDidSelectDelete:(DWDFacePageView *)facePageView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewDidSelectDelete:)]) {
        
        [self.delegate faceViewDidSelectDelete:self];
    }
}

#pragma DWDFaceMenu Delegate
- (void)faceMenuViewSendData:(DWDFaceMenuView *)faceMenuView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceViewDidSelectSend:)]) {
        
        [self.delegate faceViewDidSelectSend:self];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   int offsetX = scrollView.contentOffset.x / self.bounds.size.width;
    self.pageControl.currentPage = offsetX;
}
@end
