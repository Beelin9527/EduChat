//
//  DWDNearbySchoolClassCell.m
//  EduChat
//
//  Created by Superman on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNearbySchoolClassCell.h"
#import "DWDNearBySelectedSchoolClassModel.h"
#import <Masonry.h>
@interface DWDNearbySchoolClassCell()
@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *addressLabel;

@end

@implementation DWDNearbySchoolClassCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = DWDFontContent;
        nameLabel.textColor = [UIColor blackColor];
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.superview.left).offset(pxToH(20));
            make.top.equalTo(nameLabel.superview.top).offset(pxToH(20));
        }];
        
        
    }
    return self;
}

- (void)setNearBySchoolClass:(DWDNearBySelectedSchoolClassModel *)nearBySchoolClass{
    _nearBySchoolClass = nearBySchoolClass;
    
    if (nearBySchoolClass.used) {
        _nameLabel.text = [nearBySchoolClass.name stringByAppendingString:@" (已开通)"];
        _nameLabel.textColor = DWDRGBColor(172, 172, 172);
    }else{
        _nameLabel.text = nearBySchoolClass.name;
        _nameLabel.textColor = [UIColor blackColor];
    }
    
    
}

@end
