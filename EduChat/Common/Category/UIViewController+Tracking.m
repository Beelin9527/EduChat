//
//  UIViewController+Tracking.m
//  EduChat
//
//  Created by Gatlin on 16/5/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "UIViewController+Tracking.h"
#import <objc/runtime.h>

#import <UMMobClick/MobClick.h>
@implementation UIViewController (Tracking)

+ (void)load
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        //viewWillAppear
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(dwd_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod)
        {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        
        
        //viewDidDisappear
        SEL originalViewDidDisappearSelector = @selector(viewDidDisappear:);
        SEL swizzledViewDidDisappearSelector = @selector(dwd_viewDidDisappear:);
        
        Method originalViewDidDisappearMethod = class_getInstanceMethod(class, originalViewDidDisappearSelector);
        Method swizzledViewDidDisappearMethod = class_getInstanceMethod(class, swizzledViewDidDisappearSelector);
        
        BOOL didAddViewDidDisappearMethod =
        class_addMethod(class,
                        originalViewDidDisappearSelector,
                        method_getImplementation(originalViewDidDisappearMethod),
                        method_getTypeEncoding(originalViewDidDisappearMethod));
        
        if (didAddViewDidDisappearMethod)
        {
            class_replaceMethod(class,
                                swizzledViewDidDisappearSelector,
                                method_getImplementation(originalViewDidDisappearMethod),
                                method_getTypeEncoding(originalViewDidDisappearMethod));
        }
        else
        {
            method_exchangeImplementations(originalViewDidDisappearMethod, swizzledViewDidDisappearMethod);
        }

        
    });
}

#pragma mark - Method Swizzling
- (void)dwd_viewWillAppear:(BOOL)animated
{
    [self dwd_viewWillAppear:animated];
    NSString *className = NSStringFromClass([self class]);
    [MobClick beginLogPageView:[NSString stringWithFormat:@"%@",className]];
}

- (void)dwd_viewDidDisappear:(BOOL)animated
{
    [self dwd_viewDidDisappear:animated];
    NSString *className = NSStringFromClass([self class]);
    [MobClick endLogPageView:[NSString stringWithFormat:@"%@",className]];
    
}
@end
