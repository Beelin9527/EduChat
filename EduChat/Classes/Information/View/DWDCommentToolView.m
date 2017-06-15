//
//  DWDCommentToolView.m
//  EduChat
//
//  Created by Gatlin on 16/8/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDCommentToolView.h"
#import "DWDFaceView.h"

#import <YYTextView.h>
static CGFloat textViewMax = 85;
@interface DWDCommentToolView() <DWDFaceViewDelegate,YYTextViewDelegate>

@property (nonatomic, strong) DWDFaceView *faceView;
@property (nonatomic, strong) UIButton *faceBtn;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat ToolViewHight; //默认50 随textViewHeight而变化,+20
@property (nonatomic, assign) NSUInteger location;//光标位置
@end
@implementation DWDCommentToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _ToolViewHight = 50;
        [self setupControl];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setupControl
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 0.7)];
    line.backgroundColor = DWDColorSeparator;
    [self addSubview:line];
    
    _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _praiseBtn.frame = CGRectMake(DWDScreenW - 45, 10, 30, 30);
    [_praiseBtn setImage:[UIImage imageNamed:@"ic_praise_normal"]  forState:UIControlStateNormal];
    [_praiseBtn setImage:[UIImage imageNamed:@"ic_praise_selected"]  forState:UIControlStateSelected];
    [_praiseBtn addTarget:self action:@selector(pariseAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_praiseBtn];
    
    UIButton *faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _faceBtn = faceBtn;
    faceBtn.frame = CGRectMake(DWDScreenW - 85, 10, 30, 30);
    [faceBtn setImage:[UIImage imageNamed:@"ic_expression"] forState:UIControlStateNormal];
    [faceBtn addTarget:self action:@selector(emotionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:faceBtn];
    
    self.textView = [[YYTextView alloc] init];
    self.textView.frame = CGRectMake(10, 10, DWDScreenW - 105, 30);
    self.textView.delegate = self;
    self.textView.layer.borderColor = DWDColorSeparator.CGColor;
    self.textView.layer.borderWidth = 0.7;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 5;
    self.textView.placeholderText = @"写评论，交流下...";
    self.textView.textColor = DWDColorSecondary;
    self.textView.font = DWDFontContent;
    self.textView.placeholderFont = DWDFontContent;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.enablesReturnKeyAutomatically = YES;
    self.textView.bounces = NO;
    [self addSubview:self.textView];

}

#pragma mark - Getter
- (DWDFaceView *)faceView {
    if (!_faceView) {
        DWDFaceView *faceView = [[DWDFaceView alloc] initWithFrame:CGRectMake(0,self.ToolViewHight , DWDScreenW, 200)];
        faceView.delegate = self;
        _faceView = faceView;
        [self addSubview:faceView];
    }
    return _faceView;
}

#pragma mark - Setter
- (void)setPraiseSta:(BOOL)praiseSta
{
    _praiseSta = praiseSta;
    
    if (praiseSta) {
        self.praiseBtn.selected = YES;
    }else{
        self.praiseBtn.selected = NO;
    }
}
#pragma mark - Event Response
- (void)emotionBtnClick:(id)sender {
//    if ([self.textView.inputView isKindOfClass:[DWDFaceView class]]) {
////        [self.faceBtn setImage:[UIImage imageNamed:@"ic_expression"] forState:UIControlStateNormal];
//        self.textView.inputView = nil;
//        [self.textView setKeyboardType:UIKeyboardTypeDefault];
//        [self.textView reloadInputViews];
//        [self.textView becomeFirstResponder];
//    } else {
//        [self.faceBtn setImage:[UIImage imageNamed:@"ic_keyboard_normal"] forState:UIControlStateNormal];
//        self.textView.inputView = self.faceView;
//        [self.textView reloadInputViews];
//        [self.textView becomeFirstResponder];
//    }
    [self.textView resignFirstResponder];
    self.faceView.hidden = NO;
    
    self.textView.text = self.content;
    [self textViewDidChange:self.textView];//设计文本框高度
    self.faceView.y = self.ToolViewHight;//重新设置faceview.y
    self.y = DWDScreenH - DWDTopHight - self.faceView.h - self.ToolViewHight;
}

- (void)pariseAction
{
    self.praiseActionBlock ? self.praiseActionBlock(self.praiseBtn) : nil;
}

#pragma mark - Notification Implementtation
- (void)showKeyboard:(NSNotification *)noti
{
    NSValue *value = [noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    _keyboardHeight = keyboardRect.size.height;
    
    NSNumber *duration= [noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
   [UIView animateWithDuration:[duration floatValue] animations:^{
       self.y = DWDScreenH - DWDTopHight - keyboardRect.size.height - self.ToolViewHight;
   }];
}

- (void)hideKeyboard:(NSNotification *)noti
{
        NSNumber *duration= [noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    _keyboardHeight = 0.0;
    [UIView animateWithDuration:[duration floatValue] animations:^{
        self.y = DWDScreenH - DWDTopHight - self.ToolViewHight;
    }];
 
}
#pragma mark - DWDFaceViewDelegate
- (void)faceView:(DWDFaceView *)faceView didSelectPace:(NSString *)paceName
{
//    NSRange range = _textView.selectedRange;
    NSMutableString *string = [[_textView text] mutableCopy];
    
    //防止删了文本，光标位置大于文本长度，导致蹦溃
    if(self.location > _textView.text.length){
        self.location = _textView.text.length;
    }
    [string insertString:paceName atIndex:self.location];
    
    _textView.text = string;
    _textView.selectedRange = NSMakeRange(self.location + paceName.length, 0);
    
    //重新设置光标后加表情字符长度
    self.location += paceName.length;
    
    self.content = self.textView.text;
    
    
}

/** 删除表情按扭事件 **/
- (void)faceViewDidSelectDelete:(DWDFaceView *)faceView
{
    [self textView:_textView shouldChangeTextInRange:NSMakeRange(_textView.text.length - 1, 1) replacementText:@""];
    
    self.content = self.textView.text;
 
}

/** 发送表情按扭事件 **/
- (void)faceViewDidSelectSend:(DWDFaceView *)faceView
{
    //校验文本是否为空字符串,是则 return
    if ([self.textView.text trim].length == 0) {
        [DWDProgressHUD showText:@"消息不能为纯空格"];
        return;
    }
    
    
    self.y = DWDScreenH - DWDTopHight - self.ToolViewHight;
    self.location = 0;
    self.sendTextActionBlock ? self.sendTextActionBlock(self.content,self.commentModel) : nil;
    [self textViewDidEndEditing:self.textView];
    
}
#pragma mark - TextView Delegate
- (void)textViewDidBeginEditing:(YYTextView *)textView
{
    self.beginEnditingActionBlock ? self.beginEnditingActionBlock() : nil;
    textView.text = self.content;
    [self textViewDidChange:textView];
    self.faceView.hidden = YES;

    //标记光标位置
     self.location = textView.selectedRange.location;
    
}

- (void)textViewDidEndEditing:(YYTextView *)textView
{
    self.content = textView.text;
    textView.text = nil;
}


- (void)textViewDidChangeSelection:(YYTextView *)textView{
    if ([textView isFirstResponder]) {
        //标记光标位置
        self.location = textView.selectedRange.location;
    }
    DWDLog(@"location: ---- %zd",(unsigned long)textView.selectedRange.location);
     DWDLog(@"location: ---- %zd",self.location);
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        
        //校验文本是否为空字符串,是则 return
        if ([self.textView.text trim].length == 0) {
            [DWDProgressHUD showText:@"消息不能为纯空格"];
            return NO;
        }
        
        [self.textView resignFirstResponder];
        self.location = 0;
        self.sendTextActionBlock ? self.sendTextActionBlock(self.content,self.commentModel) : nil;
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
//    if ((textView.text.length + text.length -range.length) > 300) {
//        return NO;
//    }
    return YES;
}


- (void)textViewDidChange:(YYTextView *)textView
{
    
    CGFloat textHeight = [textView.text boundingRectWithfont:textView.font sizeMakeWidth:textView.w].height;
    CGFloat textViewHeight = MAX(textHeight, 30);
    if (textViewHeight >= textViewMax) {
        if (self.y > DWDScreenH - DWDTopHight - self.keyboardHeight - (textView.h+20)) {
            self.y = DWDScreenH - DWDTopHight - self.keyboardHeight - self.ToolViewHight;
        }
        
        self.ToolViewHight = textViewMax + 20;
        textView.h = textViewMax;
        self.textView.contentOffset = CGPointMake(0, textView.contentSize.height - textView.h);
        self.h = self.faceView.h + self.ToolViewHight;
    }else{
        self.y -= (textViewHeight + 20) - self.ToolViewHight;
        
        self.ToolViewHight = textViewHeight + 20;
        textView.h = textViewHeight;
        self.faceView.y = self.ToolViewHight;//重新设置faceview.y
        self.h = self.faceView.h + self.ToolViewHight;
    }
}
@end
