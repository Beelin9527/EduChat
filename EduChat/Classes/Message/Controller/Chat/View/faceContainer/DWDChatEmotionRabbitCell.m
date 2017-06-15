//
//  DWDChatEmotionRabbitCell.m
//  EduChat
//
//  Created by Superman on 16/10/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatEmotionRabbitCell.h"
#import <Masonry.h>

@implementation DWDChatEmotionRabbitCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView new];
        _imageView = imageView;
        [self.contentView addSubview:imageView];
        
        UILabel *textLabel = [UILabel new];
        textLabel.font = [UIFont systemFontOfSize:12];
        textLabel.textColor = DWDRGBColor(121, 121, 121);
        _titleLabel = textLabel;
        [self.contentView addSubview:textLabel];
        
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.left);
            make.top.equalTo(self.top);
            make.right.equalTo(self.right);
            make.height.equalTo(@60);
        }];
        
        [_titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageView.bottom);
            make.centerX.equalTo(_imageView.centerX);
        }];
        
    }
    return self;
}

@end
