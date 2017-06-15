//
//  DWDInputPwdViewController.m
//  EduChat
//
//  Created by apple on 15/12/3.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDInputPwdViewController.h"

#import "DWDCustBaseClient.h"
#import "UIImage+Utils.h"
@interface DWDInputPwdViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *pwdTextField_1;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField_2;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@end

@implementation DWDInputPwdViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNib];
   
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    self.doneBtn.enabled = NO;
    
    self.doneBtn.layer.masksToBounds = YES;
    self.doneBtn.layer.cornerRadius = self.doneBtn.h/2;
    
    [self.doneBtn setTitleColor:[UIColor colorWithWhite:1 alpha:.5] forState:UIControlStateDisabled];
    
    [self.doneBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.3]] forState:UIControlStateNormal];
    [self.doneBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.1]] forState:UIControlStateDisabled];
    [self.doneBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.5]] forState:UIControlStateHighlighted];
    
    /** setup placeholder with whiteColor **/
    [self.pwdTextField_1 setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField_2 setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.pwdTextField_1 becomeFirstResponder];
}


#pragma mark - Button Action
- (IBAction)doneAction:(UIButton *)sender {
    
    //校验密码是否6-16位
    if(self.pwdTextField_1.text.length < 6 || self.pwdTextField_2.text.length < 6){
        [DWDProgressHUD showText:@"请输入6-16位密码"];
        return;
    }
    
    
    //校验密码是否一致
    if (![self.pwdTextField_1.text isEqualToString:self.pwdTextField_2.text]) {
        [DWDProgressHUD showText:@"您请入的密码不一致"];
        return;
    }
    
    [self requestChangePwd];
}

#pragma mark - Notification
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.pwdTextField_1.text.length != 0 && self.pwdTextField_2.text.length != 0) {
        self.doneBtn.enabled = YES;
    }else{
        self.doneBtn.enabled = NO;
    }
}


#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==self.pwdTextField_1) {
        [self.pwdTextField_2 becomeFirstResponder];
    }else{
        
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.text.length + string.length - range.length) > 16) {
        if (range.length) {
            textField.text = [textField.text substringToIndex:16];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Event Delegate
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}


#pragma mark - Request
- (void)requestChangePwd
{

   [[DWDCustBaseClient sharedCustBaseClient] requestServerRestForgotAcctPwdUserName:self.userName newPwd:self.pwdTextField_1.text success:^(id responseObject) {
       
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.navigationController popToRootViewControllerAnimated:YES];
       });
       
   } failure:^(NSError *error) {
       
   }];
}
@end
