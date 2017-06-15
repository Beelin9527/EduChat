//
//  DWDLoginViewController.m
//  EduChat
//
//  Created by Gatlin on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLoginViewController.h"
#import "DWDRegisterViewController.h"
#import "DWDForgetPwdViewController.h"
#import "DWDTabbarViewController.h"

#import "DWDSelectRegisterIdView.h"

#import "DWDCustBaseClient.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDChatMsgDataClient.h"

#import "UIImage+Utils.h"
#import "DWDLoginDataHandler.h"
#import "DWDRSAHandler.h"
#import "DWDKeyChainTool.h"
@interface DWDLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong, nonatomic)  UIButton *bgBlackView;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrTfImageViews;
@property (strong, nonatomic) DWDSelectRegisterIdView *selectRegisterIdView;

@property (nonatomic, strong) DWDRSAHandler *handler;
@end

@implementation DWDLoginViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNib];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(textFielDidChange)
                                                name:UITextFieldTextDidChangeNotification
                                              object:nil];
    
    [self.view addSubview:self.selectRegisterIdView];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self cancleAction];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Setup View
- (void)setupNib
{
    //检测登录名是否有缓存
    self.userName.text = [[NSUserDefaults standardUserDefaults] objectForKey:DWDUserNameCache];
    self.pwd.text = [[NSUserDefaults standardUserDefaults] objectForKey:kDWDOrignPwdCache];
    self.pwd.enablesReturnKeyAutomatically = YES;
    /** 设置登录按钮可否点击 **/
    if (self.userName.text.length == 0 &&self.pwd.text.length == 0) {
        self.loginBtn.enabled = NO;
        [self.userName becomeFirstResponder];
    }else if (self.userName.text.length > 0 && self.pwd.text.length == 0){
        self.loginBtn.enabled = NO;
        [self.pwd becomeFirstResponder];
    }
    
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = self.loginBtn.h/2;
    
    [self.loginBtn setTitleColor:[UIColor colorWithWhite:1 alpha:.5] forState:UIControlStateDisabled];
    
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.3]] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.1]] forState:UIControlStateDisabled];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:.5]] forState:UIControlStateHighlighted];
    
    for (UIImageView *imageView in self.arrTfImageViews) {
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.h/2;
        imageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:.5].CGColor;
        imageView.layer.borderWidth = 1;
    }
    
    /** setup placeholder with whiteColor **/
    [self.userName setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwd setValue:[UIColor colorWithWhite:1 alpha:.5] forKeyPath:@"_placeholderLabel.textColor"];
    
}
- (void)setupSelectRegisterIdView
{
    
    if (!_selectRegisterIdView) {
        [self.view addSubview:({
            self.bgBlackView = [UIButton buttonWithType:UIButtonTypeCustom];
            self.bgBlackView.frame = self.view.bounds;
            self.bgBlackView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
            [self.bgBlackView addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchDown];
            self.bgBlackView;
        })];

        [self.view addSubview:({
            _selectRegisterIdView = [DWDSelectRegisterIdView selectRegisterIdView];
            _selectRegisterIdView.frame = CGRectMake(0, DWDScreenH - 280, DWDScreenW, 280);
            
            _selectRegisterIdView.selectParentAction =  @selector(parentAction);
            _selectRegisterIdView.selectCancleAction =  @selector(cancleAction);
            _selectRegisterIdView.selectTeacherSubjectAction = @selector(pushtTeacherVC:);
            _selectRegisterIdView;
        })];
    }
    
}

#pragma mark - Button Action
//登录
- (IBAction)loginAction:(UIButton *)sender
{
    [self.view endEditing:YES];
   
    //request get public key
    [self requestGetKeyWithPhoneNum:self.userName.text];
    
}

