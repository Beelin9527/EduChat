//
//  DWDPickUpCenterTimeLineHeaderView.m
//  EduChat
//
//  Created by KKK on 16/4/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kNumberFontSize 16
#define kTextFontSize 14

#define kNameColor DWDRGBColor(51, 51, 51)
#define kTextColor DWDRGBColor(153, 153, 153)

#import "DWDPickUpCenterTimeLineHeaderView.h"
#import "DWDGoSchoolInfoView.h"
#import "NSString+extend.h"

#import <Masonry.h>

@interface DWDPickUpCenterTimeLineHeaderView ()
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *typeLabel;
@property (nonatomic, weak) UILabel *succeedCountLabel;
@property (nonatomic, weak) UILabel *vacateCountLabel;
@property (nonatomic, weak) UILabel *notCompleteLabel;
@end

@implementation DWDPickUpCenterTimeLineHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UILabel *timeLabel = [UILabel new];
    timeLabel.font = [UIFont systemFontOfSize:kNumberFontSize];
    timeLabel.textColor = kNameColor;
    self.timeLabel = timeLabel;
    [self addSubview:timeLabel];
    
    UIView *lineView0 = [UIView new];
    lineView0.backgroundColor = UIColorFromRGB(0xcccccc);
    [self addSubview:lineView0];
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = UIColorFromRGB(0xcccccc);
    [self addSubview:lineView1];
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = UIColorFromRGB(0xcccccc);
    [self addSubview:lineView2];
    
    UILabel *succeedCountlabel = [UILabel new];
    succeedCountlabel.font = [UIFont systemFontOfSize:kNumberFontSize];
    self.succeedCountLabel = succeedCountlabel;
    [self addSubview:succeedCountlabel];
    
    UILabel *vacateCountLabel = [UILabel new];
    vacateCountLabel.font = [UIFont systemFontOfSize:kNumberFontSize];
    self.vacateCountLabel = vacateCountLabel;
    [self addSubview:vacateCountLabel];
    
    
    UILabel *notCompleteLabel = [UILabel new];
    notCompleteLabel.font = [UIFont systemFontOfSize:kNumberFontSize];
    self.notCompleteLabel = notCompleteLabel;
    [self addSubview:notCompleteLabel];
    
    
    UILabel *typeLabel = [UILabel new];
    typeLabel.font = [UIFont systemFontOfSize:kTextFontSize];
    typeLabel.textColor = kNameColor;
    [typeLabel sizeToFit];
    self.typeLabel = typeLabel;
    [self addSubview:typeLabel];
    
    UILabel *succeedCountlabel1 = [UILabel new];
    succeedCountlabel1.font = [UIFont systemFontOfSize:kTextFontSize];
    succeedCountlabel1.textColor = kTextColor;
    succeedCountlabel1.text = @"出勤";
    [succeedCountlabel1 sizeToFit];
    [self addSubview:succeedCountlabel1];
    
    UILabel *vacateCountLabel1 = [UILabel new];
    vacateCountLabel1.font = [UIFont systemFontOfSize:kTextFontSize];
    vacateCountLabel1.textColor = kTextColor;
    vacateCountLabel1.text = @"请假";
    [vacateCountLabel1 sizeToFit];
    [self addSubview:vacateCountLabel1];
    
    UILabel *notCompleteLabel1 = [UILabel new];
    notCompleteLabel1.font = [UIFont systemFontOfSize:kTextFontSize];
    notCompleteLabel1.textColor = kTextColor;
    notCompleteLabel1.text = @"未到";
    [notCompleteLabel1 sizeToFit];
    [self addSubview:notCompleteLabel1];
    
    
    
    
