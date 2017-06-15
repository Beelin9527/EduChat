//
//  DWDAddNewClassDistrictCell.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddNewClassDistrictCell.h"
#import "DWDDistrictModel.h"
#import <Masonry.h>
@interface DWDAddNewClassDistrictCell()
@property (nonatomic , weak) UIImageView *iconImageView;
@property (nonatomic , weak) UILabel *label;
@property (nonatomic , weak) UILabel *locationLabel;
@end

@implementation DWDAddNewClassDistrictCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"ic_location"];
        [self.contentView addSubview:imageView];
        _iconImageView = imageView;
        
        UILabel *leftLabel = [[UILabel alloc] init];
        leftLabel.font = DWDFontContent;
        leftLabel.textColor = DWDColorSecondary;
        leftLabel.text = @"当前定位:";
        [leftLabel sizeToFit];
        [self.contentView addSubview:leftLabel];
        _label = leftLabel;
        
        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.font = DWDFontBody;
        rightLabel.textColor = DWDColorBody;
        [self.contentView addSubview:rightLabel];
        _locationLabel = rightLabel;
        
        // CONS
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.superview.top).offset(pxToH(22));
            make.left.equalTo(imageView.superview.left).offset(pxToW(14));
            make.width.equalTo(@(pxToW(44)));
            make.height.equalTo(@(pxToH(44)));
        }];
        
        [leftLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.right).offset(pxToW(4));
            make.centerY.equalTo(imageView.centerY);
        }];
        
        [rightLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftLabel.right);
            make.centerY.equalTo(imageView.centerY);
        }];
        
    }
    return self;
}

- (void)awakeFromNib {
    
}

- (void)setCurrentLocation:(NSString *)currentLocation{
    _currentLocation = currentLocation;
    _locationLabel.text = currentLocation;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
