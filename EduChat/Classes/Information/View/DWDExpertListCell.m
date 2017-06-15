//
//  DWDExpertListCell.m
//  EduChat
//
//  Created by Catskiy on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDExpertListCell.h"
#import "NSDate+dwd_dateCategory.h"
#import "NSNumber+Extension.h"
#import <Masonry.h>

@interface DWDExpertListCell ()

@property (nonatomic, strong) UIImageView *avatarImgV;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *tagLbl;
@property (nonatomic, strong) UILabel *updateLbl;
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UILabel *subNumLbl;
@property (nonatomic, strong) UILabel *unReadLbl;
@property (nonatomic, strong) UIButton *subsBtn;

@end

@implementation DWDExpertListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSubviews];
        self.style = ExpertListCellStyleNomal;
        self.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    return self;
}

- (void)setSubviews
{
    [self.contentView addSubview:self.avatarImgV];
    [self.contentView addSubview:self.nameLbl];
    [self.contentView addSubview:self.tagLbl];
    [self.contentView addSubview:self.updateLbl];
    [self.contentView addSubview:self.subNumLbl];
    [self.contentView addSubview:self.unReadLbl];
    [self.contentView addSubview:self.timeLbl];
    [self.contentView addSubview:self.subsBtn];
    
//    self.avatarImgV.image = [UIImage imageNamed:@"img_defaultphoto"];
//    self.nameLbl.text = @"范砖家";
//    self.tagLbl.text = @"资深搬砖砖家";
//    self.updateLbl.text = @"专业搬砖20年,熟练掌握多种搬砖技能...";
//    self.subNumLbl.text = @"5023已订";
//    self.timeLbl.text = @"20分钟前";
//    self.unReadLbl.text = @"999未读";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = [self.subNumLbl.text boundingRectWithfont:self.subNumLbl.font].width + 5;
    
    [self.avatarImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(DWDPaddingMax);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.subsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-DWDPaddingMax);
        make.top.equalTo(self).offset(30);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(30);
    }];
    
    [self.subNumLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-DWDPaddingMax);
        make.top.equalTo(self.subsBtn.mas_bottom).offset(7);
        make.width.mas_equalTo(w > 55 ? w : 55);
        make.height.mas_equalTo(12);
    }];
    
    [self.nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImgV);
        make.right.equalTo(self.subsBtn.mas_left).offset(- DWDPaddingMax * 2);
        make.left.equalTo(self.avatarImgV.mas_right).offset(DWDPadding);
        make.height.mas_equalTo(19);
    }];
    
    [self.tagLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLbl);
        make.top.equalTo(self.nameLbl.mas_bottom).mas_offset(6);
        make.width.equalTo(self.nameLbl);
        make.height.mas_equalTo(14);
    }];
    
    [self.updateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.height.equalTo(self.tagLbl);
        make.bottom.equalTo(self.avatarImgV);
    }];
    
    [self.timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).mas_offset(-DWDPaddingMax);
        make.bottom.equalTo(self.avatarImgV);
    }];
    
    [self.unReadLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLbl);
        make.right.equalTo(self).offset(- DWDPaddingMax);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(18);
    }];
}

