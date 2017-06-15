//
//  DWDInfoTitleCell.h
//  EduChat
//
//  Created by Catskiy on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YGCommonCell.h"

@interface DWDInfoTitleCell : UITableViewCell

@property (nonatomic, copy) void(^moreBlock)(void);

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle image:(UIImage *)image;
- (void)hideSubTitle:(BOOL)ishide;

@end
