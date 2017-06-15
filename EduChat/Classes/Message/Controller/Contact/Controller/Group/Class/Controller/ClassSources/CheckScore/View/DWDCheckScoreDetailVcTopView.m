//
//  DWDCheckScoreDetailVcTopView.m
//  EduChat
//
//  Created by Superman on 15/11/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDCheckScoreDetailVcTopView.h"

@interface DWDCheckScoreDetailVcTopView()
/**
 *  如果需要使用绘图来画饼状图,  需要自定义这两个View
 */
@property (nonatomic , weak) IBOutlet UIView *classAve;
@property (nonatomic , weak) IBOutlet UIView *gradeAve;

@end

@implementation DWDCheckScoreDetailVcTopView

- (IBAction)btnClick:(UIButton *)btn{
    DWDLogFunc;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
