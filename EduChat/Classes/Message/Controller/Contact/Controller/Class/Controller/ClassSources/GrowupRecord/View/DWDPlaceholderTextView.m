//
//  DWDPlaceholderTextView.m
//  EduChat
//
//  Created by Superman on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDPlaceholderTextView.h"

@implementation DWDPlaceholderTextView


- (void)drawRect:(CGRect)rect {
    if (self.text.length > 0) {
        [super drawRect:rect];
        return;
    }else{
        NSDictionary *dict = @{NSForegroundColorAttributeName : DWDRGBColor(153, 153, 153),
                               NSFontAttributeName : DWDFontContent};
        NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:@"这一刻的心情" attributes:dict];
        [placeHolder drawAtPoint:CGPointMake(pxToW(18), pxToH(15))];
    }
}


@end
