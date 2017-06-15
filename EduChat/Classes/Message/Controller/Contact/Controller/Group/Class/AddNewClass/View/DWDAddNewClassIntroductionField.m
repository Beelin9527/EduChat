//
//  DWDAddNewClassIntroductionField.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddNewClassIntroductionField.h"

@interface DWDAddNewClassIntroductionField()


@end

@implementation DWDAddNewClassIntroductionField


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderWidth = pxToH(1);
        [self setFont:DWDFontContent];
        _str1 = @"请输入说明文字";
        _str2 = @"0/300";
    }
    return self;
}

- (void)setStr2Count:(int)str2Count{
    _str2Count = str2Count;
    
    _str2 = [NSString stringWithFormat:@"%d/300",str2Count];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGSize realSize = [_str2 realSizeWithfont:DWDFontContent];
    
//    if ([self.text realSizeWithfont:DWDFontContent].height > self.h) {
//        self.h += [self.text realSizeWithfont:DWDFontContent].height - self.h;
//        
//    }
    
    NSDictionary *dict = @{NSForegroundColorAttributeName : DWDColorSecondary ,
                            NSFontAttributeName : DWDFontContent};
    
    if (self.text.length > 0) {
        [@"" drawAtPoint:CGPointMake(pxToW(20), pxToH(20)) withAttributes:dict];
    }else{
        [_str1 drawAtPoint:CGPointMake(pxToW(20), pxToH(20)) withAttributes:dict];
    }
    
    CGFloat drawX = DWDScreenW - pxToW(20) - realSize.width;
    CGFloat drawY = self.h - pxToH(70);
    DWDLog(@" %f =====  %f  ===  %f",drawX , drawY , self.h);
    [_str2 drawAtPoint:CGPointMake(drawX ,drawY) withAttributes:dict];
    
}


@end
