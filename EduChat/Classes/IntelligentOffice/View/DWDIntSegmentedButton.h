//
//  DWDSegmentedControl.h
//  EduChat
//
//  Created by Beelin on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//  选择按钮control

#import <UIKit/UIKit.h>

@class DWDIntSegmentedButton;
@protocol DWDIntSegmentedButtonDelegate <NSObject>
-(void)segmentedControlIndexButtonView:(DWDIntSegmentedButton *)indexButtonView lickBtnAtTag:(NSInteger)tag;
@end


@interface DWDIntSegmentedButton : UIView

/** 指定选哪个按钮 */
+ (instancetype)segmentedControlWithFrame:(CGRect)frame Titles:(NSArray *)titles index:(NSInteger)index;

/** 改变下标 */
- (void)setupSelectButtonIndex:(NSInteger)index;

@property (nonatomic, strong) UIColor *tintColor;

/** 提供block 与 delegate,选择一种即可 */
@property (nonatomic, copy) void(^clickButtonBlock)(NSInteger tag);
@property (nonatomic,weak) id<DWDIntSegmentedButtonDelegate> delegate;
@end
