//
//  DWDPickUpCenterListCell.m
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterListCell.h"

#import "DWDPickUpCenterListDataBaseModel.h"

#import <Masonry.h>

@interface DWDPickUpCenterListCell ()
@property (weak, nonatomic) UILabel *schoolName;

@property (weak, nonatomic) UILabel *className;

@property (weak, nonatomic) UILabel *badgeLabel;

@end

@implementation DWDPickUpCenterListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UILabel *scName = [UILabel new];
    scName.textAlignment = NSTextAlignmentLeft;
    scName.numberOfLines = 1;
    scName.lineBreakMode = NSLineBreakByTruncatingTail;
    scName.font = [UIFont systemFontOfSize:16];
    scName.textColor = DWDColorSecondary;
    [self.contentView addSubview:scName];
    [scName makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(10);
    }];
    _schoolName = scName;
    
    UILabel *bgLabel = [UILabel new];
    bgLabel.textAlignment = NSTextAlignmentCenter;
    bgLabel.textColor = [UIColor whiteColor];
    bgLabel.backgroundColor = [UIColor redColor];
    bgLabel.font = [UIFont systemFontOfSize:11];
    bgLabel.layer.cornerRadius = 12;
    bgLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:bgLabel];
    [bgLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-5);
    }];
    _badgeLabel = bgLabel;
    
    UILabel *clsName = [UILabel new];
    clsName.textAlignment = NSTextAlignmentRight;
    clsName.font = [UIFont systemFontOfSize:16];
    clsName.textColor = DWDColorBody;
    [self.contentView addSubview:clsName];
    [clsName makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(bgLabel.left).offset(-5);
    }];
    
    _className = clsName;
    
    return self;
}

- (void)setDataModel:(DWDPickUpCenterListDataBaseModel *)dataModel {
    _schoolName.text =dataModel.schoolName;
    _className.text = dataModel.className;
    
    CGFloat classNameWidth = [dataModel.className realSizeWithfont:[UIFont systemFontOfSize:16]].width + 2;
    //数字label 24 最右间距 10 第二右间距 5 左侧间距10 剩余间距
    CGFloat schoolNameWidth;
    if ([dataModel.badgeNumber integerValue] > 0) {
        schoolNameWidth = DWDScreenW - 50 - classNameWidth;
    } else {
        schoolNameWidth = DWDScreenW - 20 - classNameWidth;
    }
    
    //update constraints
    [_schoolName updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(schoolNameWidth);
    }];
    
    if ([dataModel.badgeNumber integerValue] > 0) {
        _badgeLabel.hidden = NO;
        _badgeLabel.text = [NSString stringWithFormat:@"%@", [dataModel.badgeNumber integerValue] > 99 ? @"99+" : dataModel.badgeNumber];
//        _badgeLabel.text = @"99+";
        [_badgeLabel updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(24);
        }];
        [_className makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(classNameWidth);
            make.right.mas_equalTo(_badgeLabel.left).offset(-5);
        }];

    } else {
        [_badgeLabel updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(0);
        }];
        [_className makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(classNameWidth);
            make.right.mas_equalTo(self.contentView).offset(-5);
        }];
    }
    [_badgeLabel setNeedsLayout];
    [_badgeLabel updateConstraints];
    [_className updateConstraints];
    [_schoolName updateConstraints];
    
//        _schoolName.text = [NSString stringWithFormat:@"%@", dataModel.schoolId];
//        _className.text = [NSString stringWithFormat:@"%@", dataModel.classId];
//        if ([dataModel.badgeNumber isEqualToNumber:@0]) {
//            _badgeNumberButton.hidden = YES;
//            _badgeConstraint.priority = 100;
//        } else {
//            _badgeNumberButton.hidden = NO;
//            _badgeConstraint.priority = 1000;
//            //    _badgeNumberButton.titleLabel.text = [dataModel.badgeNumber stringValue];
//            [_badgeNumberButton setTitle:[dataModel.badgeNumber stringValue] forState:UIControlStateNormal];
//        }
}

@end
