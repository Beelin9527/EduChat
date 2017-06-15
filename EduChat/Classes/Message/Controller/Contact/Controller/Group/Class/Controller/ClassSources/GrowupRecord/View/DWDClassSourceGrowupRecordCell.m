//
//  DWDClassSourceGrowupRecordCell.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//  班级成员的cell

#import "DWDClassSourceGrowupRecordCell.h"
#import <Masonry.h>
#import "DWDClassMember.h"
@interface DWDClassSourceGrowupRecordCell()

@property (nonatomic , weak) UIImageView *iconView;

@end

@implementation DWDClassSourceGrowupRecordCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        _iconView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor yellowColor];
        label.font = DWDFontContent;
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        _nameLabel = label;
        
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.superview.top);
            make.left.equalTo(imageView.superview.left);
            make.right.equalTo(imageView.superview.right);
            make.height.equalTo(@(pxToH(120)));
        }];
        
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.bottom).offset(pxToH(10));
            make.left.equalTo(label.superview.left);
            make.right.equalTo(label.superview.right);
            make.bottom.equalTo(label.superview.bottom);
        }];
    }
    return self;
}

- (void)setMember:(DWDClassMember *)member{
    _member = member;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:self.member.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    _nameLabel.text = member.nickname;
}

@end
