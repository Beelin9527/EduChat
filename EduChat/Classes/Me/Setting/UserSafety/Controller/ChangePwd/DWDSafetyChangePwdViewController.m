//
//  DWDSafetyChangePwdViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/25.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSafetyChangePwdViewController.h"
#import "DWDLoginViewController.h"
#import "DWDNavViewController.h"

#import "DWDCustBaseClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDChatClient.h"

@interface DWDSafetyChangePwdViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *arrLines;

@property (weak, nonatomic) IBOutlet UITextField *tfOldPwd;
@property (weak, nonatomic) IBOutlet UITextField *tfNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *tfSurePwd;

@end

@implementation DWDSafetyChangePwdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"修改密码";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    
    //setup line hight
    for (UIView *line in self.arrLines) {
        [line setH:DWDLineH];
    }
 
}


#pragma mark - Private Method
-(void)login
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil];
    
    DWDLoginViewController *controller = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    controller.hidesBottomBarWhenPushed = YES;
    DWDNavViewController *vc = [[DWDNavViewController alloc] initWithRootViewController:controller];
    vc.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)logout
{
    NSData *loginData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeMsgClientLogoutData:[DWDCustInfo shared].custId];
    
    [[DWDChatClient sharedDWDChatClient] sendData:loginData];
    
    
    [[DWDCustBaseClient sharedCustBaseClient] requestAcctCustLogout:[DWDCustInfo shared].custId success:^{
        
        [[DWDCustInfo  shared] clearUserInfoData];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        [[DWDCustInfo  shared] clearUserInfoData];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];

}


#pragma TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location >= 16) {
        return NO;
    }
    return YES;
}

#pragma mark - Request
-(void)commitAction
{
    //校验旧密码
    if (self.tfOldPwd.text.length == 0){
        [DWDProgressHUD showText:@"请输入旧密码"];
        return;
    }
    else if (self.tfOldPwd.text.length > 0 && self.tfOldPwd.text.length < 6) {
        [DWDProgressHUD showText:@"原密码输入错误"];
        return;
    }
    
    //校验旧密码与新密码是否一致
    if([self.tfOldPwd.text isEqualToString:self.tfSurePwd.text])
    {
        [DWDProgressHUD showText:@"新密码与旧密码不能相同"];
        return;
    }
    //校验新密码第一是否输入
    if (self.tfNewPwd.text.length == 0){
        [DWDProgressHUD showText:@"请输入新密码"];
        return;
    }
    //校验新密码第二是否输入
    if (self.tfSurePwd.text.length == 0){
        [DWDProgressHUD showText:@"请确认新密码"];
        return;
    }
    //校验密码是否一致
    if(![self.tfNewPwd.text isEqualToString:self.tfSurePwd.text])
    {
        [DWDProgressHUD showText:@"您输入密码不一致"];
        return;
    }
    //校验密码是否6-12位
    if (self.tfNewPwd.text.length < 6 || self.tfSurePwd.text.length < 6) {
        [DWDProgressHUD showText:@"请输入6-16位密码"];
        return;
    }
    
    [[DWDCustBaseClient sharedCustBaseClient] requestServerResetAcctNumberPwdCustId:[DWDCustInfo shared].custId oldPwd:self.tfOldPwd.text newPwd:self.tfNewPwd.text success:^(id responseObject) {
        
        //清除密码缓存
         [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDWDOrignPwdCache];
        //退出登录
        dispatch_async(dispatch_get_main_queue(), ^{
           [self logout];
        });
        
        
        //弹出登录界面，进行登录
        dispatch_async(dispatch_get_main_queue(), ^{
            [self login];
        });
        
        
    } failure:^(NSError *error) {
        
    }];
}



@end
