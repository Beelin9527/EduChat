//
//  DWDTeacherGoSchoolFailedDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherGoSchoolFailedDetailView.h"

#import "DWDTeacherGoSchoolStudentDetailModel.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface DWDTeacherGoSchoolFailedDetailView ()

@property (nonatomic, weak) UIImageView *studentImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *detailButton;

@end

@implementation DWDTeacherGoSchoolFailedDetailView

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
    
    CGFloat picWidth = (DWDScreenW - pxToW(60)) / 4.0;
    CGFloat picHeight = picWidth;
    [studentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.width.mas_equalTo(picWidth);
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
                         placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    _nameLabel.text = dataModel.name;
    if (dataModel.leave == 0) {
        [_detailButton setTitle:@"未到达" forState:UIControlStateNormal];
        [_detailButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(153, 153, 153)] forState:UIControlStateNormal];
        [_detailButton setImage:[UIImage imageNamed:@"MSG_TF_Not_arrived"] forState:UIControlStateNormal];
    } else if (dataModel.leave == 1){
        [_detailButton setTitle:@"事假" forState:UIControlStateNormal];
        [_detailButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(249, 98, 105)] forState:UIControlStateNormal];
        [_detailButton setImage:[UIImage imageNamed:@"MSG_TF_leave"] forState:UIControlStateNormal];
    } else if (dataModel.leave == 2) {
        [_detailButton setTitle:@"病假" forState:UIControlStateNormal];
        [_detailButton setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(249, 98, 105)] forState:UIControlStateNormal];
        [_detailButton setImage:[UIImage imageNamed:@"MSG_TF_leave"] forState:UIControlStateNormal];
    }
    [super updateConstraints];
}

@end
