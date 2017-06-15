//
//  DWDTeacherGoSchoolSucceedDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherGoSchoolSucceedDetailView.h"
#import "DWDTeacherGoSchoolStudentDetailModel.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface DWDTeacherGoSchoolSucceedDetailView ()

@property (nonatomic, weak) UIImageView *studentImageView;
@property (nonatomic, weak) UIImageView *livingImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *detailButton;
@end

@implementation DWDTeacherGoSchoolSucceedDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    
//    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 200, 200)].CGPath;
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
    
    
    UIImageView *livingImageView = [UIImageView new];
    [self addSubview:livingImageView];
    self.livingImageView = livingImageView;
    [livingImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(studentImageView.right);
        make.right.equalTo(self);
        make.width.equalTo(studentImageView.width);
        make.height.mas_equalTo(picHeight);
    }];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = DWDFontContent;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(studentImageView.bottom).offset(pxToH(12));
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    detailButton.userInteractionEnabled = NO;
    [self addSubview:detailButton];
    self.detailButton = detailButton;
    [detailButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.bottom).offset(pxToH(12));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width + pxToW(6), self.bounds.size.height)].CGPath;
}

- (void)setDataModel:(DWDTeacherGoSchoolStudentDetailModel *)dataModel {
    _dataModel = dataModel;
    
    [_studentImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photohead.photoKey]
                         placeholderImage:[UIImage imageNamed:@"MSG_TF_head_placeholder"]];
    [_livingImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.punchPhoto.photoKey]
                        placeholderImage:[UIImage imageNamed:@"MSG_TF_head_placeholder"]];
    _nameLabel.text = dataModel.name;
#warning deal with image type must change data model in controller!
    [_detailButton setImage:[UIImage imageNamed:@"MSG_TF_Door"] forState:UIControlStateNormal];
    [_detailButton setTitle:@"已到学校" forState:UIControlStateNormal];
    [_detailButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(254, 179, 88)] forState:UIControlStateNormal];
//    [super updateConstraints];

}

@end
