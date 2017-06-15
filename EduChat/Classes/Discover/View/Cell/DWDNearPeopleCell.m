//
//  DWDNearPeopleCell.m
//  EduChat
//
//  Created by Superman on 15/11/12.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNearPeopleCell.h"
#import "DWDNearPeopleModel.h"
#import <Masonry.h>


@interface DWDNearPeopleCell()
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *nameLabel;

/**
 *  身份图标
 */
@property (nonatomic , weak) UIImageView *roleIconView;

/**
 *  图标
 */
@property (nonatomic , weak) UIImageView *statusIconView;

/**
 *  性别图标
 */
@property (nonatomic , weak) UIImageView *sexIconView;
@property (nonatomic , weak) UIImageView *distanceIconView;
@property (nonatomic , weak) UILabel *distanceLabel;
@property (nonatomic , weak) UILabel *schoolAndClassLabel;

@end

@implementation DWDNearPeopleCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"cell";
    DWDNearPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDNearPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *iconView = [[UIImageView alloc] init];
        UILabel *nameLabel = [[UILabel alloc] init];
        
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = DWDRGBColor(51, 51, 51);
        
        UIImageView *roleIconView = [[UIImageView alloc] init];
        UIImageView *statusIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_friend_people_nearby_normal5"]];
        UIImageView *sexIconView = [[UIImageView alloc] init];
        UIImageView *distanceIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_distance_find"]];
        UILabel *distanceLabel = [[UILabel alloc] init];
        
        distanceLabel.font = [UIFont systemFontOfSize:12];
        distanceLabel.textColor = DWDRGBColor(153, 153, 153);
        
        UILabel *schoolAndClassLabel = [[UILabel alloc] init];
        schoolAndClassLabel.font = [UIFont systemFontOfSize:14];
        schoolAndClassLabel.textColor = DWDRGBColor(102, 102, 102);
        
        _iconView = iconView;
        _nameLabel = nameLabel;
        _roleIconView = roleIconView;
        _statusIconView = statusIconView;
        _sexIconView = sexIconView;
        _distanceIconView = distanceIconView;
        _distanceLabel = distanceLabel;
        _schoolAndClassLabel = schoolAndClassLabel;
        
        [self.contentView addSubview:iconView];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:roleIconView];
        [self.contentView addSubview:statusIconView];
        [self.contentView addSubview:sexIconView];
        [self.contentView addSubview:distanceIconView];
        [self.contentView addSubview:distanceLabel];
        [self.contentView addSubview:schoolAndClassLabel];
        
        [iconView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.superview.left).offset(pxToW(20));
            make.centerY.equalTo(iconView.superview.centerY);
            make.width.equalTo(@(pxToW(100)));
            make.height.equalTo(@(pxToH(100)));
        }];
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.right).offset(pxToW(20));
            make.top.equalTo(nameLabel.superview.top).offset(pxToH(24));
        }];
        
        [roleIconView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.right).offset(pxToW(20));
            make.centerY.equalTo(nameLabel.centerY);
        }];
        
        [statusIconView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(roleIconView.right).offset(pxToW(10));
            make.centerY.equalTo(roleIconView.centerY);
            make.width.equalTo(@(pxToW(44)));
            make.height.equalTo(@(pxToW(44)));
        }];
        
        [sexIconView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(statusIconView.right);
            make.centerY.equalTo(statusIconView.centerY);
            make.width.equalTo(@(pxToW(44)));
            make.height.equalTo(@(pxToW(44)));
        }];
        
        [distanceLabel makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(distanceLabel.superview.right).offset(-pxToW(20));
            make.top.equalTo(distanceLabel.superview.top).offset(pxToH(28));
        }];
        
        [distanceIconView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(distanceLabel.left).offset(-pxToW(10));
            make.centerY.equalTo(distanceLabel.centerY);
//            make.width.equalTo(@(pxToW(18)));
//            make.height.equalTo(@(pxToW(25)));
        }];
        
        [_schoolAndClassLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.right).offset(pxToW(20));
            make.bottom.equalTo(iconView.bottom);
        }];
    }
    return self;
}

- (void)setNearPeople:(DWDNearPeopleModel *)nearPeople{
    _nearPeople = nearPeople;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:nearPeople.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    
    
    _nameLabel.text = nearPeople.nickname;
//    [_nameLabel sizeToFit];
    CGSize size = [_nameLabel.text boundingRectWithSize:CGSizeMake(150.0f, pxToH(24)) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
    [_nameLabel updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_iconView.right).offset(pxToW(20));
        make.top.equalTo(_nameLabel.superview.top).offset(pxToH(24));
        make.width.mas_equalTo(size.width);
    }];
    
    if (nearPeople.type == DWDNearPeopleModelTypeParents) {
        _roleIconView.image = [UIImage imageNamed:@"ic_parentl_people_nearby_normal"];
//        [_statusIconView updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@(0));
//        }];
        
    }else if (nearPeople.type == DWDNearPeopleModelTypeTeacher){
        
        _roleIconView.image = [UIImage imageNamed:@"ic_teacher_people_nearby_normal"];
//        _statusIconView.image = [UIImage imageNamed:@"ic_friend_people_nearby_normal5"];
//        [_statusIconView updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@(pxToW(44)));
//        }];
        
    }else if (nearPeople.type == DWDNearPeopleModelTypeStudents){
        
        _roleIconView.image = [UIImage imageNamed:@"ic_studentl_people_nearby_normal"];
//        [_statusIconView updateConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@(0));
//        }];
    }
    
    if (!nearPeople.isFriend) {
        [_statusIconView updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
    
    if (nearPeople.gender == DWDNearPeopleModelGenderMan) {
        _sexIconView.image = [UIImage imageNamed:@"ic_boy_people_nearby_normal"];
    }else{
        _sexIconView.image = [UIImage imageNamed:@"ic_gril_people_nearby_normal"];
    }
    
    _distanceLabel.text = [NSString stringWithFormat:@"%zd米",[nearPeople.distance integerValue]];
    [_distanceLabel sizeToFit];
    
    
    _schoolAndClassLabel.text = [NSString stringWithFormat:@"%@%@",nearPeople.school,nearPeople.classGrade];
    [_schoolAndClassLabel sizeToFit];
}

@end
