//
//  DWDRegisterViewController.m
//  EduChat
//
//  Created by apple on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDRegisterViewController.h"
#import "DWDTabbarViewController.h"

#import "UIImage+Utils.h"
#import <YYModel.h>
#import "DWDRSAHandler.h"

#import "DWDCustBaseClient.h"
#import "DWDChatClient.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDPickUpCenterDatabaseTool.h"




@interface DWDRegisterViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) NSTimer *timer;//定时器
@property (assign, nonatomic) int secondsCountDown;//计数标识

@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *codeTextFiled;

@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn; //完成按钮

@property (strong, nonatomic) NSString *codeString;//六位验证码
@property (strong, nonatomic) NSNumber *IDString;//4-教师号 5-家长号


@end

@implementation DWDRegisterViewController

#pragma mark - Life CyCle
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    DWDLog(@"注册控制器----消失");
}

#pragma mark - Setup View
- (void)setupNib
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
    [self.userNameTextFiled setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextFiled setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    [self.codeTextFiled setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.userNameTextFiled becomeFirstResponder];
}

#pragma mark - Getter


#pragma mark - Button Action
-(void)countDown
{
    self.verifyBtn.enabled = NO;
    [self.codeTextFiled becomeFirstResponder];
    
    self.secondsCountDown = 60;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
}

//secondsCountDown = 60;//60秒倒计时
//定时器方法
-(void)timeFireMethod
{
    self.secondsCountDown--;
    
    if(self.secondsCountDown <= 0){
        [self.timer invalidate];
        self.timer = nil;
        
        [self.verifyBtn setEnabled:YES];
        [self.verifyBtn setTitle:@"重新获取" forState:UIControlStateNormal];
      
    }else{
        [self.verifyBtn setTitle:[NSString stringWithFormat:@"%2dS",self.secondsCountDown] forState:UIControlStateNormal];
    }
}

//获取验证码
- (IBAction)getCodeAction:(UIButton *)sender {
    //判断手机号码是否为空
    if (self.userNameTextFiled.text.length<1) {
        [DWDProgressHUD showText:@"手机号码不能为空"];
        return;
    }
    
    //判断手机号码是否正确
    if (![NSString isValidatePhone:self.userNameTextFiled.text]) {
        [DWDProgressHUD showText:@"您输入的手机号码有误"];
        return;

    }
#ifdef DEBUG
    //倒计时
    [self countDown];
    u_int32_t code = arc4random_uniform(899999) + 100000;
    self.codeString = [NSString stringWithFormat:@"%d",code];
    [DWDProgressHUD showText:self.codeString];
#else
    self.verifyBtn.enabled = NO;
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [[DWDCustBaseClient sharedCustBaseClient]
     requestSendVerifyCodeWithPhoneNum:self.userNameTextFiled.text
     dataType:@1
     success:^(id responseObject) {
         [hud hideHud];
        self.codeString =  responseObject;
         //倒计时
         [self countDown];
    } failure:^(NSError *error) {
          [hud showText:error.localizedFailureReason];
        self.verifyBtn.enabled = YES;
    }];
#endif
    
}

#pragma mark - Notification
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.userNameTextFiled.text.length != 0 && self.pwdTextFiled.text.length != 0 && self.codeTextFiled.text.length != 0) {
        self.doneBtn.enabled = YES;
    }else{
        self.doneBtn.enabled = NO;
    }
}


