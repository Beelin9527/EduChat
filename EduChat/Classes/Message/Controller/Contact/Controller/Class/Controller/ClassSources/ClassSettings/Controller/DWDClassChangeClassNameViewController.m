//
//  DWDClassChangeClassNameViewController.m
//  EduChat
//
//  Created by Bharal on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassChangeClassNameViewController.h"

#import "DWDRequestClassSetting.h"

@interface DWDClassChangeClassNameViewController ()<UITextFieldDelegate>


@end

@implementation DWDClassChangeClassNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tfClassName.text = self.className;
    
    self.title = @"班级名";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(requestDataAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.className isEqualToString:textField.text]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;

    }
    
    return YES;

}
-(void)requestDataAction
{
    __weak typeof(self) weakSelf= self;
    //请求
    [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:@4010000005410 classId:@8010000001047 className:self.tfClassName.text success:^(id responseObject) {
        
        weakSelf.className = weakSelf.tfClassName.text;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
  
   
}




@end
