//
//  DWDSegmentedControl.h
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//  选择按钮control

#import <UIKit/UIKit.h>

@class DWDSegmentedControl;
@protocol DWDSegmentedControlDelegate <NSObject>
@optional
-(void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView lickBtn:(UIButton*)sender;
-(void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView index:(NSInteger)index;
@end


@interface DWDSegmentedControl : UIView

@property (nonatomic,strong) NSArray *arrayTitles;
@property (nonatomic,strong) UIButton *selectBtn;
@property (nonatomic,strong) UIView *indexLine;
@property (assign, nonatomic) CGFloat IndexLineX;
@property (nonatomic,weak) id<DWDSegmentedControlDelegate> delegate;
@end
