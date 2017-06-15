//
//  DWDEduchatAccountSetupViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDEduchatAccountSetupViewController.h"

#import "DWDCustInfoClient.h"
#import "DWDAccountClient.h"
@interface DWDEduchatAccountSetupViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfEduchatName;
@end

@implementation DWDEduchatAccountSetupViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"多维度号";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    
    [self.tfEduchatName becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.tfEduchatName resignFirstResponder];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Implememtation
- (void)textFieldDidChange
{
    NSString *toBeString = self.tfEduchatName.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.tfEduchatName markedTextRange];
    UITextPosition *position = [self.tfEduchatName positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.tfEduchatName.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.tfEduchatName.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
}


#pragma Textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



#pragma mark - Event Delegate
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}


#pragma Request
-(void)commitAction
{
    [self checkoutIsHaveAccount:self.tfEduchatName.text];
    
  
    
   }

- (void)checkoutIsHaveAccount:(NSString *)account
{
    if(account.length < 6){
        [DWDProgressHUD showText:@"请设置6-16位数字与字母组合"];
        return;
    }
    
    if ([NSString isValidateNumber:account])
    {
        [DWDProgressHUD showText:@"请设置6-16位数字与字母组合"];
        return;
    }
    if (![NSString isValidateSixToSixteen:account]) {
      
        [DWDProgressHUD showText:@"请设置6-16位数字与字母组合"];
        return;
    }
    
    [[DWDAccountClient sharedAccountClient] requestGetEduChatAccount:account success:^(NSDictionary *info) {
        
        [self.tfEduchatName resignFirstResponder];
        
        self.tfEduchatName.text = [self.tfEduchatName.text trim];
        
        //request commit server
        [[DWDCustInfoClient sharedCustInfoClient]
         requestUpdateWithEduchatAccount:self.tfEduchatName.text
         success:^(id responseObject)
         {
             [self.navigationController popViewControllerAnimated:YES];
         }];
 
        
    } failure:^(NSError *error) {
        
        [DWDProgressHUD showText:@"您设置的多维度号已存在"];
       
    }];
    
}
@end
