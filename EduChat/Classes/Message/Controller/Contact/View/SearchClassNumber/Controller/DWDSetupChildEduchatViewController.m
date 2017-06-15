//
//  DWDSetupChildEduchatViewController.m
//  EduChat
//  
//  Created by Gatlin on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSetupChildEduchatViewController.h"

#import "HttpClient.h"
#import "DWDAccountClient.h"
@interface DWDSetupChildEduchatViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *childNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *childEduAcctTextField;

@end

@implementation DWDSetupChildEduchatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置多维度号";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.w, 10)];
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Action
- (void)doneAction
{
    //检验是否存在
    [self checkoutIsHaveAccount:self.childEduAcctTextField.text];
}
#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.childNameTextField) {
        [self.childEduAcctTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    if (textField == self.childEduAcctTextField) {
        if (textField.text.length + string.length - range.length > 16) {
            if (range.length) {
                textField.text = [textField.text substringToIndex:16];
            }
            return NO;
        }
        
    }else if(textField == self.childNameTextField){
        if (textField.text.length + string.length - range.length > 10) {
            if (range.length) {
                textField.text = [textField.text substringToIndex:10];
            }
            return NO;
        }
    }
    return  YES;
}


#pragma mark - Notification
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.childEduAcctTextField.text.length < 6 || self.childNameTextField.text.length == 0 ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}


#pragma mark - Request
- (void)requestData
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.childNameTextField.text = [self.childNameTextField.text trim];
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *params = @{DWDCustId:[DWDCustInfo shared].custId,@"childName":self.childNameTextField.text,@"childEduAcct":self.childEduAcctTextField.text};
    [[HttpClient sharedClient]postApi:@"UserRestService/regChildEduAcct" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        __strong typeof(self) strongSelf = weakSelf;
        [hud hide:YES];
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(setupChildEduchatViewController:childName:educhatAccount:)]) {
            [strongSelf.delegate setupChildEduchatViewController:strongSelf childName:strongSelf.childNameTextField.text educhatAccount:strongSelf.childEduAcctTextField.text];
        }
        [strongSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [hud showText:@"申请失败，请检查网络重新尝试" afterDelay:DefaultTime];
    }];
}

/** 检验是否存在多维度号 */
- (void)checkoutIsHaveAccount:(NSString *)account
{ 
    //校验
    if ([NSString isValidateNumber:account])
    {
        [DWDProgressHUD showText:@"请设置6-16位数字与字母组合"];
        return;
    }
    if (![NSString isValidateSixToSixteen:self.childEduAcctTextField.text]) {
        [DWDProgressHUD showText:@"请设置6-16位数字与字母组合"];
        return;
    }
    
    account = [account trim];
    
     __weak typeof(self) weakSelf = self;
    [[DWDAccountClient sharedAccountClient] requestGetEduChatAccount:account success:^(NSDictionary *info) {
        
        //提交
        [weakSelf requestData];
        
    } failure:^(NSError *error) {
        [DWDProgressHUD showText:@"该多维度号已被抢先使用过啦，换一个试试。"];
    }];
    
}
/*
 参数	必填	类型	值域	说明
 custId	√	long		家长custId
 childName	√	String		孩子名字
 childEduAcct	√	String		孩子多维度账号
*/

@end
