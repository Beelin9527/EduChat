//
//  DWDRelayChooseMidView.m
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRelayChooseMidView.h"
#import <Masonry.h>

@implementation DWDRelayChooseMidView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"ic_clickable_normal"];
        [self addSubview:imageView];
        
        UILabel *label = [UILabel new];
        label.font = DWDFontContent;
        _label = label;
        [self addSubview:label];
        
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@10);
            make.centerY.equalTo(self.centerY);
        }];
        
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-10));
            make.centerY.equalTo(self.centerY);
            make.width.equalTo(@15);
            make.height.equalTo(@15);
        }];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer *)tap{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapMidView:)]) {
        [self.delegate tapMidView:self];
    }
}

@end
