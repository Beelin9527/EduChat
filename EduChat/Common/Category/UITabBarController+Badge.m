//
//  UITabBarController+Badge.m
//  EduChat
//
//  Created by Catskiy on 16/9/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "UITabBarController+Badge.h"

#define TabbarItemNums 5.0    //tabbar的数量

@implementation UITabBarController (Badge)

- (void)showBadgeOnItemIndex:(int)index{
    
    [self removeBadgeOnItemIndex:index];
    
    UIView *badgeView = [[UIView alloc]init];
    
    badgeView.tag = 888 + index;
    
    badgeView.layer.cornerRadius = 5;
    
    badgeView.backgroundColor = [UIColor redColor];
    
    CGRect tabFrame = self.tabBar.frame;
    
    float percentX = (index + 0.6) /TabbarItemNums;
    
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    
    badgeView.frame = CGRectMake(x, y, 10,10);
    
    [self.tabBar addSubview:badgeView];
    
}

- (void)hideBadgeOnItemIndex:(int)index{
    
    [self removeBadgeOnItemIndex:index];
    
}

- (void)removeBadgeOnItemIndex:(int)index{
    
    for (UIView *subView in self.tabBar.subviews) {
        
        if (subView.tag == 888 + index) {
            
            [subView removeFromSuperview];
            
        }
    }
}


@end
