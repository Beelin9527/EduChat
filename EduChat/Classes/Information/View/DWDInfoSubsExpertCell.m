//
//  DWDInfoSubsExpertCell.m
//  EduChat
//
//  Created by Catskiy on 16/8/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoSubsExpertCell.h"

@implementation DWDInfoSubsExpertCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setSubviews];
       
    }
    return self;
}

- (void)setSubviews
{
    CGFloat itemW = (DWDScreenW - 2 * 27.0/2.0 - 2 * 30.0/2 - 28/2) / 4;
    
    for (int i = 0; i < 4; i++) {
        
        DWDInfoExpertAvatarView *expertView = [[DWDInfoExpertAvatarView alloc] initWithFrame:CGRectMake(15 + i * (itemW + 27/2.0), 18.0, itemW, itemW)];
        expertView.tag = 999 + i;
        [expertView setSubsExpertViewBlock:^(NSNumber *expertId) {
             self.subsExpertCellBlock ? self.subsExpertCellBlock(expertId) : nil;
        }];
        [self.contentView addSubview:expertView];
    }
}

- (void)setExperts:(NSArray *)experts
{
    _experts = experts;
    for (int i = 0; i < 4; i ++) {
        
        DWDInfoExpertAvatarView *expertView = [self.contentView viewWithTag:999 + i];
        if (i >= experts.count) {
            [expertView setHidden:YES];
            continue;
        }
        DWDInfoExpertModel *model = experts[i];
        expertView.expert = model;
        [expertView setHidden:NO];
    }
}

- (void)addOneExpert:(DWDInfoExpertModel *)expert
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        for (int i = 0; i < 3; i ++ ) {
            DWDInfoExpertAvatarView *expertView = [self.contentView viewWithTag:999 + i];
            expertView.x += (DWDScreenW - 2 * 27.0/2.0 - 2 * 30.0/2 - 28/2) / 4 + 19.0;
            expertView.tag = 999 + i + 1;
        }
    } completion:^(BOOL finished) {
        DWDInfoExpertAvatarView *expertView = [self.contentView viewWithTag:999 + 5];
        expertView.x = 27.0;
        expertView.expert = expert;
        expertView.hidden = NO;
        expertView.tag = 999;
    }];
}

+ (CGFloat)getHeight
{
    return (DWDScreenW - 2 * 27.0/2.0 - 2 * 30.0/2 - 28/2) / 4 + 18.0 + 38.0;
}

@end




@implementation DWDInfoExpertAvatarView
{
    UIImageView *_avatarImgV;
    UILabel *_nameLbl;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CGFloat itemW = (DWDScreenW - 2 * 27.0/2.0 - 2 * 30.0/2 - 28/2) / 4;
        
        self.w = itemW;
        self.h = itemW + 19.0;
        
        _avatarImgV = [[UIImageView alloc] init];
        _avatarImgV.frame = CGRectMake(0, 0, itemW, itemW);
        _avatarImgV.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImgV.layer.cornerRadius = 10; //itemW * 0.5;
        _avatarImgV.layer.masksToBounds = YES;
        _avatarImgV.layer.borderWidth = 0.5;
        _avatarImgV.layer.borderColor = UIColorFromRGB(0xeeeeee).CGColor;
        [self addSubview:_avatarImgV];
        
        _nameLbl = [[UILabel alloc] init];
        _nameLbl.frame = CGRectMake(0, CGRectGetMaxY(_avatarImgV.frame) + 7.0, _avatarImgV.w, 12);
        _nameLbl.userInteractionEnabled = YES;
        _nameLbl.textAlignment = NSTextAlignmentCenter;
        _nameLbl.textColor = DWDColorBody;
        _nameLbl.font = DWDFontContent;
        [self addSubview:_nameLbl];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setExpert:(DWDInfoExpertModel *)expert
{
    _expert = expert;
    [_avatarImgV sd_setImageWithURL:[NSURL URLWithString:expert.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    _nameLbl.text = expert.name;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    self.subsExpertViewBlock ? self.subsExpertViewBlock(_expert.custId) : nil;
}

@end
