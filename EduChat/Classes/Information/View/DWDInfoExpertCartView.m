//
//  DWDInfoExpertCartView.m
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoExpertCartView.h"

@interface DWDInfoExpertCartView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *placeBackView;
@property (nonatomic, strong) UIImageView *topImgV;
@property (nonatomic, strong) UIImageView *avatarImgV;
@property (nonatomic, strong) UIImageView *tagBackImgV;
@property (nonatomic, strong) UIImageView *placeIconImgV;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *tagLbl;
@property (nonatomic, strong) UILabel *rankLbl;

@end

@implementation DWDInfoExpertCartView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    [self addSubview:self.backView];
    [self addSubview:self.topImgV];
    [self addSubview:self.rankLbl];
}

- (void)layoutSubviews
{
    self.backView.frame = CGRectMake(0, 3.0, self.w, self.h - 3.0);
    self.topImgV.frame = CGRectMake(4.0, 0, 24.0, 24.0);
    self.avatarImgV.frame = CGRectMake(0, 0, self.w, self.backView.h - 25.0);
    self.tagBackImgV.frame = CGRectMake(0, self.avatarImgV.h * 0.6, self.avatarImgV.w, self.avatarImgV.h * 0.4);
    self.placeBackView.frame = CGRectMake(0, 0, self.w, self.avatarImgV.h);
    self.placeIconImgV.frame = CGRectMake((self.backView.w - 26.0) * 0.5, self.backView.h * 0.23, 26.0, 29.0);
    
    self.tagLbl.frame = CGRectMake(DWDPadding, CGRectGetMaxY(self.avatarImgV.frame) - DWDPadding - 12.0, self.w - 2 * DWDPadding, 12.0);
    self.nameLbl.frame = CGRectMake(DWDPadding, CGRectGetMaxY(self.avatarImgV.frame), self.w - 2 * DWDPadding, 25.0);
    self.rankLbl.frame = CGRectMake(self.topImgV.x, self.topImgV.y, self.topImgV.w - 2.0, self.topImgV.h -3.0);
}

- (UIView *)backView
{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.cornerRadius = 4.0;
        _backView.layer.borderColor = DWDColorSeparator.CGColor;
        _backView.layer.borderWidth = 1.0;
        _backView.layer.masksToBounds = YES;
        
        _placeBackView = [[UIView alloc] init];
        _placeBackView.backgroundColor = UIColorFromRGB(0xe9e9e9);
        [_backView addSubview:_placeBackView];
        
        _placeIconImgV = [[UIImageView alloc] init];
        _placeIconImgV.contentMode = UIViewContentModeScaleAspectFit;
        _placeIconImgV.image = [UIImage imageNamed:@"bg_professor"];
        [_backView addSubview:_placeIconImgV];
        
        [_backView addSubview:self.avatarImgV];
        [_backView addSubview:self.nameLbl];
        [_backView addSubview:self.tagLbl];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

- (UIImageView *)topImgV
{
    if (!_topImgV) {
        _topImgV = [[UIImageView alloc] init];
        _topImgV.contentMode = UIViewContentModeCenter;
    }
    return _topImgV;
}

- (UIImageView *)avatarImgV
{
    if (!_avatarImgV) {
        _avatarImgV = [[UIImageView alloc] init];
        _avatarImgV.layer.masksToBounds = YES;
        _avatarImgV.contentMode = UIViewContentModeScaleAspectFill;
//        _avatarImgV.backgroundColor = UIColorFromRGBWithAlpha(0xe9e9e9, 0.3);
//        _avatarImgV.image = [UIImage imageNamed:@"bg_record_detail"];
        
        _tagBackImgV = [[UIImageView alloc] init];
        _tagBackImgV.layer.masksToBounds = YES;
        _tagBackImgV.contentMode = UIViewContentModeScaleAspectFill;
        _tagBackImgV.image = [UIImage imageNamed:@"img_photo_123"];
        [_avatarImgV addSubview:_tagBackImgV];
    }
    return _avatarImgV;
}

- (UILabel *)nameLbl
{
    if (!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.textAlignment = NSTextAlignmentCenter;
        _nameLbl.font = DWDFontContent;
        _nameLbl.textColor = DWDColorContent;
//        _nameLbl.text = @"范专家";
    }
    return _nameLbl;
}

- (UILabel *)tagLbl
{
    if (!_tagLbl) {
        _tagLbl = [[UILabel alloc] init];
        _tagLbl.textAlignment = NSTextAlignmentCenter;
        _tagLbl.font = DWDFontMin;
        _tagLbl.textColor = [UIColor whiteColor];
//        _tagLbl.text = @"资深程序猿";
    }
    return _tagLbl;
}

- (UILabel *)rankLbl
{
    if (!_rankLbl) {
        _rankLbl = [[UILabel alloc] init];
        _rankLbl.textAlignment = NSTextAlignmentCenter;
        _rankLbl.font = DWDFontMin;
        _rankLbl.textColor = [UIColor whiteColor];
    }
    return _rankLbl;
}

- (void)tapGestureHandle:(UITapGestureRecognizer *)tap
{
    NSInteger index = [_rankLbl.text integerValue] - 1;
    self.tapBlock ? self.tapBlock(index) : nil;
}

- (void)setTopImage:(UIImage *)image
{
    _topImgV.image = image;
}

- (void)setRank:(int)rank
{
    _rankLbl.text = [NSString stringWithFormat:@"%d",rank];
}

- (void)setExpert:(DWDInfoExpertModel *)expert
{
    [_avatarImgV sd_setImageWithURL:[NSURL URLWithString:expert.photoKey] placeholderImage:nil];//expert.photoKey
    _nameLbl.text = expert.name;
    if (expert.tags.count > 0) {
        _tagLbl.text = [expert.tags[0] name];
    }
}

@end
