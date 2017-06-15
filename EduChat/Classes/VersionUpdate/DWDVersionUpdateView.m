//
//  DWDVersionUpdateView.m
//  EduChat
//
//  Created by KKK on 16/9/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDVersionUpdateView.h"

#import "UIImage+Utils.h"

@interface DWDVersionUpdateView ()

@property (nonatomic, weak) UIButton *cancelButton;

@property (nonatomic, assign) BOOL forceUpdate;


@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UITextView *contentTextView;

@end

@implementation DWDVersionUpdateView
{
    NSString *_version;
}

- (instancetype)initWithVersion:(NSString *)version content:(NSString *)content forceUpdate:(BOOL)forceUpdate {
    _forceUpdate = forceUpdate;
    _version = version;
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    CGFloat textViewHeight = 204 * 0.5;
    
    UIImageView *backgroundImgView = [[UIImageView alloc] init];
    backgroundImgView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.preferredMaxLayoutWidth = 408 * 0.5 - 78;
    titleLabel.numberOfLines = 1;
    _titleLabel = titleLabel;
    
    UITextView *contentTextView = [[UITextView alloc] init];
    contentTextView.selectable = NO;
    contentTextView.textContainerInset = UIEdgeInsetsMake(5, 6, 5, 6);
    contentTextView.editable = NO;
    contentTextView.alwaysBounceVertical = YES;
    contentTextView.showsVerticalScrollIndicator = NO;
    contentTextView.showsHorizontalScrollIndicator = NO;
    _contentTextView = contentTextView;
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton addTarget:self action:@selector(completeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setImage:[UIImage imageNamed:@"btn_cancel"] forState:UIControlStateNormal];
    [cancelButton setContentMode:UIViewContentModeCenter];
    _cancelButton = cancelButton;
    if (forceUpdate) {
        cancelButton.hidden = YES;
        cancelButton.enabled = NO;
    }
    
    NSString *title = [NSString stringWithFormat:@"V%@ 新增功能", version];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    UIColor *fontColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0f];
    
    NSAttributedString *titleAttr = [[NSAttributedString alloc]
                                     initWithString:title
                                     attributes:@{
                                                  NSFontAttributeName : font,
                                                  NSForegroundColorAttributeName : fontColor
                                                  }];
    NSString *rnContentStr = [content stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    
    NSAttributedString *contentAttr = [[NSAttributedString alloc]
                                       initWithString:rnContentStr
                                       attributes:@{
                                                    NSFontAttributeName : font,
                                                    NSForegroundColorAttributeName : fontColor
                                                    }];
    
    //ready setting
    self.backgroundColor = [UIColor colorWithRed:0.0f
                                           green:0.0f
                                            blue:0.0f
                                           alpha:0.5f];
    [titleLabel setAttributedText:titleAttr];
    [contentTextView setAttributedText:contentAttr];
    
    //    [confirmButton setTitle:@"立即更新" forState:UIControlStateNormal];
    [confirmButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"立即更新"
                                                                      attributes:@{NSFontAttributeName : [UIFont fontWithName:@"PingFangSC-Regular" size:27.3 * 0.5],
                                                                                                  NSForegroundColorAttributeName : [UIColor colorWithRed:254 / 255.0
                                                                                                                                                   green:254 / 255.0
                                                                                                                                                    blue:255 / 255.0
                                                                                                                                                   alpha:1.0f]}]
                             forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x5a88e6)] forState:UIControlStateNormal];
    confirmButton.layer.cornerRadius = 22;
    confirmButton.layer.masksToBounds = YES;
    
    //calculate frame
    [titleLabel sizeToFit];
    
    //start adjust if backgroundimageView needs extend
    //    CGFloat currentHeight = 222 + titleHeight + 12 + textViewHeight + 20 + 45 + 19;
    [backgroundImgView setImage:[UIImage imageNamed:@"img_dialog"]];
    CGRect bgFrame = backgroundImgView.frame;
    bgFrame.origin = (CGPoint){([UIScreen mainScreen].bounds.size.width - 540 * 0.5) * 0.5, [UIScreen mainScreen].bounds.size.height / (1334.0 * 0.5) * 230 * 0.5};
    bgFrame.size = (CGSize){540 * 0.5, 801 * 0.5};
    backgroundImgView.frame = bgFrame;
    if (CGRectGetMaxY(backgroundImgView.frame) > [UIScreen mainScreen].bounds.size.height) {
        backgroundImgView.center = self.center;
    }
    
    //frame settting
    [self addSubview:backgroundImgView];
    
    CGRect frame = CGRectZero;
    
    frame = titleLabel.frame;
    frame.origin.x = 78 * 0.5;
    frame.origin.y = 422 * 0.5;
    titleLabel.frame = frame;
    [backgroundImgView addSubview:titleLabel];
    
    contentTextView.frame = (CGRect){33, CGRectGetMaxY(titleLabel.frame) + 13 * 0.5, 408 * 0.5, textViewHeight};
    [backgroundImgView addSubview:contentTextView];
        cancelButton.frame = (CGRect){514 * 0.5 - 10, 146 * 0.5 - 10, 30 + 20, 30 + 20};
        [backgroundImgView addSubview:cancelButton];
    confirmButton.frame = (CGRect){47 * 0.5, CGRectGetMaxY(contentTextView.frame) + 6, (540 - 47 * 2) * 0.5, 88 * 0.5};
    [backgroundImgView addSubview:confirmButton];
    
    
    //add grandintlayer
    
    CAGradientLayer *gradientLayerTop = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayerTop.borderWidth = 0;
    gradientLayerTop.frame = (CGRect){contentTextView.frame.origin.x, contentTextView.frame.origin.y, contentTextView.frame.size.width, 18};
    gradientLayerTop.colors = [NSArray arrayWithObjects:
                               (id)[[UIColor whiteColor] CGColor],
                               (id)[[UIColor colorWithWhite:1.0f alpha:0.0f] CGColor], nil];
    gradientLayerTop.startPoint = CGPointMake(0.5, 0.0);
    gradientLayerTop.endPoint = CGPointMake(0.5, 1.0);
    [backgroundImgView.layer addSublayer:gradientLayerTop];
    
    CAGradientLayer *gradientLayerBottom = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayerBottom.frame = (CGRect){contentTextView.frame.origin.x, CGRectGetMaxY(contentTextView.frame) - 6, contentTextView.frame.size.width, 6};
    gradientLayerBottom.borderWidth = 0;
    gradientLayerBottom.colors = [NSArray arrayWithObjects:
                                  (id)[[UIColor colorWithWhite:1.0f alpha:0.0f] CGColor],
                                  (id)[[UIColor whiteColor] CGColor], nil];
    gradientLayerBottom.startPoint = CGPointMake(0.5, 0.0);
    gradientLayerBottom.endPoint = CGPointMake(0.5, 1.0);
    
    [backgroundImgView.layer addSublayer:gradientLayerBottom];
    
    return self;
}


