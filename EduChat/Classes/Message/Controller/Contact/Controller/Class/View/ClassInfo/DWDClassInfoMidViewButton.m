//
//  DWDClassInfoMidViewButton.m
//  EduChat
//
//  Created by Superman on 15/11/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassInfoMidViewButton.h"
#import "NSString+Extension.h"

@interface DWDClassInfoMidViewButton()
@property (nonatomic , assign) CGFloat realW;
@property (nonatomic , assign) CGFloat realH;

@end

@implementation DWDClassInfoMidViewButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    [super setTitle:title forState:state];
    _realW = [title realSizeWithfont:DWDFontContent].width;
    _realH = [title realSizeWithfont:DWDFontContent].height;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(self.imageView.cenX - _realW * 0.5, pxToH(122) ,_realW , _realH);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(self.frame.size.width * 0.5 - (pxToW(30)), pxToH(42) , pxToW(60), pxToH(60));
}
@end
