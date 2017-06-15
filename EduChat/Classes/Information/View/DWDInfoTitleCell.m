//
//  DWDInfoTitleCell.m
//  EduChat
//
//  Created by Catskiy on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoTitleCell.h"

@interface DWDInfoTitleCell ()
{
    UIImageView *_iconImgV;
    UILabel *_titleLbl;
    UILabel *_moreLbl;
}
@end

@implementation DWDInfoTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.separatorInset = UIEdgeInsetsMake(0, DWDScreenW, 0, 0);
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    _iconImgV = [[UIImageView alloc] init];
    _iconImgV.layer.masksToBounds = YES;
    _iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_iconImgV];
    
    _titleLbl = [[UILabel alloc] init];
    _titleLbl.font = [UIFont boldSystemFontOfSize:14];
    _titleLbl.textColor = DWDRGBColor(34, 34, 34);
    [self addSubview:_titleLbl];
    
    _moreLbl = [[UILabel alloc] init];
    _moreLbl.font = DWDFontMin;
    _moreLbl.textColor = DWDColorContent;
    _moreLbl.textAlignment = NSTextAlignmentRight;
    _moreLbl.userInteractionEnabled = YES;
    [self addSubview:_moreLbl];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreLblAction:)];
    [_moreLbl addGestureRecognizer:tap];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _iconImgV.frame = CGRectMake(DWDPadding, 12, 20, 20);
    _moreLbl.frame = CGRectMake(DWDScreenW - 67, 12, 50, 20);
    _titleLbl.frame = CGRectMake(CGRectGetMaxX(_iconImgV.frame) + 6, 12, DWDScreenW - 100, 20);
    
//    _iconImgV.frame = CGRectMake(DWDPadding, (self.h - 22) * 0.5, 22, 22);
//    _moreLbl.frame = CGRectMake(DWDScreenW - 67, 0, 50, self.h);
//    _titleLbl.frame = CGRectMake(CGRectGetMaxX(_iconImgV.frame) + 6, 0, DWDScreenW - 100, self.h);

}

- (void)moreLblAction:(UITapGestureRecognizer *)tap
{
    self.moreBlock ? self.moreBlock() : nil;
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle image:(UIImage *)image
{
    _titleLbl.text = title;
    _moreLbl.text = subTitle;
    _iconImgV.image = image;
    
    if ([subTitle isEqualToString:@""]) {
        _moreLbl.hidden = YES;
    }else {
        _moreLbl.hidden = NO;
    }
}

- (void)hideSubTitle:(BOOL)ishide
{
    if (ishide) {
        _moreLbl.hidden = YES;
    }else {
        _moreLbl.hidden = NO;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
