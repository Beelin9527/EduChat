//
//  DWDInfoExpertCartView.h
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDInfoExpertModel.h"

@interface DWDInfoExpertCartView : UIView

@property (nonatomic, strong) DWDInfoExpertModel *expert;
@property (nonatomic, copy) void(^tapBlock)(NSInteger index);

- (void)setTopImage:(UIImage *)image;
- (void)setRank:(int)rank;

@end
