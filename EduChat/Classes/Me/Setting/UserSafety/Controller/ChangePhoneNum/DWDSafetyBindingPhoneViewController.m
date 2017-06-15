//
//  DWDSafetyBindingPhoneViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/25.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSafetyBindingPhoneViewController.h"
#import "DWDSafetySendVerifyViewController.h"

@interface DWDSafetyBindingPhoneViewController ()

@property (weak, nonatomic) IBOutlet UIButton *btnChangePhoneNum;
@property (weak, nonatomic) IBOutlet UILabel *labPhoneNum;
@end

@implementation DWDSafetyBindingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"绑定手机号";
    
    _btnChangePhoneNum.layer.masksToBounds = YES;
    _btnChangePhoneNum.layer.cornerRadius = self.btnChangePhoneNum.frame.size.height/2;
    
    /** 手机号 中间四位字符设置为*号 **/
    self.labPhoneNum.text = [DWDCustInfo shared].custMobile;
    if (self.labPhoneNum.text) {
        NSMutableString *string = [self.labPhoneNum.text copy];
        self.labPhoneNum.text = [string stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
}

- (IBAction)pushSendVerifyVCAction:(UIButton *)sender {
    
    DWDSafetySendVerifyViewController *vc = [[DWDSafetySendVerifyViewController alloc]init];
    vc.phoneNum = [DWDCustInfo shared].custMobile;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
