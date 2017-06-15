//
//  DWDGrowUpTouchImageView.h
//  EduChat
//
//  Created by KKK on 16/4/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDGrowUpTouchImageView : UIImageView

@property (nonatomic, copy) void (^tapBlock)(UITapGestureRecognizer *tapGestureRecognizer);

@end
