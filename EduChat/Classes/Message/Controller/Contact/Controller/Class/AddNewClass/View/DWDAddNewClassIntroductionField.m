//
//  DWDAddNewClassIntroductionField.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddNewClassIntroductionField.h"
#import "NSString+Extension.h"

@interface DWDAddNewClassIntroductionField()


@end

@implementation DWDAddNewClassIntroductionField


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderWidth = pxToH(1);
        _str1 = @"请输入说明文字";
        _str2 = @"0/300";
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGSize realSize = [_str2 realSizeWithfont:DWDFontContent];
    
    NSDictionary *dict = @{NSForegroundColorAttributeName : DWDColorSecondary ,
                            NSFontAttributeName : DWDFontContent};
    
    [_str1 drawAtPoint:CGPointMake(pxToW(20), pxToH(20)) withAttributes:dict];
    [_str2 drawAtPoint:CGPointMake(DWDScreenW - pxToW(20) - realSize.width, self.h - pxToH(20) - realSize.height) withAttributes:dict];
}


@end
