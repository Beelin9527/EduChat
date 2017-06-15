//
//  DWDChatEmotionDefaultCell.m
//  EduChat
//
//  Created by Superman on 16/10/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatEmotionDefaultCell.h"
#import <Masonry.h>
@implementation DWDChatEmotionDefaultCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [UIImageView new];
        _imageView = imageView;
        [self.contentView addSubview:imageView];
        
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.top);
            make.left.equalTo(self.contentView.left);
            make.right.equalTo(self.contentView.right);
            make.bottom.equalTo(self.contentView.bottom);
        }];
        
    }
    return self;
}

@end
