//
//  DWDAddNewClassLabel.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddNewClassLabel.h"
#import "NSString+Extension.h"
@implementation DWDAddNewClassLabel


- (void)drawRect:(CGRect)rect {
    NSDictionary *dict = @{NSFontAttributeName : DWDFontContent ,
                             NSForegroundColorAttributeName : DWDColorSecondary};
    CGSize realSize = [self.text realSizeWithfont:DWDFontContent];
    [self.text drawAtPoint:CGPointMake(pxToW(20), (pxToH(66) - realSize.height)/2.0) withAttributes:dict];
                           
}
@end
