//
//  UINavigationController+dwd_status_bar_light_swizzling.m
//  EduChat
//
//  Created by KKK on 16/12/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "UINavigationController+dwd_status_bar_light_swizzling.h"

@implementation UINavigationController (dwd_status_bar_light_swizzling)

- (UIStatusBarStyle)kk_preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
