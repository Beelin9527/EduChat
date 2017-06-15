//
//  DWDFileContainerButton.m
//  EduChat
//
//  Created by Superman on 16/6/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDFileContainerButton.h"

@interface DWDFileContainerButton()

@end

@implementation DWDFileContainerButton
CGSize realSize;
+ (instancetype)buttonWithImage:(UIImage *)image title:(NSString *)title{
    return [[self alloc] initWithImage:image title:title];
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title{
    DWDFileContainerButton *btn = [DWDFileContainerButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:image forState:UIControlStateNormal];
    realSize = [title realSizeWithfont:DWDFontContent];
    return btn;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.cenX = self.w * 0.5;
    self.imageView.y = 0;
    
    self.titleLabel.y = self.imageView.h;
    self.titleLabel.cenX = self.w * 0.5;
    
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0 , 0, self.w, realSize.height);
}

@end
