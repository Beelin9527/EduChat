//
//  DWDGroupMyNicknameViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGroupMyNicknameViewController.h"

#import "DWDGroupEntity.h"
#import "DWDGroupClient.h"

#import "DWDGroupDataBaseTool.h"

@interface DWDGroupMyNicknameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfSetupName;
@end

@implementation DWDGroupMyNicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群昵称";
    
    self.tfSetupName.text = self.groupModel.nickname;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(requestDataAction)];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification Implementation
- (void)textFielDidChange
{
    NSString *toBeString = self.tfSetupName.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.tfSetupName markedTextRange];
    UITextPosition *position = [self.tfSetupName positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.tfSetupName.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.tfSetupName.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
//     || self.tfSetupName.text.length <= 0
//    if ([self.groupModel.nickname isEqualToString:self.tfSetupName.text]) {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }else{
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }
}
#pragma mark - TextFiel Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.groupModel.nickname isEqualToString:textField.text] || textField.text.length != 0) {
        [self requestDataAction];
    }
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Request
-(void)requestDataAction
{
    if ([self.groupModel.nickname isEqualToString:self.tfSetupName.text]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if ([self.tfSetupName.text isBlank]) {
        [DWDProgressHUD showText:@"昵称不能为空"];
        return;
    }
    
    self.tfSetupName.text = [self.tfSetupName.text trim];
    
    //请求
    [[DWDGroupClient sharedRequestGroup]
     getGroupRestUpdateGroupWithGroupId:self.groupModel.groupId
     groupName:nil
     groupNickName:self.tfSetupName.text
     success:^(id responseObject) {
        
         self.groupModel.nickname = self.tfSetupName.text;
         
         //更改本地库我在该群组的昵称
         [[DWDGroupDataBaseTool sharedGroupDataBase]
          updateGroupInfoWithMyCustId:[DWDCustInfo shared].custId
          groupId:self.groupModel.groupId
          nickname:self.tfSetupName.text];
       
         if (self.delegate && [self.delegate respondsToSelector:@selector(groupMyNicknameViewController:myGroupNickname:)]) {
             [self.delegate groupMyNicknameViewController:self myGroupNickname:self.tfSetupName.text];
         }
     
        [self.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
    
    }];
}

@end
