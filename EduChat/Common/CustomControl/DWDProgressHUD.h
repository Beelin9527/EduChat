//
//  DWDProgressHUD.h
//  EduChat
//
//  Created by Gatlin on 16/1/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

static CGFloat const DefaultTime = 1.5;  //默认时间

@interface DWDProgressHUD : MBProgressHUD

+ (instancetype)showHUD;  //默认带菊花、字体颜色白色、国际化 loding

+ (instancetype)showText:(NSString *)text; // 创建纯文本，默认时间1.5秒

+ (instancetype)showText:(NSString *)text afterDelay:(float)time;

- (void)showText:(NSString *)text;
- (void)showText:(NSString *)text afterDelay:(float)time; // 纯文本，自定义时间


+ (instancetype)showHUDWithTarget:(UIView*)target;
- (void)hideHud;
@end
