//
//  DWDGrowUpTouchImageView.m
//  EduChat
//
//  Created by KKK on 16/4/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGrowUpTouchImageView.h"

@implementation DWDGrowUpTouchImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = NO;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    UITapGestureRecognizer *gR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self addGestureRecognizer:gR];
    return self;
}
#pragma mark - Event Response
- (void)tapImage:(UITapGestureRecognizer *)tap {
    if (_tapBlock) {
        _tapBlock(tap);
    }
}
#pragma mark - Private Method



@end
