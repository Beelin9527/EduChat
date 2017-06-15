//
//  DWDClassChangeClassNameViewController.m
//  EduChat
//
//  Created by Gatlin on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassChangeClassNameViewController.h"

#import "DWDClassModel.h"

#import "DWDRequestClassSetting.h"

#import "DWDClassDataBaseTool.h"

@interface DWDClassChangeClassNameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfdNickname;

@end

@implementation DWDClassChangeClassNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.tfdNickname.text = self.classModel.nickname;
    
    self.title = @"班级昵称";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(requestDataAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Notification Implementation
- (void)textFieldDidChange
{
    NSString *toBeString = self.tfdNickname.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.tfdNickname markedTextRange];
    UITextPosition *position = [self.tfdNickname positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.tfdNickname.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.tfdNickname.text = [toBeString substringWithRange:rangeRange];
            }
        }
        
    }
    if ([self.classModel.nickname isEqualToString:self.tfdNickname.text] || self.tfdNickname.text.length == 0 ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    }
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}



#pragma mark - Request
-(void)requestDataAction
{
    if ([self.tfdNickname.text isBlank]) {
        [DWDProgressHUD showText:@"昵称不能为空"];
        return;
    }
    self.tfdNickname.text = [self.tfdNickname.text trim];
    
    __weak typeof(self) weakSelf= self;
    //请求
    [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:[DWDCustInfo shared].custId classId:self.classModel.classId nickname:self.tfdNickname.text success:^(id responseObject) {
        
        __strong typeof(self) strongSelf = weakSelf;
        //1.更新本地库
        [[DWDClassDataBaseTool sharedClassDataBase] updateClassInfoWithNickname:strongSelf.tfdNickname.text ClassId:strongSelf.classModel.classId myCustId:[DWDCustInfo shared].custId];
        
        //2.设置代理实现
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(classChangeMyNicknameViewController:doneRemarkName:)]){
            [weakSelf.delegate classChangeMyNicknameViewController:weakSelf doneRemarkName:weakSelf.tfdNickname.text];
        }
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
  
   
}




@end
