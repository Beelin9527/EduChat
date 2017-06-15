//
//  DWDClassSourceGrowupRecordCell.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//  班级成员的cell

#import "DWDClassSourceGrowupRecordCell.h"
#import <Masonry.h>
@interface DWDClassSourceGrowupRecordCell()

@property (nonatomic , weak) UIImageView *iconView;

@end

@implementation DWDClassSourceGrowupRecordCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"AvatarOther"];
        [self.contentView addSubview:imageView];
        _iconView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor yellowColor];
        label.font = DWDFontContent;
        NSArray *arr = @[@"蛋蛋",@"刘德华",@"Nike",@"蔡依林",@"刘欢",@"那英",@"刘邦",@"董存瑞",@"Nike",@"Rose",@"Tom",@"奥巴马",@"Michael Schrofiel",@"Adidas",@"NewBalance",@"Eyan",@"Faker",];
        int a = arc4random_uniform(17);
        label.text = [NSString stringWithFormat:@"%@",arr[a]];
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

@end