//忘记密码
- (IBAction)forgetPwdAction:(UIButton *)sender
{
    [self pushToVcWithClassName:NSStringFromClass([DWDForgetPwdViewController class]) title:@"忘记密码"];
}
//以游客浏览
- (IBAction)backRootMianAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 点击注册老师科目 **/
- (void)pushtTeacherVC:(UIButton *)sender
{
    NSNumber *tag = [NSNumber numberWithInteger:sender.tag];
   [self pushToVcWithClassName:NSStringFromClass([DWDRegisterViewController class]) title:@"老师注册" courseTag:tag];
}
/** 点击注册家长 **/
- (void)parentAction
{
    [self pushToVcWithClassName:NSStringFromClass([DWDRegisterViewController class]) title:@"家长注册" courseTag:0];
}
/** 点击注册 **/
- (IBAction)registerAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    [self setupSelectRegisterIdView];
    
}
/** 点击取消注册 **/
- (void)cancleAction
{
    [self.selectRegisterIdView removeFromSuperview];
    self.selectRegisterIdView = nil;
    [self.bgBlackView removeFromSuperview];
    self.bgBlackView = nil;
}

/** 点击背景，移除背景黑 **/
- (void)removeSelf
{
    [self cancleAction];
    
}


#pragma mark - Private Method
/** push register ViewController **/
- (void)pushToVcWithClassName:(NSString *)VCName title:(NSString*)title courseTag:(NSNumber *)courseTag
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:VCName bundle:nil];
    DWDRegisterViewController *vc = [sb instantiateViewControllerWithIdentifier:VCName];
    vc.title = title;
    vc.courseTag = courseTag;
    vc.registerType = (courseTag ? DWDRegisterTypeTeacher : DWDRegisterTypeParent);
    [self.navigationController pushViewController:vc animated:YES];
}
/** push forgetPwdViewController ViewController **/
- (void)pushToVcWithClassName:(NSString *)VCName title:(NSString*)title 
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:VCName bundle:nil];
    DWDForgetPwdViewController *vc = [sb instantiateViewControllerWithIdentifier:VCName];
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification Implementtation
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.userName.text.length != 0 && self.pwd.text.length != 0 ) {
        self.loginBtn.enabled = YES;
    }else{
        self.loginBtn.enabled = NO;
    }
}


#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userName)
    {
        [self.pwd becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        //登录
        [self loginAction:nil];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.userName) {
        if (textField.text.length + string.length - range.length > 11) {
            return NO;
        }
    }else if (textField == self.pwd){
        if (textField.text.length + string.length - range.length > 16) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (textField == self.userName) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDWDOrignPwdCache];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DWDUserNameCache];
        self.pwd.text = nil;
    }else if (textField == self.pwd) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kDWDOrignPwdCache];
    }
    return YES;
}

#pragma mark - UIEvent Delegate
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



#pragma mark - Request
/** 获取公钥 */
- (void)requestGetKeyWithPhoneNum:(NSString *)phoneNum
{
    
    //判断帐号或密码是否有误
    if (![NSString isValidatePhone:phoneNum] ) {
        [DWDProgressHUD showText:@"帐号或密码输入有误"];
        return;
    }
    //判断密码是否为空
    if (self.pwd.text.length == 0) {
        [DWDProgressHUD showText:@"请输入密码"];
        return;
    }
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [DWDLoginDataHandler requestGetPublicKeyWithPhoneNum:phoneNum
                                                password:self.pwd.text
                                                 success:^(NSString *publicKey,NSString *password) {
                                                     
                                                     //app登录、保存返回的Token
                                                     [self requestLoginWithUserName:self.userName.text encryptPassword:password hud:hud];
                                                     
                                                 } failure:^(NSError *error){
                                                     [hud showText:@"登录失败，请稍候重试!"];
                                                 }];
}


/** 登录 */
- (void)requestLoginWithUserName:(NSString *)userName encryptPassword:(NSString *)encryptPassword hud:(DWDProgressHUD *)hud
{
    [DWDLoginDataHandler requestLoginWithUserName:userName password:self.pwd.text encryptPassword:encryptPassword success:^() {
        
        [hud hide:YES];
        //刷新咨询模块
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationRefreshInformation" object:nil];
        //切换老师端智能办公与家长班级模块
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChangeLoginIdentify object:nil userInfo:@{@"custIdentity" : [DWDCustInfo shared].custIdentity}];
        
        //销毁本控制器
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(presentControllerDidDismiss:)]) {
                [self.delegate presentControllerDidDismiss:self];
            }
           
        }];
        
    } failure:^(NSError *error) {
        if (error.localizedFailureReason.length > 0 ) {
            [hud showText:error.localizedFailureReason];
        }else{
            [hud showText:@"登录失败，请稍候重试"];
        }
    }];
}
@end