- (UIImageView *)avatarImgV
{
    if (!_avatarImgV) {
        _avatarImgV = [[UIImageView alloc] init];
        _avatarImgV.layer.masksToBounds = YES;
        _avatarImgV.layer.cornerRadius = 10;
        _avatarImgV.layer.borderWidth = 0.5;
        _avatarImgV.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
        _avatarImgV.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarImgV;
}

- (UILabel *)nameLbl
{
    if (!_nameLbl) {
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.font = DWDScreenW > 320.0f ? [UIFont systemFontOfSize:18.0] : [UIFont systemFontOfSize:17.0];
        _nameLbl.textColor = DWDColorBody;
    }
    return _nameLbl;
}

- (UILabel *)tagLbl
{
    if (!_tagLbl) {
        _tagLbl = [[UILabel alloc] init];
        _tagLbl.font = DWDFontContent;
        _tagLbl.textColor = DWDColorSecondary;
    }
    return _tagLbl;
}

- (UILabel *)updateLbl
{
    if (!_updateLbl) {
        _updateLbl = [[UILabel alloc] init];
        _updateLbl.font = DWDFontContent;
        _updateLbl.textColor = DWDColorSecondary;
    }
    return _updateLbl;
}

- (UILabel *)timeLbl
{
    if (!_timeLbl) {
        _timeLbl = [[UILabel alloc] init];
        _timeLbl.font = DWDFontMin;
        _timeLbl.textColor = DWDColorSecondary;
        _timeLbl.textAlignment = NSTextAlignmentRight;
    }
    return _timeLbl;
}

- (UILabel *)subNumLbl
{
    if (!_subNumLbl) {
        _subNumLbl = [[UILabel alloc] init];
        _subNumLbl.font = DWDFontMin;
        _subNumLbl.textColor = DWDColorSecondary;
        _subNumLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _subNumLbl;
}

- (UILabel *)unReadLbl
{
    if (!_unReadLbl) {
        _unReadLbl = [[UILabel alloc] init];
        _unReadLbl.font = DWDFontMin;
        _unReadLbl.textColor = DWDColorSecondary;
        _unReadLbl.textAlignment = NSTextAlignmentCenter;
        _unReadLbl.layer.cornerRadius = 9.0;
        _unReadLbl.layer.borderWidth = 0.5;
        _unReadLbl.layer.borderColor = DWDColorSecondary.CGColor;
    }
    return _unReadLbl;
}

- (UIButton *)subsBtn
{
    if (!_subsBtn) {
        _subsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subsBtn setTitle:@"订阅" forState:UIControlStateNormal];
        [_subsBtn setTitle:@"已订阅" forState:UIControlStateDisabled];
        [_subsBtn setTitleColor:DWDColorMain forState:UIControlStateNormal];
         [_subsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_subsBtn setTitleColor:DWDColorContent forState:UIControlStateDisabled];
        
        [_subsBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_subsBtn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateHighlighted];
        [_subsBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf5f6f7)] forState:UIControlStateDisabled];
        
        [_subsBtn addTarget:self action:@selector(subsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _subsBtn.layer.masksToBounds = YES;
        _subsBtn.layer.cornerRadius = 5.0;
        _subsBtn.layer.borderColor = DWDColorMain.CGColor;
        _subsBtn.layer.borderWidth = 1.0;
        _subsBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _subsBtn;
}

- (void)subsBtnAction:(UIButton *)sender
{
    sender.enabled = NO;
    if (!sender.enabled) {
        self.subsBtn.enabled = NO;
        _subsBtn.layer.borderColor = UIColorFromRGB(0xf5f6f7).CGColor;
        _subsBtn.layer.borderWidth = 1.0;
    }
    //    self.subscribeBlock ? self.subscribeBlock(self.model.custId) : nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(expertCellDidClickedSubscribeButton:WithExpert:)]) {
        [self.delegate expertCellDidClickedSubscribeButton:sender WithExpert:_model];
    }
}

- (void)setStyle:(ExpertListCellStyle)style
{
    if (style == ExpertListCellStyleNomal) {
        self.subsBtn.hidden = NO;
        self.subNumLbl.hidden = NO;
        self.timeLbl.hidden = YES;
        self.unReadLbl.hidden = YES;
    }else {
        self.subsBtn.hidden = YES;
        self.subNumLbl.hidden = YES;
        self.timeLbl.hidden = NO;
        self.unReadLbl.hidden = NO;
    }
}

- (void)setModel:(DWDInfoExpertModel *)model
{
    _model = model;
    
    if (model.isSub) {
        self.subsBtn.enabled = NO;
        _subsBtn.layer.borderColor = UIColorFromRGB(0xf5f6f7).CGColor;
        _subsBtn.layer.borderWidth = 1.0;
    }else {
        self.subsBtn.enabled = YES;
        _subsBtn.layer.borderColor = DWDColorMain.CGColor;
        _subsBtn.layer.borderWidth = 1.0;
    }
    
    [self.avatarImgV sd_setImageWithURL:[NSURL URLWithString:model.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    self.nameLbl.text = model.name;
    self.tagLbl.text = [[model.tags firstObject] name];
    self.updateLbl.text = model.lastArticle.title;
    self.subNumLbl.text = [NSString stringWithFormat:@"%@已订",[model.subCnt calculateReadCount]];
    self.timeLbl.text = [NSString stringWithTimelineDate:[NSDate dateWithString:model.lastArticle.time format:@"YYYYMMddHHmmss"]];
    
    if ([model.unreadCnt isEqualToNumber:@0] || !model.unreadCnt) {
        self.unReadLbl.hidden = YES;
    }else{
        self.unReadLbl.text = [NSString stringWithFormat:@"未读%@",model.unreadCnt];
        self.unReadLbl.hidden = NO;
    }
    
}

- (void)setIsSub:(BOOL)isSub
{
    _isSub = isSub;
    _model.isSub = isSub;
    
    if (_isSub) {
        _subsBtn.layer.borderColor = UIColorFromRGB(0xf5f6f7).CGColor;
        _subsBtn.layer.borderWidth = 1.0;
        
        self.subsBtn.enabled = NO;
    }else {
        self.subsBtn.enabled = YES;
        _subsBtn.layer.borderColor = DWDColorMain.CGColor;
        _subsBtn.layer.borderWidth = 1.0;

    }
}

@end