//    [timeLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.frame.size.width * 0.125);
//        make.centerY.mas_equalTo(self.frame.size.height * 0.25);
//    }];
//    [typeLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(timeLabel);
//        make.centerY.mas_equalTo(self.frame.size.height * 0.75);
//    }];
//    [lineView0 makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(1);
//        make.height.mas_equalTo(pxToH(48));
//        make.centerY.mas_equalTo(self.frame.size.height * 0.5);
//        make.centerX.mas_equalTo(self.frame.size.width * 0.25);
//    }];
//    [succeedCountlabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.frame.size.width * 0.375);
//        make.centerY.equalTo(timeLabel);
//    }];
//    [succeedCountlabel1 makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(succeedCountlabel);
//        make.centerY.equalTo(typeLabel);
//    }];
//    [lineView1 makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(1);
//        make.height.mas_equalTo(pxToH(48));
//        make.centerY.mas_equalTo(self.frame.size.height * 0.5);
//        make.centerX.mas_equalTo(self.frame.size.width * 0.5);
//    }];
//    [vacateCountLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.frame.size.width * 0.625);
//        make.centerY.equalTo(timeLabel);
//    }];
//    [vacateCountLabel1 makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(vacateCountLabel);
//        make.centerY.equalTo(typeLabel);
//    }];
//    [lineView2 makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(1);
//        make.height.mas_equalTo(pxToH(48));
//        make.centerY.mas_equalTo(self.frame.size.height * 0.5);
//        make.centerX.mas_equalTo(self.frame.size.width * 0.75);
//    }];
//    [notCompleteLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.frame.size.width * 0.875);
//        make.centerY.equalTo(timeLabel);
//    }];
//    [notCompleteLabel1 makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(notCompleteLabel);
//        make.centerY.equalTo(typeLabel);
//    }];
//    [super updateConstraints];
    lineView0.frame = CGRectMake(0, 0, 1, pxToH(48));
    lineView0.center = CGPointMake(frame.size.width * 0.25, frame.size.height * 0.5);
    
    lineView1.frame = CGRectMake(0, 0, 1, pxToH(48));
    lineView1.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
    
    lineView2.frame = CGRectMake(0, 0, 1, pxToH(48));
    lineView2.center = CGPointMake(frame.size.width * 0.75, frame.size.height * 0.5);
    
    
    

    succeedCountlabel1.center = CGPointMake(frame.size.width * 0.375, frame.size.height * 0.75);
    
    vacateCountLabel1.center = CGPointMake(frame.size.width * 0.625, frame.size.height * 0.75);
    
    
    notCompleteLabel1.center = CGPointMake(frame.size.width * 0.875, frame.size.height * 0.75);
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _timeLabel.center = CGPointMake(self.frame.size.width * 0.125, self.frame.size.height * 0.25);
    _typeLabel.center = CGPointMake(self.frame.size.width * 0.125, self.frame.size.height * 0.75);
    
    _succeedCountLabel.center = CGPointMake(self.frame.size.width * 0.375, self.frame.size.height * 0.25);
    _vacateCountLabel.center = CGPointMake(self.frame.size.width * 0.625, self.frame.size.height * 0.25);
    _notCompleteLabel.center = CGPointMake(self.frame.size.width * 0.875, self.frame.size.height * 0.25);
}

- (void)setLabelsTextWithTime:(NSString *)time
                         type:(NSInteger)type
                 succeedCount:(NSInteger)succeedCount
                  vacateCount:(NSInteger)vacateCount
             notCompleteCount:(NSInteger)notComplete {
    _timeLabel.text = [time hourMinuteString];
    [_timeLabel sizeToFit];
    
    NSString *typeStr;
    //判断上午下午
    NSDateFormatter *format = [NSDateFormatter new];
    format.locale = [NSLocale currentLocale];
    format.dateFormat = @"HH:mm";
    NSDate *date = [format dateFromString:_timeLabel.text];
    format.dateFormat = @"a";
    typeStr = [format stringFromDate:date];
    //类型代表上学放学
    if (type == 0) {
        typeStr = [typeStr stringByAppendingString:@"上学"];
    } else {
        typeStr = [typeStr stringByAppendingString:@"放学"];
    }
    _typeLabel.text = typeStr;
    [_typeLabel sizeToFit];
    _succeedCountLabel.text = [NSString stringWithFormat:@"%zd 人", succeedCount];
    [_succeedCountLabel sizeToFit];
    _vacateCountLabel.text = [NSString stringWithFormat:@"%zd 人", vacateCount];
    [_vacateCountLabel sizeToFit];
    _notCompleteLabel.text = [NSString stringWithFormat:@"%zd 人", notComplete];
    [_notCompleteLabel sizeToFit];
}



//- (void)setInfoModel:(DWDTeacherGoSchoolInfoModel *)infoModel {
//    _infoModel = infoModel;
//    //        @property (nonatomic, weak) UILabel *timeLabel;
//    //        @property (nonatomic, weak) UILabel *succeedCountLabel;
//    //        @property (nonatomic, weak) UILabel *vacateCountLabel;
//    //        @property (nonatomic, weak) UILabel *notCompleteLabel;
//    _timeLabel.text = [NSString stringWithFormat:@"%ld 人", infoModel.totalStudent];
//    _succeedCountLabel.text = [NSString stringWithFormat:@"%ld 人", infoModel.succeedCount];
//    _vacateCountLabel.text = [NSString stringWithFormat:@"%ld 人", infoModel.vacateCount];
//    _notCompleteLabel.text = [NSString stringWithFormat:@"%.1f %%", infoModel.attendanceRate * 100];
//    [super updateConstraints];
//}

@end
