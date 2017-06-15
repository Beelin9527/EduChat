//
//  DWDSendVerifyView.m
//  EduChat
//
//  Created by Gatlin on 15/12/25.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSendVerifyView.h"
#import "DWDCustBaseClient.h"

#import "UIImage+Utils.h"
@interface DWDSendVerifyView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnVerify;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UITextField *tfVerifyCode;

@property (strong, nonatomic) NSTimer *timer;//定时器
@property (assign, nonatomic) int secondsCountDown;

@property (strong, nonatomic) NSString *codeString;
@end

@implementation DWDSendVerifyView


-(void)awakeFromNib
{
    [super awakeFromNib];
    _tfPhone.delegate = self;
    _tfVerifyCode.delegate = self;
    
    _btnVerify.layer.masksToBounds = YES;
    _btnVerify.layer.cornerRadius = 4;
    [_btnVerify setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [_btnVerify setBackgroundImage:[UIImage imageWithColor:DWDColorSeparator] forState:UIControlStateDisabled];
    
    _btnNext.layer.masksToBounds = YES;
    _btnNext.layer.cornerRadius = 20;
    
    [_btnNext setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [_btnNext setBackgroundImage:[UIImage imageWithColor:DWDColorSeparator] forState:UIControlStateDisabled];
    
     _btnNext.enabled = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sendVerifyView
{
    DWDSendVerifyView *view = [[NSBundle mainBundle] loadNibNamed:@"DWDSendVerifyView" owner:nil options:nil][0];
    
    return view;
}

#pragma mark - Setter
/** 如果是更改手机号，检测是否自己发送验证码 **/
- (void)setAutoSend:(BOOL)autoSend
{
    _autoSend = autoSend;
    if (autoSend) {
        [self didSelectBtnVerifyAction:nil];
    }
}


#pragma mark - Button Action
-(void)countDown
{
    [self.btnVerify setEnabled:NO];
    [self.btnVerify setBackgroundColor:DWDColorSecondary];
    [self.tfVerifyCode becomeFirstResponder];
    
    self.secondsCountDown = 60;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
}

//secondsCountDown = 60;//60秒倒计时
//定时器方法
-(void)timeFireMethod{
    
    self.secondsCountDown--;
    
    if(self.secondsCountDown <= 0){
        [self.timer invalidate];
        self.timer = nil;
        
        [self.btnVerify setEnabled:YES];
        [self.btnVerify setTitle:@"重新获取" forState:UIControlStateNormal];
    }else{
        [self.btnVerify setTitle:[NSString stringWithFormat:@"%2dS",self.secondsCountDown] forState:UIControlStateNormal];
    }
}

- (IBAction)didSelectBtnVerifyAction:(UIButton *)sender {
    if (self.isAutosend){
        __weak typeof(self) weakSelf = self;
        self.btnVerify.enabled = NO;
         DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self];
        [[DWDCustBaseClient sharedCustBaseClient]
         requestSendVerifyCodeWithPhoneNum:[DWDCustInfo shared].custMobile
         dataType:@4
         success:^(id responseObject) {
             [hud hideHud];
              __strong typeof(self) strongSelf = weakSelf;
             strongSelf.codeString =  responseObject;
             [self countDown];
             
         } failure:^(NSError *error) {
             [hud showText:error.localizedFailureReason];
             self.btnVerify.enabled = YES;
         }];
    }else{
        
        //判断手机号码是否为空
        if (self.tfPhone.text.length<1) {
            [DWDProgressHUD showText:@"手机号码不能为空"];
            return;
        }
        //判断手机号码是否正确
        if (![NSString isValidatePhone:self.tfPhone.text]) {
            [DWDProgressHUD showText:@"您输入的手机号码有误"];
            return;
        }
        self.btnVerify.enabled = NO;
        DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self];
        [[DWDCustBaseClient sharedCustBaseClient]
         requestSendVerifyCodeWithPhoneNum:self.tfPhone.text
         dataType:@5
         success:^(id responseObject) {
             [hud hideHud];
             self.codeString =  responseObject;
             [self countDown];
             
         } failure:^(NSError *error) {
            [hud showText:error.localizedFailureReason];
             self.btnVerify.enabled = YES;
             
         }];
    }

   
    
    
}

// next action
- (IBAction)didSelectBtnNextAction:(UIButton *)sender {
    
    //判断手机号码是否为空
    if (self.tfPhone.text.length<1 && self.isAutosend == NO) {
        [DWDProgressHUD showText:@"手机号码不能为空"];
        return;
    }
    //判断手机号码是否正确 自动往原手机发不用检测 、
    if (self.isAutosend == NO) {
        if (![NSString isValidatePhone:self.tfPhone.text]) {
            [DWDProgressHUD showText:@"您输入的手机号码有误"];
            return;
        }
    }
    
    //校验验证码是否正确
     if (![self.codeString isEqualToString:self.tfVerifyCode.text] || [self.tfVerifyCode.text isEqualToString:@""] || !self.tfVerifyCode.text) {
     [DWDProgressHUD showText:@"验证码输入有误"];
     return;
     }
    
    
    [self endEditing:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendVerifyViewDidSelectNextButton:)]) {
        
        [self.delegate sendVerifyViewDidSelectNextButton:self];
    }
}

#pragma mark - Notification
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.tfVerifyCode.text.length == 0) {
        self.btnNext.enabled = NO;
    }else{
        self.btnNext.enabled = YES;
    }
}


#pragma mark - TextFiled Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.tfPhone == textField) {
        if (textField.text.length + string.length - range.length > 11) {
            return NO;
        }
    }
    
    if (self.tfVerifyCode == textField) {
        if (textField.text.length + string.length - range.length > 6) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Event Delegate
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
    
}
@end
