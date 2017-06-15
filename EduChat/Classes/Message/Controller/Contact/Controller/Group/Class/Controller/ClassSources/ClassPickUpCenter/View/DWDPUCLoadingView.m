//
//  DWDPUCLoadingView.m
//  EduChat
//
//  Created by KKK on 16/9/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPUCLoadingView.h"

@interface DWDPUCLoadingView ()
@property (nonatomic, weak) UIImageView *loadFailedView;


@end

@implementation DWDPUCLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    //310 * 271
//    CGRect newFrame = (CGRect){0, 0, 310 * 0.5, (271 + 46 + 40) * 0.5};
    self = [super initWithFrame:frame];
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor clearColor];
    [self addSubview:containerView];
    containerView.frame = self.bounds;
    
    UIImageView *loadingView = [[UIImageView alloc] init];
    NSMutableArray *ar = [NSMutableArray array];
    for (int i = 1; i < 8; i ++) {
        [ar addObject:[UIImage imageNamed:[NSString stringWithFormat:@"background_loading_%d", i]]];
    }
    [loadingView setAnimationImages:ar];
    [loadingView setAnimationDuration:0.35f];
    [loadingView startAnimating];
    
    CGRect loadingFrame = loadingView.frame;
    loadingFrame.origin = (CGPoint){(frame.size.width - 310 * 0.5) * 0.5, 0};
    loadingFrame.size = (CGSize){310 * 0.5, 271 * 0.5};
    loadingView.frame = loadingFrame;
    [containerView addSubview:loadingView];
    
    _loadingView = loadingView;
    
    UIImageView *loadFailedView = [UIImageView new];
    [loadFailedView setImage:[UIImage imageNamed:@"background_loading_fail"]];
    loadFailedView.hidden = YES;
    loadFailedView.frame = loadingFrame;
    [containerView addSubview:loadFailedView];
    _loadFailedView = loadFailedView;
    
    UIImageView *blankView = [UIImageView new];
    [blankView setImage:[UIImage imageNamed:@"img_contacts_empty"]];
    blankView.hidden = YES;
//    341 × 225
    blankView.frame = (CGRect){0, 0, 341 * 0.5, 225 * 0.5};
    [containerView addSubview:blankView];
    _blankImgView = blankView;
    
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.font = [UIFont systemFontOfSize:28 * 0.5];
    descriptionLabel.textColor = DWDRGBColor(153, 153, 153);
    descriptionLabel.text = @"努力加载中...";
    [descriptionLabel sizeToFit];
//    CGRect desFrame = descriptionLabel.frame;
//    desFrame.origin = (CGPoint){loadingView.frame.origin.x + 10, CGRectGetMaxY(loadingFrame) + 32 * 0.5};
    CGPoint desCenter = (CGPoint){self.loadingView.center.x + 15, CGRectGetMaxY(loadingFrame) + 46 * 0.5 + descriptionLabel.bounds.size.height * 0.5};
    descriptionLabel.center = desCenter;
    [containerView addSubview:descriptionLabel];
    _descriptionLabel = descriptionLabel;
    
    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reloadButton addTarget:self action:@selector(reloadButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [reloadButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"重新加载"
                                                                     attributes:@{
                                                                                  NSFontAttributeName : [UIFont systemFontOfSize:28 * 0.5],
                                                                                  NSForegroundColorAttributeName : UIColorFromRGB(0x5a88e7)
                                                                                  }]
                            forState:UIControlStateNormal];
    [reloadButton sizeToFit];
    
    CGPoint reloadButtonCenter = CGPointZero;
    reloadButtonCenter.x = self.descriptionLabel.center.x;
    reloadButtonCenter.y = CGRectGetMaxY(descriptionLabel.frame) + reloadButton.bounds.size.height * 0.5 + 30 * 0.5;
    reloadButton.center = reloadButtonCenter;
    [containerView addSubview:reloadButton];
    _reloadButton = reloadButton;
    
    reloadButton.hidden = YES;
    
    
    return self;
}

- (void)changeToFailedView {
    self.loadingView.animationImages = nil;
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.loadFailedView.hidden = NO;
    self.blankImgView.hidden = YES;
    self.descriptionLabel.text = @"拼命加载...失败噜!";
    [self.descriptionLabel sizeToFit];
//    self.descriptionLabel.origin = (CGPoint){self.loadingView.frame.origin.x + 10, CGRectGetMaxY(self.loadingView.frame) + 46 * 0.5};
    CGPoint desCenter = (CGPoint){self.loadingView.center.x  + 15, CGRectGetMaxY(self.loadingView.frame) + 46 * 0.5 + self.descriptionLabel.bounds.size.height * 0.5};
    self.descriptionLabel.center = desCenter;
    
    CGPoint reloadButtonCenter = CGPointZero;
    reloadButtonCenter.x = self.descriptionLabel.center.x;
    reloadButtonCenter.y = CGRectGetMaxY(self.descriptionLabel.frame) + self.reloadButton.bounds.size.height * 0.5 + 30 * 0.5;
    self.reloadButton.center = reloadButtonCenter;
    self.reloadButton.hidden = NO;
}

- (void)changeToBlankView {
    self.loadingView.animationImages = nil;
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.loadFailedView.hidden = YES;
    self.blankImgView.hidden = NO;
    self.reloadButton.hidden = YES;
    [self.descriptionLabel sizeToFit];
    CGPoint desCenter = (CGPoint){self.loadingView.center.x, CGRectGetMaxY(self.loadingView.frame) + 46 * 0.5 + self.descriptionLabel.bounds.size.height * 0.5};
    self.descriptionLabel.center = desCenter;
}

- (void)reloadButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(loadingViewDidClickReloadButton:)]) {
        [_delegate loadingViewDidClickReloadButton:self];
    }
}

/*
    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [containerView addSubview:reloadButton];
    _reloadButton = reloadButton;
 
 添加按钮
 */

@end
