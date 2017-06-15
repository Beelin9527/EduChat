//
//  ViewController.m
//  GuidePages
//
//  Created by KKK on 3/7/16.
//  Copyright © 2016 KKK. All rights reserved.
//#

#import "DWDGuideViewController.h"
#import "DWDTabbarViewController.h"
#import "JPUSHService.h"

#import "DWDVersionUpdateManager.h"

@interface DWDGuideViewController () <UIScrollViewDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView0;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UIImageView *imageView4;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *endButton;
@end

@implementation DWDGuideViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self layoutSubView];
    
    //监听JPush登录成功回调,获取 registrationID --Add by fzg
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];

}

#pragma mark - private method
- (void)layoutSubView {
    [self.view addSubview:self.imageView0];
    [self.view insertSubview:self.imageView1 belowSubview:self.imageView0];
    [self.view insertSubview:self.imageView2 belowSubview:self.imageView1];
    [self.view insertSubview:self.imageView3 belowSubview:self.imageView2];
    [self.view insertSubview:self.imageView4 belowSubview:self.imageView3];
    
    [self.view insertSubview:self.scrollView aboveSubview:self.imageView0];
    [self.view insertSubview:self.pageControl aboveSubview:self.scrollView];
    
    [self.scrollView addSubview:self.endButton];
    self.endButton.center = CGPointMake(DWDScreenW * 4.5, DWDScreenH - pxToW(97 + 65 * 0.5));
}

- (void)calculateImagesAlphaWithPoint:(CGFloat)pointX {
//    320
    
    CGFloat imgEnd = [UIScreen mainScreen].bounds.size.width;
    CGFloat currentX = 0;
    if (pointX < imgEnd && pointX >= 0) {
//        0 ~ 320
        self.pageControl.currentPage = 0;
        currentX = pointX;
        //imgeView0
        self.imageView0.alpha = 1 - currentX / imgEnd;
    } else if (pointX < imgEnd * 2 && pointX >= imgEnd) {
//        320 ~ 640
        self.pageControl.currentPage = 1;
        currentX = pointX - imgEnd;
        //imgeView1
        self.imageView1.alpha = 1 - currentX / imgEnd;
        
    } else if (pointX < imgEnd * 3 && pointX >= imgEnd * 2) {
//        640 ~ 960
        self.pageControl.currentPage = 2;
        currentX = pointX - imgEnd * 2;
        //imgeView2
        self.imageView2.alpha = 1 - currentX / imgEnd;
    } else if (pointX < imgEnd * 4 && pointX >= imgEnd * 3) {
        self.pageControl.currentPage = 3;
        currentX = pointX - imgEnd * 3;
        //imgeView2
        self.imageView3.alpha = 1 - currentX / imgEnd;
    } else if (pointX == imgEnd * 4) {
        self.pageControl.currentPage = 4;
    } else if (pointX > (imgEnd * 4 + 10)) {
        [self endButtonClick];
    }
}

- (void)endButtonClick {
    DWDMarkLog(@"endButtonClick");
    
    DWDTabbarViewController *vc = [[DWDTabbarViewController alloc]init];
    [[UIApplication sharedApplication].keyWindow setRootViewController:vc];
    [[DWDVersionUpdateManager defaultManager] checkUpdate];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //4张图
    [self calculateImagesAlphaWithPoint:scrollView.contentOffset.x];
}


#pragma mark - setter / getter

- (UIButton *)endButton {
    if (!_endButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setTitle:@"立即体验" forState:UIControlStateNormal];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:
                                                [UIFont systemFontOfSize:20]
                                                                                  forKey:NSFontAttributeName];
        [attrsDictionary setObject:DWDRGBColor(64, 147, 232) forKey:NSForegroundColorAttributeName];
        NSAttributedString *titleStr = [[NSAttributedString alloc] initWithString:@"立即体验" attributes:attrsDictionary];
        [button setAttributedTitle:titleStr forState:UIControlStateNormal];
        [button setSize:CGSizeMake(106, 65 * 0.5)];
        button.layer.cornerRadius = 65 * 0.25;
        button.layer.borderWidth = 1;
        button.layer.borderColor = DWDRGBColor(64, 147, 232).CGColor;
        button.layer.masksToBounds = YES;
//        UIImage *buttonImage = [UIImage imageNamed:@"btn_come_in"];
//        buttonImage = [buttonImage resizableImageWithCapInsets:UIEdgeInsetsMake(buttonImage.size.height * 0.5, buttonImage.size.width * 0.5, buttonImage.size.height * 0.5, buttonImage.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
        [button addTarget:self action:@selector(endButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        _endButton = button;
    }
    return _endButton;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 5, [UIScreen mainScreen].bounds.size.height);
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        
        scrollView.delegate = self;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        pageControl.numberOfPages = 5;
        pageControl.pageIndicatorTintColor = UIColorFromRGB(0xdddddd);
        pageControl.currentPageIndicatorTintColor = DWDRGBColor(64, 147, 232);
        pageControl.size = [pageControl sizeForNumberOfPages:5];
        [pageControl sizeToFit];
        pageControl.center = CGPointMake(DWDScreenW / 2.0, DWDScreenH - pxToW(44 - 15));
        
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (UIImageView *)imageView0 {
    if (!_imageView0) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_guide_one"]];
        view.frame = [UIScreen mainScreen].bounds;
        _imageView0 = view;
    }
    
    return _imageView0;
}

- (UIImageView *)imageView1 {
    if (!_imageView1) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_guide_two"]];
        view.alpha = 1.00;
        view.frame = [UIScreen mainScreen].bounds;
        _imageView1 = view;
    }
    
    return _imageView1;
}

- (UIImageView *)imageView2 {
    if (!_imageView2) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_guide_three"]];
        view.alpha = 1.00;
        view.frame = [UIScreen mainScreen].bounds;
        _imageView2 = view;
    }
    
    return _imageView2;
}

- (UIImageView *)imageView3 {
    if (!_imageView3) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_guide_four"]];
        view.alpha = 1.00;
        view.frame = [UIScreen mainScreen].bounds;
        _imageView3 = view;
    }
    
    return _imageView3;
}


- (UIImageView *)imageView4 {
    if (!_imageView4) {
        UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_guide_five"]];
        view.alpha = 1.00;
        view.frame = [UIScreen mainScreen].bounds;
        _imageView4 = view;
    }
    
    return _imageView4;
}

//获取 registrationID --Add by fzg
- (void)networkDidLogin:(NSNotification *)notification {
    
    if ([JPUSHService registrationID]) {
        DWDLog(@"get RegistrationID");
        [DWDCustInfo shared].registrationID = [JPUSHService registrationID];
    }
}

- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:kJPFNetworkDidLoginNotification
                           object:nil];
}

@end
