//
//  DWDMyChildFixChildNameViewController.m
//  EduChat
//
//  Created by Gatlin on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyChildFixChildNameViewController.h"

#import "DWDMyChildClient.h"

#import "DWDMyChildInfoModel.h"
#import "DWDMyChildListEntity.h"
@interface DWDMyChildFixChildNameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *childNameTextField;

@end

@implementation DWDMyChildFixChildNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"姓名";
    
    _childNameTextField.text = self.myChildInfoModel.childName;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Action
- (void)doneAction
{
    [self requestFixChildName:self.childNameTextField.text];
}

#pragma mark - Notification
- (void)textFielDidChange
{
    if ([self.myChildInfoModel.childName isEqualToString:self.childNameTextField.text] || self.childNameTextField.text.length <= 0 ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}


#pragma mark - TextFiel Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.myChildInfoModel.childName isEqualToString:textField.text] && textField.text.length != 0) {
         [self requestFixChildName:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField.text.length + string.length - range.length) > 16) {
        if (range.length) {
            textField.text = [textField.text substringToIndex:16];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Request
- (void)requestFixChildName:(NSString *)newChildName
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    __weak typeof(self) weakSelf = self;
    [[DWDMyChildClient sharedMyChildClient]
     requestUpdateMyChildInfoWithCustId:[DWDCustInfo shared].custId
     childCustId:self.myChildInfoModel.childCustId
     childName:newChildName
     childGender:nil
     childPhotoKey:nil
     success:^(id responseObject) {
         
         [hud showText:@"修改成功"];
         __strong typeof(self) strongSelf = weakSelf;
         
         //直接更改内存孩子姓名。 控制器记得刷新
        strongSelf.myChildInfoModel.childName = newChildName;
         strongSelf.myChildListEntity.childName = newChildName;
         [DWDCustInfo shared].custMyChildName = newChildName;
         
        [strongSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        [hud showText:@"修改失败"];
    }];
}



@end
