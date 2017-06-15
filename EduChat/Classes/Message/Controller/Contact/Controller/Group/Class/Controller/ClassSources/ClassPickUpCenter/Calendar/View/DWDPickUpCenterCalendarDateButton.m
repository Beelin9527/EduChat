//
//  DWDPickUpCenterCalendarDateButton.m
//  EduChat
//
//  Created by KKK on 16/3/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterCalendarDateButton.h"
#import "NSString+extend.h"

@interface DWDPickUpCenterCalendarDateButton ()

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIToolbar *toolBar;

@end


@implementation DWDPickUpCenterCalendarDateButton

#pragma mark - Private Method
//- (void)datePickerDidUpdateDate:(UIDatePicker *)datePicker {
//    if ([self.delegate respondsToSelector:@selector(dateButton:DidUpdateDate:)]) {
//        [self.delegate dateButton:self DidUpdateDate:datePicker.date];
//    }
//}

- (void)datePickerDidClickDoneButton {
    if ([self.delegate respondsToSelector:@selector(dateButton:DidClickDate:)]) {
        [self.delegate dateButton:self DidClickDate:self.datePicker.date];
    }
}

#pragma mark - Show Keyboard Method
- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - Setter / Getter
//inputView
- (UIView *)inputView {
    return self.datePicker;
}

//inputAccessoryView

- (UIView *)inputAccessoryView {
    return self.toolBar;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.locale = [NSLocale currentLocale];
        datePicker.datePickerMode = UIDatePickerModeDate;
//        [datePicker addTarget:self action:@selector(datePickerDidUpdateDate:) forControlEvents:UIControlEventValueChanged];
        _datePicker = datePicker;
    }
    return _datePicker;
}

- (UIToolbar *)toolBar {
    if (!_toolBar) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 44)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(datePickerDidClickDoneButton)];
        [doneButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],
          NSForegroundColorAttributeName,nil]
                                  forState:UIControlStateNormal];
        UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        toolbar.items = @[flexibleSeparator, doneButton];
        _toolBar = toolbar;
    }
    return _toolBar;
}

@end
