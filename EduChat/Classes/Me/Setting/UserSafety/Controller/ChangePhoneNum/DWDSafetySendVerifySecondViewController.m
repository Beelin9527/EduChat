//
//  DWDSafetySendVerifySecondViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/25.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSafetySendVerifySecondViewController.h"
#import "DWDLoginViewController.h"
#import "DWDNavViewController.h"

#import "DWDSendVerifyView.h"

#import "DWDCustBaseClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDChatClient.h"

@interface DWDSafetySendVerifySecondViewController ()<DWDSendVerifyViewDelegate>

@property (strong, nonatomic) DWDSendVerifyView *sendVerifyView;
@end

@implementation DWDSafetySendVerifySecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新手机号";
    
    self.view.backgroundColor = DWDColorBackgroud;
    
    // create sendVerify view
    [self createSendVerifyView];
}

#pragma Setup SendVerify View
- (void)createSendVerifyView
{
    DWDSendVerifyView *sendVerifyView = [DWDSendVerifyView sendVerifyView];
    sendVerifyView.delegate = self;
    self.sendVerifyView = sendVerifyView;
    sendVerifyView.frame = CGRectMake(0,0, DWDScreenW, DWDScreenH);
    sendVerifyView.labIntrol.text = @"请输入新的手机号码，并发送验证码到新号码的手机上";
    sendVerifyView.tfPhone.enabled = YES;
    [self.view addSubview:sendVerifyView];
    
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
        
    }failure:^(NSError *error) {
        [[DWDCustInfo  shared] clearUserInfoData];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
}


#pragma mark Request
- (void)sendVerifyViewDidSelectNextButton:(DWDSendVerifyView *)sendVerifyView
{
    //校验是否原手机号
    if ([self.sendVerifyView.tfPhone.text isEqualToString:self.phoneNum]) {
        [DWDProgressHUD showText:@"不能与原手机号相同"];
        return;
    }
    
    [[DWDCustBaseClient sharedCustBaseClient] requestServerResetAcctPhoneNumCustId:[DWDCustInfo shared].custId newPhoneNum:self.sendVerifyView.tfPhone.text success:^(id responseObject) {
        
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
