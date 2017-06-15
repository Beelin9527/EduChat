//
//  DWDFixIntroViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDFixSignatureViewController.h"

#import "DWDCustInfoClient.h"

@interface DWDFixSignatureViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *signature;
@property (weak, nonatomic) IBOutlet UILabel *labFalg;
@end

@implementation DWDFixSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个性签名";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    
    _signature.text = [self.StrSignature isEqualToString: @"未填写"] ? nil : self.StrSignature;
    _signature.delegate = self;
    
    _labFalg.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)self.signature.text.length];
    
    
    if ([self.signature.text isEqualToString:[DWDCustInfo shared].custSignature]) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)commitAction
{
    if ([self.signature.text isEqualToString:[DWDCustInfo shared].custEduchatAccount]) {
        return;
    }
   
    self.signature.text = [self.signature.text trim];
    
    //request commit server
    [[DWDCustInfoClient sharedCustInfoClient]
     requestUpdateWithSignature:self.signature.text
     success:^(id responseObject)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark textView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        [self commitAction];
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *toBeString = textView.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 30)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:30];
            if (rangeIndex.length == 1)
            {
                textView.text = [toBeString substringToIndex:30];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 30)];
                textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
        
        _labFalg.text = [NSString stringWithFormat:@"%lu/30",(unsigned long)textView.text.length];
    }

    if ([textView.text isEqualToString:[DWDCustInfo shared].custSignature]) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    }else{
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Event Delegate
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.signature resignFirstResponder];
    
}
@end
