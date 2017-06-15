//
//  DWDSafetySendVerifyViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/25.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSafetySendVerifyViewController.h"
#import "DWDSafetySendVerifySecondViewController.h"
#import "DWDSafetyChangePwdViewController.h"

#import "DWDSendVerifyView.h"

@interface DWDSafetySendVerifyViewController ()<DWDSendVerifyViewDelegate>

@end

@implementation DWDSafetySendVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"验证手机号";
    
    self.view.backgroundColor = DWDColorBackgroud;
    
    // create sendVerify view
    [self createSendVerifyView];
}

#pragma sendVerify view
- (void)createSendVerifyView
{
    DWDSendVerifyView *sendVerifyView = [DWDSendVerifyView sendVerifyView];
    sendVerifyView.delegate = self;
    sendVerifyView.frame = CGRectMake(0,0, DWDScreenW, DWDScreenH);
    
    
    NSMutableString *string = [self.phoneNum copy];
    sendVerifyView.tfPhone.text = [string stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    sendVerifyView.tfPhone.textColor = UIColorFromRGB(0x666666);
    
    sendVerifyView.labIntrol.text = @"已经往原手机号码发送验证码短信，请在60秒内使用。请及时输入，切勿泄露";
    sendVerifyView.tfPhone.enabled = NO;
    sendVerifyView.autoSend = YES;
    
    
    [self.view addSubview:sendVerifyView];
    
}

- (void)sendVerifyViewDidSelectNextButton:(DWDSendVerifyView *)sendVerifyView
{
    DWDSafetySendVerifySecondViewController *vc = [[DWDSafetySendVerifySecondViewController alloc]init];
    vc.phoneNum = self.phoneNum;
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
