//
//  DWDSendVerifyInfoViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSendVerifyInfoViewController.h"
#import "DWDFriendVerifyClient.h"
@interface DWDSendVerifyInfoViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *verifyMsgTfd;

@end

@implementation DWDSendVerifyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"朋友验证";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(requestAddEntityVerifyMsg)];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}


#pragma mark - Notification
-(void)textFielDidChange
{
    if (self.verifyMsgTfd.text.length > 30) {
        self.verifyMsgTfd.text = [self.verifyMsgTfd.text substringToIndex:30];
        
    }
}


#pragma mark - TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.text.length + string.length - range.length ) > 30) {
        if (range.length) {
            textField.text = [textField.text substringToIndex:30];
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Request
/** 加为好友 **/
- (void)requestAddEntityVerifyMsg
{
    
    [self.view endEditing:YES];
   
    [[DWDFriendVerifyClient sharedFriendVerifyClient]
     sendFriendVerify:[DWDCustInfo shared].custId
     friendId:self.friendCustId
     verifyInfo:self.verifyMsgTfd.text
     source:self.source
     success:^(NSArray *invites) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.navigationController popToRootViewControllerAnimated:YES];
         });
         
     } failure:^(NSError *error) {
         
     }];
    
}
@end
