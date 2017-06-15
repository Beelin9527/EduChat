//
//  DWDPickUpCenterMonthsView.m
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterMonthsView.h"

@implementation DWDPickUpCenterMonthsView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.locale = [NSLocale currentLocale];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [self addSubview:datePicker];
    
    
    
    return self;
}

@end
