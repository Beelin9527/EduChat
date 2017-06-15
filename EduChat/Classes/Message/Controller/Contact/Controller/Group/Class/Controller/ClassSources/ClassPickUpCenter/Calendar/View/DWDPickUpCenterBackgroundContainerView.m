//
//  DWDPickUpCenterBackgroundContainerView.m
//  EduChat
//
//  Created by KKK on 16/3/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterBackgroundContainerView.h"

#import <Masonry.h>

@implementation DWDPickUpCenterBackgroundContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIImageView *imgView = [UIImageView new];
    [self addSubview:imgView];
    self.backgroundImageView = imgView;
    
    UILabel *infoLabel = [UILabel new];
    infoLabel.textColor = DWDRGBColor(102, 102, 102);
    [self addSubview:infoLabel];
    self.infoLabel = infoLabel;
    
    [imgView makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(pxToW(316));
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self);
    }];
    
    [infoLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.bottom);
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    return self;
}

@end
