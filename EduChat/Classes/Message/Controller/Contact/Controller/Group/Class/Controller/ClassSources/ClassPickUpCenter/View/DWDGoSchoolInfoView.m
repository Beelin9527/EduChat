//
//  DWDGoSchoolInfoView.m
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kContentText 16
#define kContentTextColor DWDRGBColor(51, 51, 51)

#define kSecondText 14
#define kSecondTextColor DWDRGBColor(153, 153, 153)


#import "DWDGoSchoolInfoView.h"

#import "DWDTeacherGoSchoolInfoModel.h"

#import <Masonry.h>

@interface DWDGoSchoolInfoView ()
@property (nonatomic, weak) UILabel *totalStudentsLabel;
@property (nonatomic, weak) UILabel *succeedCountLabel;
@property (nonatomic, weak) UILabel *vacateCountLabel;
@property (nonatomic, weak) UILabel *attendanceRateLabel;
@end

@implementation DWDGoSchoolInfoView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    

    self.backgroundColor = [UIColor whiteColor];
    UILabel *totalStudentsLabel = [UILabel new];
    totalStudentsLabel.font = [UIFont systemFontOfSize:kContentText];
    totalStudentsLabel.textColor = kContentTextColor;
    self.totalStudentsLabel = totalStudentsLabel;
    [self addSubview:totalStudentsLabel];
    
    UIView *lineView0 = [UIView new];
    lineView0.backgroundColor = UIColorFromRGB(0xdddddd);
    [self addSubview:lineView0];
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = UIColorFromRGB(0xdddddd);
    [self addSubview:lineView1];
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = UIColorFromRGB(0xdddddd);
    [self addSubview:lineView2];
    
    UILabel *succeedCountlabel = [UILabel new];
    succeedCountlabel.font = [UIFont systemFontOfSize:kContentText];
    succeedCountlabel.textColor = kContentTextColor;
    self.succeedCountLabel = succeedCountlabel;
    [self addSubview:succeedCountlabel];
    
    UILabel *vacateCountLabel = [UILabel new];
    vacateCountLabel.font = [UIFont systemFontOfSize:kContentText];
    vacateCountLabel.textColor = kContentTextColor;
    self.vacateCountLabel = vacateCountLabel;
    [self addSubview:vacateCountLabel];
    
    
    UILabel *attendanceRatelabel = [UILabel new];
    attendanceRatelabel.font = [UIFont systemFontOfSize:kContentText];
    attendanceRatelabel.textColor = [UIColor redColor];
    self.attendanceRateLabel = attendanceRatelabel;
    [self addSubview:attendanceRatelabel];
    
    
    UILabel *totalStudentsLabel1 = [UILabel new];
    totalStudentsLabel1.font = [UIFont systemFontOfSize:kSecondText];
    totalStudentsLabel1.textColor = kSecondTextColor;
    totalStudentsLabel1.text = @"学生总数";
    [totalStudentsLabel1 sizeToFit];
    [self addSubview:totalStudentsLabel1];
    
    UILabel *succeedCountlabel1 = [UILabel new];
    succeedCountlabel1.font = [UIFont systemFontOfSize:kSecondText];
    succeedCountlabel1.textColor = kSecondTextColor;
    succeedCountlabel1.text = @"出勤";
    [succeedCountlabel1 sizeToFit];
    [self addSubview:succeedCountlabel1];
    
    UILabel *vacateCountLabel1 = [UILabel new];
    vacateCountLabel1.font = [UIFont systemFontOfSize:kSecondText];
    vacateCountLabel1.textColor = kSecondTextColor;
    vacateCountLabel1.text = @"请假";
    [vacateCountLabel1 sizeToFit];
    [self addSubview:vacateCountLabel1];

    UILabel *attendanceRatelabel1 = [UILabel new];
    attendanceRatelabel1.font = [UIFont systemFontOfSize:kSecondText];
    attendanceRatelabel1.textColor = kSecondTextColor;
    attendanceRatelabel1.text = @"出勤率";
    [attendanceRatelabel1 sizeToFit];
    [self addSubview:attendanceRatelabel1];
    

    
    
    [totalStudentsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(DWDScreenW * 0.125);
        make.centerY.mas_equalTo(frame.size.height * 0.25);
    }];
    [totalStudentsLabel1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(totalStudentsLabel);
        make.centerY.mas_equalTo(frame.size.height * 0.75);
    }];
    [lineView0 makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(pxToH(48));
        make.centerY.mas_equalTo(frame.size.height * 0.5);
        make.centerX.mas_equalTo(DWDScreenW * 0.25);
    }];
    
    [succeedCountlabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(DWDScreenW * 0.375);
        make.centerY.equalTo(totalStudentsLabel);
    }];
    [succeedCountlabel1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(succeedCountlabel);
        make.centerY.equalTo(totalStudentsLabel1);
    }];
    [lineView1 makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(pxToH(48));
        make.centerY.mas_equalTo(frame.size.height * 0.5);
        make.centerX.mas_equalTo(DWDScreenW * 0.5);
    }];
 
    [vacateCountLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(DWDScreenW * 0.625);
        make.centerY.equalTo(totalStudentsLabel);
    }];
    [vacateCountLabel1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(vacateCountLabel);
        make.centerY.equalTo(totalStudentsLabel1);
    }];
    [lineView2 makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(pxToH(48));
        make.centerY.mas_equalTo(frame.size.height * 0.5);
        make.centerX.mas_equalTo(DWDScreenW * 0.75);
    }];
 
    [attendanceRatelabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(DWDScreenW * 0.875);
        make.centerY.equalTo(totalStudentsLabel);
    }];
    [attendanceRatelabel1 makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(attendanceRatelabel);
        make.centerY.equalTo(totalStudentsLabel1);
    }];
    
    [super updateConstraints];
    
    return self;
}

- (void)setInfoModel:(DWDTeacherGoSchoolInfoModel *)infoModel {
    _infoModel = infoModel;
//        @property (nonatomic, weak) UILabel *totalStudentsLabel;
//        @property (nonatomic, weak) UILabel *succeedCountLabel;
//        @property (nonatomic, weak) UILabel *vacateCountLabel;
//        @property (nonatomic, weak) UILabel *attendanceRateLabel;
    _totalStudentsLabel.text = [NSString stringWithFormat:@"%ld 人", (unsigned long)infoModel.totalStudent];
    _succeedCountLabel.text = [NSString stringWithFormat:@"%ld 人", (unsigned long)infoModel.succeedCount];
    _vacateCountLabel.text = [NSString stringWithFormat:@"%ld 人", (unsigned long)infoModel.vacateCount];
    _attendanceRateLabel.text = [NSString stringWithFormat:@"%.1f %%", isnan(infoModel.attendanceRate * 100) ? 0.0f : infoModel.attendanceRate * 100];
//    [super updateConstraints];
}
@end
