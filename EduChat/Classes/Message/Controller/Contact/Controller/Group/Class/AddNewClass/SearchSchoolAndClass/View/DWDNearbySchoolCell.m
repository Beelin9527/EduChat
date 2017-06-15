//
//  DWDNearbySchoolCell.m
//  EduChat
//
//  Created by Superman on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNearbySchoolCell.h"
#import "DWDNearbySchoolModel.h"
#import <Masonry.h>

@interface DWDNearbySchoolCell()
@property (nonatomic , weak) UILabel *schoolName;
@property (nonatomic , weak) UILabel *addressName;
@end

@implementation DWDNearbySchoolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *schoolName = [[UILabel alloc] init];
        schoolName.font = DWDFontContent;
        schoolName.textColor = DWDColorContent;
        _schoolName = schoolName;
        [self.contentView addSubview:schoolName];
        
        UILabel *addressLabel = [[UILabel alloc] init];
        addressLabel.font = [UIFont systemFontOfSize:14];
        addressLabel.textColor = DWDRGBColor(172, 172, 172);
        [self.contentView addSubview:addressLabel];
        _addressName = addressLabel;
        
        [schoolName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(schoolName.superview.left).offset(pxToH(20));
            make.top.equalTo(schoolName.superview.top).offset(pxToH(20));
        }];
        
        [addressLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(schoolName.left);
            make.top.equalTo(schoolName.bottom).offset(pxToH(20));
        }];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setSchoolModel:(DWDNearbySchoolModel *)schoolModel{
    _schoolModel = schoolModel;
    
    _schoolName.text = schoolModel.fullName;
    _addressName.text = schoolModel.address;
}

@end
