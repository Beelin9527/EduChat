//
//  DWDIntAlertView.m
//  EduChat
//
//  Created by Beelin on 16/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntAlertView.h"

#import <Masonry.h>
@interface DWDIntAlertView ()
@property (nonatomic, strong) UIImageView *imv;
@property (nonatomic, strong) UILabel *contentLab;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *okBtn;
@end

@implementation DWDIntAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        UIView *boxView = [[UIView alloc] init];
        [self addSubview:({
            boxView.frame = CGRectMake(DWDScreenW/2 - 270/2.0, DWDScreenH/2.0 - 350/2.0, 270, 350);
            boxView.backgroundColor = [UIColor whiteColor];
            boxView.layer.masksToBounds = YES;
            boxView.layer.cornerRadius = 10;
            boxView;
        })];
        
        UIImageView *imv = [[UIImageView alloc] init];
        [boxView addSubview:({
            imv.frame = CGRectMake(0, 0, boxView.w, 155);
            _imv = imv;
        })];
        
        UILabel *contentLab = [[UILabel alloc] init];
        [boxView addSubview:({
            contentLab.textColor = DWDColorContent;
            contentLab.font = DWDFontContent;
            contentLab.textAlignment = NSTextAlignmentCenter;
            contentLab.numberOfLines = 0;
            _contentLab = contentLab;
        })];
        
        UILabel *titleLab = [[UILabel alloc] init];
        [boxView addSubview:({
            titleLab.textColor = DWDColorBody;
            titleLab.font = DWDFontBody;
            titleLab.textAlignment = NSTextAlignmentCenter;
            _titleLab = titleLab;
        })];
        
        UIView *line = [[UIView alloc] init];
        [boxView addSubview:({
            line.frame = CGRectMake(0, 305, boxView.w, 0.7);
            line.backgroundColor = DWDColorSeparator;
            line;
        })];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [boxView addSubview:({
            btn.frame = CGRectMake(0, 306, boxView.w, 45);
            [btn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchDown];
            _okBtn = btn;
        })];
        
        //masonry
        [contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.mas_equalTo(230);
        }];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(contentLab.mas_top).mas_offset(-14);
        }];
    }
    return self;
}

#pragma mark - Setter
- (void)setModel:(DWDIntAlertViewModel *)model{
    _model = model;
    
    [_imv sd_setImageWithURL:[NSURL URLWithString:_model.icon] placeholderImage:DWDDefault_infoVideoImage];
    _contentLab.text = _model.content;
    _titleLab.text = _model.title;
    [_okBtn setTitle:_model.btntext forState:UIControlStateNormal];
    
    //计算文本高度及设计contentLab的布局top
    CGFloat contentH = [self.contentLab.text boundingRectWithfont:DWDFontContent sizeMakeWidth:230].height;
    CGFloat contentTop = 240 - contentH/2.0;//240是文本在boxView的中心点值
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentTop);
    }];

}
#pragma mark - Event Method
- (void)okAction:(UIButton *)sender{
    [self removeFromSuperview];
}
@end


@implementation DWDIntAlertViewModel
@end

