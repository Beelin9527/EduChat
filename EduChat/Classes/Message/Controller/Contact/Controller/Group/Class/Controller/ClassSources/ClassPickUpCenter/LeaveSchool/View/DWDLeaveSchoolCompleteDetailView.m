//
//  DWDLeaveSchoolCompleteDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLeaveSchoolCompleteDetailView.h"

#import "DWDPickUpCenterDataBaseModel.h"

#import "NSString+extend.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface DWDLeaveSchoolCompleteDetailView ()

@property (nonatomic, weak) UIImageView *studentImageView;
@property (nonatomic, weak) UIImageView *parentImageView;
@property (nonatomic, weak) UILabel *studentLabel;
@property (nonatomic, weak) UILabel *parentLabel;
@property (nonatomic, weak) UIButton *detailButton;

@end

@implementation DWDLeaveSchoolCompleteDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.14f;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOffset = CGSizeMake(-pxToW(3), pxToW(3));
    self.clipsToBounds = NO;

    
    UIImageView *studentImageView = [UIImageView new];
    [self addSubview:studentImageView];
    self.studentImageView = studentImageView;
    
    CGFloat picWidth = (DWDScreenW - pxToW(62)) / 4.0;
    CGFloat picHeight = picWidth;
    [studentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.width.mas_equalTo(picWidth);
        make.height.mas_equalTo(picHeight);
    }];
    
    
    UIImageView *parentImageView = [UIImageView new];
    [self addSubview:parentImageView];
    self.parentImageView = parentImageView;
    [parentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(studentImageView.right);
        make.right.equalTo(self);
        make.width.equalTo(studentImageView.width);
        make.height.mas_equalTo(picHeight);
    }];
    
    UILabel *studentLabel = [UILabel new];
    studentLabel.font = DWDFontContent;
    studentLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:studentLabel];
    self.studentLabel = studentLabel;
    [studentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(studentImageView.bottom).offset(pxToH(12));
        make.left.equalTo(self);
    }];
    
    UILabel *parentlabel = [UILabel new];
    parentlabel.font = DWDFontContent;
    parentlabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:parentlabel];
    self.parentLabel = parentlabel;
    [parentlabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.parentImageView.bottom).offset(pxToH(12));
        make.left.equalTo(studentLabel.right);
        make.right.equalTo(self);
    }];

    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:detailButton];
    self.detailButton = detailButton;
    [detailButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(studentLabel.bottom).offset(pxToH(12));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    [super updateConstraints];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width + pxToW(6), self.bounds.size.height)].CGPath;
}

#pragma mark - Private Method
- (void)detailButtonClick:(UIButton *)button {
    DWDMarkLog(@"Surprise");
}

#pragma mark - Setter / Getter
- (void)setDataModel:(DWDPickUpCenterDataBaseModel *)dataModel {
    _dataModel = dataModel;
    
    [_studentImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photokey]
                         placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    [_parentImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photo]
                        placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    _studentLabel.text = dataModel.name;

    if ([dataModel.contextual isEqualToString:@"Getoutschool"]) {
        //校门
        [_detailButton setImage:[UIImage imageNamed:@"MSG_TF_Door"] forState:UIControlStateNormal];
        [_detailButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(79, 211, 190)] forState:UIControlStateNormal];
        
        _parentLabel.text = [NSString parentRelationStringWithRelation:dataModel.relation];
        [_parentLabel updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo((DWDScreenW - pxToW(62)) / 4.0);
        }];
    }
    else {
        //校车
        [_detailButton setImage:[UIImage imageNamed:@"OffAfterschoolBus"] forState:UIControlStateNormal];
        [_detailButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(246, 186, 90)] forState:UIControlStateNormal];
        
        _parentLabel.text = nil;
        [_parentLabel updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
    
    [_detailButton setTitle:dataModel.time forState:UIControlStateNormal];
    [_detailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [super updateConstraints];
}

@end
