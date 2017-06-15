//
//  DWDForgetPwdViewController.m
//  EduChat
//
//  Created by apple on 15/12/3.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDForgetPwdViewController.h"
#import "DWDInputPwdViewController.h"
#import "DWDCustBaseClient.h"

#import "UIImage+Utils.h"
@interface DWDForgetPwdViewController ()

@property (strong, nonatomic) NSTimer *timer;//定时器
@property (assign, nonatomic) int secondsCountDown;

@property (weak, nonatomic) IBOutlet UITextField *phoneTfd;
@property (weak, nonatomic) IBOutlet UITextField *codeTfd;

@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (strong, nonatomic) NSString *codeString;//六位验证码
@end

@implementation DWDForgetPwdViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNib];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark - Setup View
-(void)setupNib
{
    /** 设置登录按钮可否点击 **/
    self.nextBtn.enabled = NO;
    
    self.nextBtn.layer.masksToBounds = YES;
    self.nextBtn.layer.cornerRadius = self.nextBtn.h/2;
    
    [self.nextBtn setTitleColor:[UIColor colorWithWhite:1 alpha:.5] forState:UIControlStateDisabled];
    
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.3]] forState:UIControlStateNormal];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.1]] forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.5]] forState:UIControlStateHighlighted];
    
    /** setup placeholder with whiteColor **/
    [self.phoneTfd setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    [self.codeTfd setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.phoneTfd becomeFirstResponder];
}


#pragma mark - Button Action
//获取验证码
- (IBAction)getCodeAction:(UIButton *)sender
{
    //判断手机号码是否为空
    if (self.phoneTfd.text.length<1) {
        [DWDProgressHUD showText:@"手机号码不能为空"];
        return;
    }
    
    //判断手机号码是否正确
    if (![NSString isValidatePhone:self.phoneTfd.text]) {
        [DWDProgressHUD showText:@"您输入的手机号码有误"];
        return;
    }
   

    self.verifyBtn.enabled = NO;
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [[DWDCustBaseClient sharedCustBaseClient]
     requestSendVerifyCodeWithPhoneNum:self.phoneTfd.text
     dataType:@2
     success:^(id responseObject) {
         [hud hideHud];
         self.codeString =  responseObject;
         //倒计时
         [self countDown];
     } failure:^(NSError *error) {
         [hud showText:error.localizedFailureReason];
         self.verifyBtn.enabled = YES;
     }];

}

//下一步
- (IBAction)nextAction:(UIButton *)sender
{
    //判断手机号码是否正确
    if (![NSString isValidatePhone:self.phoneTfd.text]) {
        [DWDProgressHUD showText:@"您输入的手机号码有误"];
        return;
    }
    //判断验证码是否输入正确
    if (![self.codeString isEqualToString:self.codeTfd.text] || [self.codeTfd.text isEqualToString:@""] || !self.codeTfd.text) {
        [DWDProgressHUD showText:@"验证码输入有误"];
        return;
    }
    [self pushToVcWithClassName:NSStringFromClass([DWDInputPwdViewController class]) title:@"确认密码" userName:self.phoneTfd.text];
}


#pragma mark - Private Method
-(void)countDown
{
    [self.verifyBtn setEnabled:NO];
    [self.codeTfd becomeFirstResponder];
    
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
        
        [self.verifyBtn setEnabled:YES];
        [self.verifyBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.verifyBtn setTitleColor:DWDColorMain forState:UIControlStateNormal];
    }else{
       
        [self.verifyBtn setTitle:[NSString stringWithFormat:@"%2dS",self.secondsCountDown] forState:UIControlStateNormal];
    }
}
//push新的ViewController
- (void)pushToVcWithClassName:(NSString *)VCName title:(NSString*)title userName:(NSString *)userName{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:VCName bundle:nil];
    DWDInputPwdViewController *vc = [sb instantiateViewControllerWithIdentifier:VCName];
    vc.title = title;
    vc.userName = userName;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Notification
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.phoneTfd.text.length != 0 && self.codeTfd.text.length != 0) {
        self.nextBtn.enabled = YES;
    }else{
        self.nextBtn.enabled = NO;
    }
}


#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.phoneTfd){
        
        [self.codeTfd becomeFirstResponder];
        
    }else{
    
        [self nextAction:nil];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.phoneTfd){
        if (textField.text.length >= 11 && ![string isEqualToString:@""]) {
            return NO;
        }
    }else if (textField == self.codeTfd){
        if (textField.text.length >= 6 && ![string isEqualToString:@""]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Event Delegate
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}
@end
