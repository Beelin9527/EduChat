//
//  DWDIntHeaderClassInfoCell.m
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntHeaderClassInfoCell.h"

#import "DWDClassModel.h"

#import <Masonry/Masonry.h>
#import <UIButton+WebCache.h>

@interface DWDIntHeaderClassInfoCell ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *headerBgImv;
@property (nonatomic, strong) UIButton *avatarBtn;
@property (nonatomic, strong) UILabel *className;
@property (nonatomic, strong) UIImageView *announceImv;
@property (nonatomic, strong) UIButton *introBtn;

@property (nonatomic, strong) CAGradientLayer *gradient;
@end

@implementation DWDIntHeaderClassInfoCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"DWDIntHeaderClassInfoCell";
    DWDIntHeaderClassInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDIntHeaderClassInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.headerView addSubview:self.headerBgImv];
        [self.headerView addSubview:self.avatarBtn];
        [self.headerView addSubview:self.className];
        [self.headerView addSubview:self.announceImv];
        [self.headerView addSubview:self.introBtn];
        
        [self.contentView addSubview:self.headerView];
        
        [self layoutControls];
        
    }
    return self;
}


#pragma mark - Layout
- (void)layoutControls{
    [self.introBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.width.mas_lessThanOrEqualTo(DWDScreenW - 100);
        make.height.mas_equalTo(14);
        make.bottom.equalTo(self.headerView).mas_offset(-15);
    }];
    [self.announceImv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.introBtn.left).mas_offset(-5);
        make.centerY.equalTo(self.introBtn);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [self.className mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.bottom.equalTo(self.announceImv.mas_top).mas_offset(-15);
    }];
    [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.bottom.equalTo(self.className.mas_top).mas_offset(-10);
        make.width.height.mas_equalTo(64);
    }];
}

#pragma mark - Setter
- (void)setHeadertype:(HeaderType)headertype{
    _headertype = headertype;
    
    if (_headertype == DWDClassManagerHeaderType) {
        self.headerView.frame = CGRectMake(0, 0, DWDScreenW, 350/2.0);
        self.gradient.frame = self.headerView.bounds;
        self.headerBgImv.frame = self.headerView.bounds;
        self.headerBgImv.image = [UIImage imageNamed:@"img_bg_class"];
    }else{
        self.headerView.frame = CGRectMake(0, 0, DWDScreenW, 426/2.0);
        self.gradient.frame = self.headerView.bounds;
        self.headerBgImv.frame = self.headerView.bounds;
        self.headerBgImv.image = [UIImage imageNamed:@"img_bg_class_home"];
    }
}

#pragma mark - Setter
- (void)setClassModel:(DWDClassModel *)classModel{
    _classModel = classModel;
    
    [self.avatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:_classModel.photoKey] forState:UIControlStateNormal placeholderImage:DWDDefault_GradeImage];

    self.className.text = _classModel.className ? _classModel.className : @"多维度1班";
    if ([_classModel.introduce isEqualToString:@""] || !_classModel.introduce) {
        [self.introBtn setTitle:@"家校管理专家，构建“智慧校园”。" forState: UIControlStateNormal];
    }else{
        [self.introBtn setTitle:_classModel.introduce forState: UIControlStateNormal];
    }
}

#pragma mark - Getter

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        CAGradientLayer *gradientLayerTop = [CAGradientLayer layer];  // 设置渐变效果
        _gradient = gradientLayerTop;
        gradientLayerTop.borderWidth = 0;
        gradientLayerTop.colors = [NSArray arrayWithObjects:
                                   (id)UIColorFromRGB(0x5a88e7).CGColor,
                                   (id)UIColorFromRGB(0x5cd9e8).CGColor, nil];
        gradientLayerTop.startPoint = CGPointMake(0.5, 0.0);
        gradientLayerTop.endPoint = CGPointMake(0.5, 1.0);
        [_headerView.layer addSublayer:gradientLayerTop];

    }
    return _headerView;
}
- (UIImageView *)headerBgImv{
    if (!_headerBgImv) {
        _headerBgImv = [[UIImageView alloc] init];
        
    }
    return _headerBgImv;
}

- (UIButton *)avatarBtn{
    if (!_avatarBtn) {
        _avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarBtn.layer.masksToBounds = YES;
        _avatarBtn.layer.cornerRadius = 64/2.0;
        _avatarBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatarBtn.layer.borderWidth = 2;
        [_avatarBtn addTarget:self action:@selector(clickAvatar) forControlEvents:UIControlEventTouchDown];
    }
    return _avatarBtn;
}
- (UILabel *)className{
    if (!_className) {
        _className = [[UILabel alloc] init];
        _className.textColor = [UIColor whiteColor];
        _className.font = [UIFont systemFontOfSize:18];
        _className.textAlignment = NSTextAlignmentCenter;
    }
    return _className;
}
- (UIImageView *)announceImv{
    if (!_announceImv) {
        _announceImv = [[UIImageView alloc] init];
        _announceImv.image = [UIImage imageNamed:@"ic_declaration"];

    }
    return _announceImv;
}

- (UIButton *)introBtn{
    if (!_introBtn) {
        _introBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_introBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _introBtn.titleLabel.font = DWDFontContent;
        _introBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;;
        [_introBtn addTarget:self action:@selector(clickIntro) forControlEvents:UIControlEventTouchDown];
    }
    return _introBtn;
}

#pragma mark - Event Response
- (void)clickAvatar{
    if (!self.classModel) return;
    //管理者可以更新班级头像
    if ([self.classModel.isManager isEqualToNumber:@1]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(intHeaderClassInfoCellClickAvatar:)]) {
            [self.delegate intHeaderClassInfoCellClickAvatar:self];
        }
    }
}
- (void)clickIntro{
    if (!self.classModel) return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(intHeaderClassInfoCell:clickIntroWithClassModel:)]) {
        [self.delegate intHeaderClassInfoCell:self clickIntroWithClassModel:self.classModel];
    }
}

@end
