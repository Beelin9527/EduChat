//
//  DWDLeavePaperDateTimeLabel.m
//  EduChat
//
//  Created by KKK on 16/5/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLeavePaperDateTimeLabel.h"

@interface DWDLeavePaperDateTimeLabel ()
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation DWDLeavePaperDateTimeLabel

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    
//    
//    
//    return self;
//}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIView *)inputView {
    // uidatepicker
    if (!_datePicker) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.locale = [NSLocale currentLocale];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker = datePicker;
    }
    return _datePicker;
}

- (UIView *)inputAccessoryView {
    // toolbar
    if (!_toolbar) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 44)];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(datePickerDidClickDoneButton)];
        [doneButton setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],
          NSForegroundColorAttributeName,nil]
                                  forState:UIControlStateNormal];
        UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        toolbar.items = @[flexibleSeparator, doneButton];
        _toolbar = toolbar;
    }
    return _toolbar;
}

- (void)datePickerDidClickDoneButton {
    self.textColor = DWDRGBColor(51, 51, 51);
    NSString *str = [self.formatter stringFromDate:_datePicker.date];
    self.text = str;
    if (_delegate && [_delegate respondsToSelector:@selector(label:didClickToolbarDoneButton:)]) {
        [_delegate label:self didClickToolbarDoneButton:_datePicker.date];
    }
}

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"YYYY/MM/dd HH:mm";
        _formatter = formatter;
    }
    return _formatter;
}

@end
