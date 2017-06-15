//
//  UITabBarController+Badge.h
//  EduChat
//
//  Created by Catskiy on 16/9/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Badge)

- (void)showBadgeOnItemIndex:(int)index;   // 显示提示小红点标记
- (void)hideBadgeOnItemIndex:(int)index;   // 隐藏小红点标记
- (void)removeBadgeOnItemIndex:(int)index; // 移除小红点标记

@end
