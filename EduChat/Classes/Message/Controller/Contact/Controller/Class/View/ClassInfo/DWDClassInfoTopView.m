//
//  DWDClassInfoTopView.m
//  EduChat
//
//  Created by Superman on 15/11/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassInfoTopView.h"
#import "NSString+Extension.h"

@interface DWDClassInfoTopView()

@end

@implementation DWDClassInfoTopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"img_defaultphoto"];
    }
    return self;
}

@end
