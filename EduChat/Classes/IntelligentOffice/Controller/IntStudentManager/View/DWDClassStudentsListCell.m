//
//  DWDClassStudentsListCell.m
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassStudentsListCell.h"
#import "DWDTeacherGoSchoolStudentDetailModel.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface DWDClassStudentsListCell ()

// head img view
@property (nonatomic, weak) UIImageView *photoImgView;

// name text label
@property (nonatomic, weak) UILabel *nameLabel;

// dwd id text label
@property (nonatomic, weak) UILabel *descriptionLabel;

// data model
@property (nonatomic, strong) DWDTeacherGoSchoolStudentDetailModel *model;

@end

@implementation DWDClassStudentsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UIImageView *imgView = [UIImageView new];
    [self.contentView addSubview:imgView];
    _photoImgView = imgView;
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(60);
    }];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:nameLabel];
    _nameLabel = nameLabel;
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(22);
        make.left.mas_equalTo(imgView.mas_right).offset(10);
    }];
    
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.font = [UIFont systemFontOfSize:12];
    descriptionLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:descriptionLabel];
    _descriptionLabel = descriptionLabel;
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-22);
        make.left.mas_equalTo(nameLabel);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = UIColorFromRGB(0xdddddd);
    [self.contentView addSubview:lineView];
    [lineView makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(DWDScreenW);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(-1);
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(10);
    }];
    
    return self;
}

- (void)setCellData:(DWDTeacherGoSchoolStudentDetailModel *)model {
    
//    _photoImgView.backgroundColor = [UIColor blueColor];
    [_photoImgView sd_setImageWithURL:[NSURL URLWithString:model.photohead.photoKey] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    _nameLabel.text = model.name;
    _descriptionLabel.text = [@"多维度号: " stringByAppendingString:[NSString stringWithFormat:@"%@", model.educhatAccount]];
    
}

@end
