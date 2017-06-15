//
//  DWDInfoExpertChart.h
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDInfoExpertModel.h"

@interface DWDInfoExpertChart : UIView

@property (nonatomic, strong) NSArray<DWDInfoExpertModel *> *experts;
@property (nonatomic, copy) void(^block)(NSInteger index);

+ (CGFloat)getExpertChartHeight;

@end
