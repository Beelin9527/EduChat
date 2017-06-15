//
//  DWDMsgRecordCell.m
//  EduChat
//
//  Created by apple on 16/4/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMsgRecordCell.h"
#import <Masonry.h>

@interface DWDMsgRecordCell ()

@property (nonatomic, strong) UIImageView *avatarImgV;
@property (nonatomic, strong) UILabel *nickNameLbl;
@property (nonatomic, strong) UILabel *contentLbl;
@property (nonatomic, strong) UILabel *dateLbl;

@end

@implementation DWDMsgRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    [self.contentView addSubview:self.avatarImgV];
    [self.contentView addSubview:self.nickNameLbl];
    [self.contentView addSubview:self.contentLbl];
    [self.contentView addSubview:self.dateLbl];
    
    self.avatarImgV.backgroundColor = [UIColor greenColor];
    self.nickNameLbl.backgroundColor = [UIColor blueColor];
    self.contentLbl.backgroundColor = [UIColor brownColor];
    self.dateLbl.backgroundColor = [UIColor redColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.avatarImgV makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(pxToW(20));
        make.top.equalTo(self.contentView).offset(pxToW(20));
        make.width.height.mas_equalTo(pxToW(100));
    }];
    
    [self.nickNameLbl makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImgV.right).offset(pxToW(20));
        make.top.equalTo(self.contentView).offset(pxToW(30));
        make.width.mas_equalTo(DWDScreenW - 170);
        make.height.mas_equalTo(14);
    }];
    
    [self.dateLbl makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickNameLbl);
        make.right.equalTo(self).offset(pxToW(-20));
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(70);
    }];
    
    [self.contentView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickNameLbl).offset(14);
    }];
}

- (UIImageView *)avatarImgV
{
    if (!_avatarImgV) {
        _avatarImgV = [[UIImageView alloc] init];
        _avatarImgV.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatarImgV;
}

- (UILabel *)nickNameLbl
{
    if (!_nickNameLbl) {
        _nickNameLbl = [[UILabel alloc] init];
        _nickNameLbl.font = DWDFontContent;
        _nickNameLbl.textColor = DWDColorContent;
    }
    return _nickNameLbl;
}

- (UILabel *)contentLbl
{
    if (!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.font = DWDFontContent;
        _contentLbl.textColor = DWDColorBody;
        _contentLbl.numberOfLines = 0;
    }
    return _contentLbl;
}

- (UILabel *)dateLbl
{
    if (!_dateLbl) {
        _dateLbl = [[UILabel alloc] init];
        _dateLbl.font = DWDFontMin;
        _dateLbl.textColor = DWDColorSecondary;
    }
    return _dateLbl;
}



@end