-(void)refreshWithVersion:(NSString *)version
                  content:(NSString *)content {
    
    NSString *title = [NSString stringWithFormat:@"V%@ 新增功能", version];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    UIColor *fontColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0f];
    
    NSAttributedString *titleAttr = [[NSAttributedString alloc]
                                     initWithString:title
                                     attributes:@{
                                                  NSFontAttributeName : font,
                                                  NSForegroundColorAttributeName : fontColor
                                                  }];
    NSString *rnContentStr = [content stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    
    NSAttributedString *contentAttr = [[NSAttributedString alloc]
                                       initWithString:rnContentStr
                                       attributes:@{
                                                    NSFontAttributeName : font,
                                                    NSForegroundColorAttributeName : fontColor
                                                    }];
    [_titleLabel setAttributedText:titleAttr];
    [_contentTextView setAttributedText:contentAttr];

    [_titleLabel sizeToFit];
    
    
    CGRect frame = CGRectZero;
    frame = _titleLabel.frame;
    frame.origin.x = 78 * 0.5;
    frame.origin.y = 422 * 0.5;
    _titleLabel.frame = frame;
    
    CGFloat textViewHeight = 204 * 0.5;
    _contentTextView.frame = (CGRect){33, CGRectGetMaxY(_titleLabel.frame) + 13 * 0.5, 408 * 0.5, textViewHeight};
}







- (void)completeButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(versionUpdateViewDidClickUpdateButton:)]) {
        [_delegate versionUpdateViewDidClickUpdateButton:self];
    }
    if (!_forceUpdate) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }
}

- (void)cancelButtonClick {
    if (_delegate && [_delegate respondsToSelector:@selector(versionUpdateView:didClickCancelButtonWithVersion:)]) {
        [_delegate versionUpdateView:self didClickCancelButtonWithVersion:_version];
    }
    if (!_forceUpdate) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
    }
}

//取消按钮点击范围
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 当前坐标系上的点转换到按钮上的点
    CGPoint btnP = [self convertPoint:point toView:_cancelButton];
    
    // 判断点在不在按钮上
    if ([_cancelButton pointInside:btnP withEvent:event]) {
        // 点在按钮上
        return _cancelButton;
    }else{
        return [super hitTest:point withEvent:event];
    }
}

@end
