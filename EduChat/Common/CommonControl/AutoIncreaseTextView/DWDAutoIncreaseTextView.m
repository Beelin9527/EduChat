//
//  DWDAutoIncreaseTextView.m
//  EduChat
//
//  Created by KKK on 16/6/3.
//  Copyright © 2016年 dwd. All rights reserved.
//

/**
 *  自增高的textView
 *
 *  内部逻辑已经处理,外部直接resign可以直接判断是否调用代理
 *  代理回调进行网络请求等数据处理操作
 *
 */
//t2

#define kDWDTextViewEndEditingDone @"endEditingDone"
#define kDWDTextViewEndEditingCancel @"endEditingCancel"

#import "DWDAutoIncreaseTextView.h"
#import "DWDFaceView.h"

#import "NSString+extend.h"

@interface DWDAutoIncreaseTextView () <YYTextViewDelegate, DWDFaceViewDelegate>

@property (nonatomic, strong) DWDFaceView *faceView;
@property (nonatomic, weak) UIButton *emotionButton;

@property (nonatomic, copy) NSString *endEditingType;

@end

@implementation DWDAutoIncreaseTextView

- (instancetype)initWithFrame:(CGRect)frame {
    
    CGRect viewFrame = CGRectMake(frame.origin.x, frame.origin.y, DWDScreenW, 50);
    self = [super initWithFrame:viewFrame];
    if (self) {
        /**
         ------------------------------------
         |                <-5->             |     height
         |<-10-> textview <-5-> button <-5->|       50
         |                <-5->             |
         ------------------------------------
         */
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect textViewRect = CGRectZero;
        textViewRect.origin = (CGPoint){10, 5};
        textViewRect.size = (CGSize){DWDScreenW - 60, 40};
        YYTextView *textView = [YYTextView new];
        textView.returnKeyType = UIReturnKeyDone;
        textView.font = [UIFont systemFontOfSize:14];
        textView.layer.borderColor = DWDColorBackgroud.CGColor;
        textView.layer.borderWidth = 1;
        textView.layer.cornerRadius = 3;
        textView.frame = textViewRect;
        textView.delegate =self;
        [self addSubview:textView];
        _textView = textView;
        
        CGRect emotionRect = CGRectZero;
        emotionRect.origin = (CGPoint){CGRectGetMaxX(textViewRect) + 5, 5};
        emotionRect.size = (CGSize){30, 30};
        UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        emotionButton.frame = emotionRect;
//        [emotionButton setTitle:@"表情" forState:UIControlStateNormal];
        [emotionButton setImage:[UIImage imageNamed:@"ic_expression_normal"]
                       forState:UIControlStateNormal];
        [emotionButton setImage:[UIImage imageNamed:@"ic_expression_press"]
                       forState:UIControlStateHighlighted];
        [emotionButton addTarget:self action:@selector(emotionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:emotionButton];
        _emotionButton = emotionButton;
    }
    return self;
}

#pragma mark - YYTextDelegate
- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView {
//    textView.text = nil;
    self.endEditingType = kDWDTextViewEndEditingCancel;
    [self textViewDidChange:textView];
    return YES;
}

- (void)textViewDidChange:(YYTextView *)textView {
    if ([textView contentSize].height < 40 && (textView.text.length != 0 && textView.text != nil)) {
        return;
    }
    if (textView.frame.size.height > 150 && (textView.text.length != 0 && textView.text != nil)) {
        return;
    }
    if (textView.text.length != 0 || textView.text != nil) {
        if ((textView.text.length == 0 && textView.text == nil)) {
            CGSize contentSize = textView.contentSize;
            contentSize.height = 40;
            textView.contentSize = contentSize;
        }
        CGRect selfFrame = self.frame;
        selfFrame.origin.y = selfFrame.origin.y - ([textView contentSize].height + 10 - selfFrame.size.height);
        selfFrame.size.height = [textView contentSize].height + 10;
        self.frame = selfFrame;
        
        CGRect frame = textView.frame;
        /**
         maxY不变,高度变高,y值 = 原来的y - (新的高度 - 旧的高度)
         */
        frame.origin.y = 5;
        frame.size.height = [_textView contentSize].height;
        textView.frame = frame;
        //    [textView setNeedsLayout];
        //    CGPoint center = _emotionButton.center;
        //    center.y = textView.center.y;
        //    _emotionButton.center = center;
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
- (BOOL)textViewShouldEndEditing:(YYTextView *)textView {
//    [self.textView resignFirstResponder];
    if ([[self endEditingType] isEqualToString:kDWDTextViewEndEditingCancel]) {
        return YES;
    }
    if (!textView.text || !textView.text.length) {
        return YES;
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(autoIncreaseTextViewDidEndEditing:)]) {
            self.textView.text = [self.textView.text trim];
            [_delegate autoIncreaseTextViewDidEndEditing:self];
        }
    }
    return YES;
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) { // 监听键盘点击return key
        //        self.dismissKeyboardType = DWDDismissKeyboardFromReturnKey;
        self.endEditingType = kDWDTextViewEndEditingDone;
//        [_textView.delegate textViewShouldEndEditing:_textView];
        [textView resignFirstResponder];
        return NO;
    } else if (_textView.text.length > 0 && [text isEqualToString:@""]) {
        /** 删除表情所做事件处理 **/
        if ([_textView.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [_textView.text characterAtIndex:location];
                if (c == '[') {
                    _textView.text = [_textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
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

#pragma mark - DWDFaceViewDelegate
- (void)faceView:(DWDFaceView *)faceView didSelectPace:(NSString *)paceName
{
    NSRange range = _textView.selectedRange;
    NSMutableString *string = [[_textView text] mutableCopy];
    
    [string insertString:paceName atIndex:range.location];
//    _textView.text = [NSString stringWithFormat:@"%@%@",_textView.text, paceName];
    _textView.text = string;
    _textView.selectedRange = NSMakeRange(range.location + paceName.length, 0);
}

/** 删除表情按扭事件 **/
- (void)faceViewDidSelectDelete:(DWDFaceView *)faceView
{
    [self textView:_textView shouldChangeTextInRange:NSMakeRange(_textView.text.length - 1, 1) replacementText:@""];
}

/** 发送表情按扭事件 **/
- (void)faceViewDidSelectSend:(DWDFaceView *)faceView
{
    self.endEditingType = kDWDTextViewEndEditingDone;
//    [_textView.delegate textViewShouldEndEditing:self.textView];
    [_textView resignFirstResponder];
//    _textView.text = nil;
}

#pragma mark - Event Response
- (void)emotionBtnClick:(id)sender {
    if ([self.textView.inputView isKindOfClass:[DWDFaceView class]]) {
        self.textView.inputView = nil;
        [self.textView setKeyboardType:UIKeyboardTypeDefault];
        [self.textView reloadInputViews];
        [self.textView becomeFirstResponder];
    } else {
        self.textView.inputView = self.faceView;
        [self.textView reloadInputViews];
        [self.textView becomeFirstResponder];
    }
}

#pragma mark - Setter / Getter
- (DWDFaceView *)faceView {
    if (!_faceView) {
        DWDFaceView *faceView = [[DWDFaceView alloc] initWithFrame:CGRectMake(0,DWDScreenH - DWDTopHight , DWDScreenW, 200)];
        faceView.delegate = self;
        _faceView = faceView;
    }
    return _faceView;
}

- (NSMutableDictionary *)userInfo {
    if (!_userInfo) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return _userInfo;
}

@end
