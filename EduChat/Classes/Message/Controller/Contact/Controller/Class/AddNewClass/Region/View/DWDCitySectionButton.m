//
//  DWDCitySectionButton.m
//  EduChat
//
//  Created by Superman on 15/12/14.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDCitySectionButton.h"

@implementation DWDCitySectionButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        CALayer *seperator = [CALayer layer];
        seperator.backgroundColor = DWDColorSecondary.CGColor;
        seperator.frame = CGRectMake(0, pxToH(87), DWDScreenW, 0.5);
        [self.layer addSublayer:seperator];
    }
    return self;
}

@end
