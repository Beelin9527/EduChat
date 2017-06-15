//
//  DWDBottomTextField.m
//  EduChat
//
//  Created by Superman on 16/1/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDBottomTextField.h"
#import "DWDFaceView.h"

@interface DWDBottomTextField()<DWDFaceViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) DWDFaceView *faceView;
@property (nonatomic, assign) BOOL keyboardType;
@end

@implementation DWDBottomTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (IBAction)emotionBtnClick:(id)sender {
    DWDMarkLog(@"keyboardType:%d", _keyboardType);
//    if (_keyboardType == NO) {
//        self.Field.inputView = self.faceView;
//        [self.faceView removeFromSuperview];
//        [self.Field becomeFirstResponder];
//        [self.Field reloadInputViews];
//    } else {
//        self.Field.inputView = nil;
//        [self.Field setKeyboardType:UIKeyboardTypeDefault];
//        [self.Field reloadInputViews];
//        [self.Field becomeFirstResponder];
//    }
    if ([self.Field.inputView isKindOfClass:[DWDFaceView class]]) {
        self.Field.inputView = nil;
        [self.Field setKeyboardType:UIKeyboardTypeDefault];
        [self.Field reloadInputViews];
        [self.Field becomeFirstResponder];
    } else {
        self.Field.inputView = self.faceView;
        [self.faceView removeFromSuperview];
        [self.Field becomeFirstResponder];
        [self.Field reloadInputViews];
    }
//    _keyboardType = !_keyboardType;
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!textField.text || !textField.text.length) {
        return NO;
    }
    [self.Field resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(bottomTextFieldDidEndEditing:)]) {
        [self.delegate bottomTextFieldDidEndEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _keyboardType = !_keyboardType;
}


#pragma mark - DWDFaceViewDelegate

- (void)faceView:(DWDFaceView *)faceView didSelectPace:(NSString *)paceName
{
    self.Field.text = [NSString stringWithFormat:@"%@%@",self.Field.text, paceName];
}

/** 删除表情按扭事件 **/
- (void)faceViewDidSelectDelete:(DWDFaceView *)faceView
{
    [self textField:self.Field shouldChangeCharactersInRange:NSMakeRange(self.Field.text.length - 1, 1) replacementString:@""];
}

/** 发送表情按扭事件 **/
- (void)faceViewDidSelectSend:(DWDFaceView *)faceView
{
    [self.Field.delegate textFieldShouldReturn:self.Field];
    self.Field.text = nil;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([string isEqualToString:@"\n"]) { // 监听键盘点击return key
        
//        self.dismissKeyboardType = DWDDismissKeyboardFromReturnKey;
        
        [self.Field.delegate textFieldShouldReturn:self.Field];
        
        self.Field.text = nil;
        
        return NO;
    } else if (self.Field.text.length > 0 && [string isEqualToString:@""]) {
        /** 删除表情所做事件处理 **/
        if ([self.Field.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [self.Field.text characterAtIndex:location];
                if (c == '[') {
                    self.Field.text = [self.Field.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    return NO;
                }
                else if (c == ']') {
                    return YES;
                }
            }
        }
    }
    
    return YES;
}

#pragma mark - setter / getter
- (DWDFaceView *)faceView
{
    if (!_faceView) {
        DWDFaceView *faceView = [[DWDFaceView alloc]initWithFrame:CGRectMake(0,DWDScreenH - DWDTopHight , DWDScreenW, 200)];
        [faceView setDelegate:self];
        [self addSubview:faceView];
        _faceView = faceView;
    }
    return _faceView;
}

@end
