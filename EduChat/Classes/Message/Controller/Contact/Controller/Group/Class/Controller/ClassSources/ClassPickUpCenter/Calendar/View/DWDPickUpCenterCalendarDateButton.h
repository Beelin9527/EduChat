//
//  DWDPickUpCenterCalendarDateButton.h
//  EduChat
//
//  Created by KKK on 16/3/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDPickUpCenterCalendarDateButton;

@protocol DWDPickUpCenterCalendarDateButtonDelegate <NSObject>

@optional
/**
 *  datePicker更新了时间,暂时没啥用
 *
 *  @param dateStr 日期字符串 @"YYYY-MM-dd"
 */
//- (void)dateButton:(DWDPickUpCenterCalendarDateButton *)button DidUpdateDate:(NSDate *)date;

/**
 *  datePicker点击了确定
 */
- (void)dateButton:(DWDPickUpCenterCalendarDateButton *)button DidClickDate:(NSDate *)date;
@end

@interface DWDPickUpCenterCalendarDateButton : UIButton// <UIKeyInput>

@property (nonatomic, weak) id<DWDPickUpCenterCalendarDateButtonDelegate> delegate;

@end
