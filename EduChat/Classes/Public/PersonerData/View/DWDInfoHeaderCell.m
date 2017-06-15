//
//  DWDInfoHeaderCell.m
//  EduChat
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoHeaderCell.h"

@interface DWDInfoHeaderCell ()

@property (nonatomic, strong) UIImageView *avatarImgV;
@property (nonatomic, strong) UILabel *nicknameLbl;
@property (nonatomic, strong) UIButton *addBtn;

@end

@implementation DWDInfoHeaderCell

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
    [self.contentView addSubview:self.nicknameLbl];
    [self.contentView addSubview:self.addBtn];
    
//    self.avatarImgV.backgroundColor = [UIColor greenColor];
//    self.nicknameLbl.backgroundColor = [UIColor redColor];
//    self.addBtn.backgroundColor = [UIColor blueColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarImgV.frame = CGRectMake(10.0f, 10.0f, 40.0f, 40.0f);
    self.nicknameLbl.frame = CGRectMake(self.avatarImgV.x, self.avatarImgV.y + self.avatarImgV.h + 2.5f, self.avatarImgV.w, 14.0);
    self.addBtn.frame = CGRectMake(self.avatarImgV.x + self.avatarImgV.w + 15.0f, 10.0f, 40.0f, 40.0f);
}

- (void)setAvatarImg:(NSString *)avatarImg
{
    [self.avatarImgV sd_setImageWithURL:[NSURL URLWithString:avatarImg] placeholderImage:DWDDefault_MeBoyImage];
}

- (void)setNickName:(NSString *)nickName
{
    self.nicknameLbl.text = nickName;
}

- (UIImageView *)avatarImgV
{
    if (!_avatarImgV) {
        _avatarImgV = [[UIImageView alloc] init];
        _avatarImgV.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImgV.layer.masksToBounds = YES;
    }
    return _avatarImgV;
}

- (UILabel *)nicknameLbl
{
    if (!_nicknameLbl) {
        _nicknameLbl = [[UILabel alloc] init];
        _nicknameLbl.font = [UIFont systemFontOfSize:12];
        _nicknameLbl.textColor = DWDColorSecondary;
    }
    return _nicknameLbl;
}

- (UIButton *)addBtn
{
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] init];
        [_addBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_normal"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(addBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}

- (void)addBtnAction:(UIButton *)sender
{
    if (self.addContactBlock) {
        self.addContactBlock();
    }
}

@end
