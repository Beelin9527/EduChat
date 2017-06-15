//
//  DWDRefreshGifHeader.m
//  EduChat
//
//  Created by Catskiy on 16/8/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRefreshGifHeader.h"

@interface DWDRefreshGifHeader ()

@property (weak, nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation DWDRefreshGifHeader

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.gifView.frame = self.bounds;
    self.gifView.contentMode = UIViewContentModeScaleAspectFit;
    self.gifView.mj_h = self.mj_h - 20;
    self.stateLabel.mj_y += 35;
    self.loadingView.frame = CGRectMake(self.mj_w * 0.5 - 60, self.gifView.mj_h, 20, 20);
}

- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(MJRefreshState)state
{
    [super setImages:images duration:duration forState:state];
    self.mj_h = 90;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

- (void)setState:(MJRefreshState)state
{
    [super setState:state];
    // 根据状态做事情
    if (state == MJRefreshStatePulling || state == MJRefreshStateRefreshing) {
        [self.loadingView startAnimating];
        self.stateLabel.text = @"正在刷新中";
    } else if (state == MJRefreshStateIdle) {
        [self.loadingView stopAnimating];
        self.stateLabel.text = @"刷新完成";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.stateLabel.text = @"下拉刷新";
        });
    }
}

@end
