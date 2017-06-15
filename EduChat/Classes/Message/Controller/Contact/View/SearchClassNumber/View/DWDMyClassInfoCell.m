//
//  DWDMyClassInfoCell.m
//  EduChat
//
//  Created by Superman on 16/2/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyClassInfoCell.h"
#import "DWDClassModel.h"
#import <Masonry.h>
@interface DWDMyClassInfoCell()

@property (nonatomic , weak) UILabel *nameLabel;
@property (nonatomic , weak) UILabel *detalLabel;
//@property (nonatomic , weak) UILabel *memberCountLabel;
@property (nonatomic , weak) UIImageView *iconView;


@end

@implementation DWDMyClassInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconView];
        _iconView = iconView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = DWDRGBColor(51, 51, 51);
        _nameLabel = nameLabel;
        [self.contentView addSubview:nameLabel];
        
        UILabel *detalLabel = [[UILabel alloc] init];
        detalLabel.font = [UIFont systemFontOfSize:14];
        detalLabel.textColor = DWDRGBColor(153, 153, 153);
        _detalLabel = detalLabel;
        [self.contentView addSubview:detalLabel];
        
        //隐藏班级人数
//        UILabel *memberCountLabel = [[UILabel alloc] init];
//        memberCountLabel.font = DWDFontContent;
//        _memberCountLabel = memberCountLabel;
//        [self.contentView addSubview:memberCountLabel];
        
        
        
        [iconView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(iconView.superview.top).offset(pxToH(20));
            make.left.equalTo(iconView.superview.left).offset(pxToW(20));
            make.bottom.equalTo(iconView.superview.bottom).offset(pxToH(-20));
            make.width.equalTo(@(pxToW(100)));
        }];
        
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.right).offset(pxToW(20));
            make.top.equalTo(nameLabel.superview.top).offset(pxToH(24));
        }];
        
        [detalLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.left);
            make.bottom.equalTo(detalLabel.superview.bottom).offset(pxToH(-23));
            make.right.equalTo(detalLabel.superview.right).offset(-pxToW(20));
        }];
        
//        [memberCountLabel makeConstraints:^(MASConstraintMaker *make) {
//            make.right.equalTo(detalLabel.right);
//            make.centerY.equalTo(self.centerY);
//        }];隐藏班级人数
    }
    return self;
}


/*
 classGrade = 0;
 classId = 8010000001080;
 className = "\U4e8c\U5e74\U7ea7\U4e00\U73ed";
 classNum = 0;
 introduce = "";
 isClose = 0;
 isShowNick = 1;
 isTop = 0;
 memberNum = 4;
 nickName = "";
 standardId = 0;
 */
- (void)setClassModel:(DWDClassModel *)classModel
{
    _classModel = classModel;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:classModel.photoKey] placeholderImage:DWDDefault_GradeImage];
    _nameLabel.text = classModel.className;
    _detalLabel.text = classModel.introduce;
//    _memberCountLabel.text = [NSString stringWithFormat:@"(%@人)",classModel.memberNum]; 隐藏班级人数
}



@end
