//
//  DWDClassIntroduceViewController.m
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassIntroduceViewController.h"

#import "DWDRequestClassSetting.h"

#import "DWDClassModel.h"

#import "DWDClassDataBaseTool.h"
@interface DWDClassIntroduceViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textLenghtLabel;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;
@end

@implementation DWDClassIntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"班级介绍";
    
    if ([DWDCustInfo shared].isTeacher)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(doneAction)];
        _textLenghtLabel.text = [NSString stringWithFormat:@"%ld/300",(unsigned long)self.introTextView.text.length];
    }else
    {
        _introTextView.userInteractionEnabled = NO;
        _textLenghtLabel.text = @"";
    }
    _introTextView.text = self.classModel.introduce;
    
}

#pragma mark - Button Action
- (void)doneAction
{
    if ([self.classModel.introduce isEqualToString:self.introTextView.text]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        //request
        [self requestSettingClassIntroduce];
    }
}


#pragma mark - Notification Implementation
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *toBeString = self.introTextView.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.introTextView markedTextRange];
    UITextPosition *position = [self.introTextView positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 300)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:300];
            if (rangeIndex.length == 1)
            {
                self.introTextView.text = [toBeString substringToIndex:300];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 300)];
                self.introTextView.text = [toBeString substringWithRange:rangeRange];
            }
        }
         self.textLenghtLabel.text = [NSString stringWithFormat:@"%lu/300",(unsigned long)self.introTextView.text.length];
    }
}


#pragma mark - Request
- (void)requestSettingClassIntroduce
{
    
    self.introTextView.text = [self.introTextView.text trim];
    
    __weak typeof(self) weakSelf = self;
    [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:[DWDCustInfo shared].custId classId:self.classModel.classId introduce:self.introTextView.text success:^(id responseObject) {
         __strong typeof(self) strongSelf = weakSelf;
        
        //1.更新本地库 班级介绍
        [[DWDClassDataBaseTool sharedClassDataBase] updateClassInfoWithIntroduce:strongSelf.introTextView.text ClassId:strongSelf.classModel.classId myCustId:[DWDCustInfo shared].custId];
       
        //2.设置代理实现
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(classIntroduceViewController:introduce:)]) {
            [strongSelf.delegate classIntroduceViewController:strongSelf introduce:strongSelf.introTextView.text];
        }
        
        [strongSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
}

@end