#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextFiled){
        
        [self.pwdTextFiled becomeFirstResponder];
        
    }else if (textField == self.pwdTextFiled){
        
        [self.codeTextFiled becomeFirstResponder];
        
    }else if (textField == self.codeTextFiled)
    {
        [self registerAction:nil];
        
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.userNameTextFiled) {
        if (textField.text.length + string.length - range.length > 11) {
            return NO;
        }
    }else if (textField == self.pwdTextFiled){
        if (textField.text.length + string.length - range.length > 16) {
            return NO;
        }
    }else if (textField == self.codeTextFiled){
        if (textField.text.length + string.length - range.length > 6) {
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

#pragma Request
//注册并登录  idType 4-教师号 6-家长号
- (IBAction)registerAction:(UIButton *)sender {
    
    //判断帐号或密码是否有误
    if (![NSString isValidatePhone:self.userNameTextFiled.text] )
    {
        [DWDProgressHUD showText:@"帐号或密码输入有误"];
        return;
    }
    //判断密码是否在6-16
    if (!(self.pwdTextFiled.text.length>5) || !(self.pwdTextFiled.text.length<17)) {
        [DWDProgressHUD showText:@"密码请输6-16位"];
        return;
    }
    
    
//    //判断验证码是否输入正确
#ifdef DEBUG
#else
    //im
    if (![self.codeString isEqualToString:self.codeTextFiled.text] || [self.codeTextFiled.text isEqualToString:@""] || !self.codeTextFiled.text) {
        [DWDProgressHUD showText:@"验证码输入有误"];
        return;
    }
    
#endif
   
    //request get publick key
    [self requestGetKeyWithPhoneNum:self.userNameTextFiled.text];
}


/** 获取公钥 */
- (void)requestGetKeyWithPhoneNum:(NSString *)phoneNum
{
    //判断帐号或密码是否有误
    if (![NSString isValidatePhone:phoneNum] ) {
        [DWDProgressHUD showText:@"请输入正确手机号码"];
        return;
    }
    //判断密码是否为空
    if (self.pwdTextFiled.text.length == 0) {
        [DWDProgressHUD showText:@"请输入密码"];
        return;
    }
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    [[HttpClient sharedClient]
     getApi:@"token/getKey"
     params:@{@"phoneNum":phoneNum}
     success:^(NSURLSessionDataTask *task, id responseObject)
     {
         NSString *publicKey = responseObject[DWDApiDataKey];
         
         //1.将公钥保存
         BOOL isSave = [[DWDRSAHandler sharedHandler] savePublicKey:publicKey];
         
         //2.对密码、用户名进行加密 与 储存
         if (isSave)
         {
             NSString *pwd = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoString:self.pwdTextFiled.text];
             
             [DWDCustInfo shared].custEncryptPwd = pwd;
             [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:kDWDEncryptPwdCache];
             
             //3.执行注册请求
             [self requestRegisterWithEncryptPassword:pwd hud:hud];
 
         }
         
         else
         {
             [hud showText:@"注册失败，请稍候重试!"];
         }
         
     }
     failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         [hud showText:@"注册失败，请稍候重试!"];
         
     }];
}

/** 请求注册 */
- (void)requestRegisterWithEncryptPassword:(NSString *)encryptPassword hud:(DWDProgressHUD *)hud
{
    NSDictionary *dictParams;
    if (self.registerType == DWDRegisterTypeTeacher) {
        //老师请求
        dictParams = @{@"phoneNum":self.userNameTextFiled.text,
                       @"pwd":encryptPassword,
                       @"idType":@4,
                       @"course":self.courseTag,
                       @"platform":@"iOS",
                       @"deviceid":[DWDCustInfo shared].registrationID ? [DWDCustInfo shared].registrationID : [NSNull null],
                       @"devinfos":[[[UIDevice currentDevice] identifierForVendor] UUIDString]};
    }else{
        //家长请求
        dictParams = @{@"phoneNum":self.userNameTextFiled.text,
                       @"pwd":encryptPassword ,
                       @"idType":@6 ,
                       @"platform":@"iOS",
                       @"deviceid":[DWDCustInfo shared].registrationID ? [DWDCustInfo shared].registrationID : [NSNull null],
                       @"devinfos":[[[UIDevice currentDevice] identifierForVendor] UUIDString]};
    }
   
    
    [[DWDCustBaseClient sharedCustBaseClient]
     getRequestPraram:dictParams
     success:^
    {
        [hud showText:@"注册成功"];
        
        //缓存登录帐号
        [DWDCustInfo shared].custUserName = self.userNameTextFiled.text;
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextFiled.text
                                                  forKey:DWDUserNameCache];
        
        //缓存密码
        [DWDCustInfo shared].custMD5Pwd = [self.pwdTextFiled.text md532BitLower];
        [[NSUserDefaults standardUserDefaults] setObject:[self.pwdTextFiled.text md532BitLower]
                                                  forKey:kDWDMD5PwdCache];
        
        //切换账号时 更改db本地路径
        [[DWDDataBaseHelper sharedManager] resetDB];
        // 先把数据表格建好
        [[DWDContactsDatabaseTool sharedContactsClient] reCreateTables];
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] reCreateTables];
        //往群组表增加isSave字段
        [[DWDContactsDatabaseTool sharedContactsClient] groupTableAddElement:@"isSave"];
        
        [DWDPickUpCenterDatabaseTool sharedManager];
        
            
        //发送通知、是否刷新 会话列表
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
        
        /** 加载个人信息 **/
        [[DWDCustInfo shared]
         requestUserInfoExWithCustId:[DWDCustInfo shared].custId
         success:^
        {
            
            //本地加载数据
            [[DWDCustInfo shared] loadUserInfoData];

            //发通知 刷新班级列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
            
            //切换老师端智能办公与家长班级模块
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChangeLoginIdentify object:nil userInfo:@{@"custIdentity" : [DWDCustInfo shared].custIdentity}];
            
            //销毁本控制器
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
            }];
            
            //建立链接
            [[DWDChatClient sharedDWDChatClient] reconnection];
            
        } failure:^{
             [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DWDLoginCustIdCache];
            //失败就返回登录界面
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    }failure:^(NSError *error) {
        if (error.localizedFailureReason.length > 0)
        {
            [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
        }
        else
        {
            [hud showText:@"注册失败，请稍候重试"];
        }
        
    }];
}





@end









