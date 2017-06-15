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
@implementation DWDNearbySchoolCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *schoolName = [[UILabel alloc] init];
        schoolName.font = DWDFontContent;
        schoolName.textColor = DWDColorContent;
        _schoolName = schoolName;
        [self.contentView addSubview:schoolName];
        
        UILabel *addressName = [[UILabel alloc] init];
        addressName.textColor = DWDColorSecondary;
        addressName.font = DWDFontMin;
        _addressName = addressName;
        [self.contentView addSubview:addressName];
        
        [schoolName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(schoolName.superview.left).offset(20);
            make.top.equalTo(schoolName.superview.top).offset(10);
        }];
        
        [addressName makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(schoolName.left);
            make.top.equalTo(schoolName.bottom).offset(10);
        }];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    
}

- (void)setSchoolModel:(DWDNearbySchoolModel *)schoolModel{
    _schoolModel = schoolModel;
    _schoolName.text = schoolModel.shortName;
    _addressName.text = schoolModel.fullName;
}

@end
