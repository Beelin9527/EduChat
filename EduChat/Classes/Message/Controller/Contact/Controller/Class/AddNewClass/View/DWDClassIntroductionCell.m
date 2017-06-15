//
//  DWDClassIntroductionCell.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassIntroductionCell.h"
#import "DWDAddNewClassIntroductionField.h"

@interface DWDClassIntroductionCell() <UITextViewDelegate>

@end

@implementation DWDClassIntroductionCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        DWDAddNewClassIntroductionField *textView = [[DWDAddNewClassIntroductionField alloc] init];
        textView.delegate = self;
        _textView = textView;
        [self.contentView addSubview:textView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _textView.frame = self.bounds;
}


#pragma mark - <UITextViewDelegate>


- (BOOL)textView:(DWDAddNewClassIntroductionField *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (!text.length && textView.text.length == 1) {
        textView.str1 = @"请输入说明文字";
        [textView setNeedsDisplay];
        return YES;
    }else{
        textView.str1 = nil;
        [textView setNeedsDisplay];
        return YES;
    }
}

@end
