//
//  DWDProgressHUD.m
//  EduChat
//
//  Created by Gatlin on 16/1/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDProgressHUD.h"
@interface DWDProgressHUD()
@property (nonatomic, weak) UIView *target;
@end


@implementation DWDProgressHUD

+ (instancetype)showHUD
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.opacity = 0.65;
    hud.mode = MBProgressHUDModeIndeterminate;
    return hud;
}
+ (instancetype)showHUDWithTarget:(UIView*)target
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:target animated:YES];
    hud.opacity = 0.65;
    hud.mode = MBProgressHUDModeIndeterminate;
    
    hud.target = target;
    target.userInteractionEnabled = NO;
    return hud;
}
+ (instancetype)showText:(NSString *)text
{
    return [DWDProgressHUD showText:text afterDelay:DefaultTime];
}

+ (instancetype)showText:(NSString *)text afterDelay:(float)time {
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.opacity = .65;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = text;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideHud];
    });
    return hud;
    
}


- (void)showText:(NSString *)text
{
    [self showText:text afterDelay:DefaultTime];
}
- (void)showText:(NSString *)text afterDelay:(float)time
{
    self.mode = MBProgressHUDModeText;
    self.detailsLabelText = text;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideHud];
    });
   
}

- (void)hideHud
{
    self.target.userInteractionEnabled = YES;
    [self hide:YES];
}
@end
