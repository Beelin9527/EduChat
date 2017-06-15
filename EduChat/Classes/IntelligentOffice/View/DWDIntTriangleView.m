//
//  DWDIntTriangleView.m
//  EduChat
//
//  Created by Beelin on 16/12/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntTriangleView.h"

@implementation DWDIntTriangleView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ref, 0, 5);
    CGContextAddLineToPoint(ref, rect.size.width/2.0 , 0);
    CGContextAddLineToPoint(ref, rect.size.width, 5);
    CGContextClosePath(ref);
    
    [[UIColor whiteColor] setFill];
    CGContextFillPath(ref);
    
}

@end
