//
//  DWDInfoSelectView.h
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDInfoSelectView : UIView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, copy) void(^selectViewBlock)(NSUInteger fromIndex, NSUInteger toIndex);

@end
