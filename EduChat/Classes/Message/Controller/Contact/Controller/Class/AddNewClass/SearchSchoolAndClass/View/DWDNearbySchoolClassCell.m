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
@property (nonatomic , weak) UIImageView *selectedImageView;
@end

@implementation DWDNearbySchoolClassCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = DWDFontContent;
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        selectedImageView.image = [UIImage imageNamed:@"AvatarOther"];
        selectedImageView.userInteractionEnabled = YES;
        _selectedImageView = selectedImageView;
        [self.contentView addSubview:selectedImageView];
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.superview.left).offset(10);
            make.centerY.equalTo(nameLabel.superview.centerY);
        }];
        
        [selectedImageView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(selectedImageView.superview.right).offset(-10);
            make.centerY.equalTo(selectedImageView.superview.centerY);
        }];
    }
    return self;
}

- (void)setNearBySchoolClass:(DWDNearBySelectedSchoolClassModel *)nearBySchoolClass{
    _nearBySchoolClass = nearBySchoolClass;
    _nameLabel.text = nearBySchoolClass.name;
}

@end
