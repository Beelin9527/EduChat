//
//  DWDClassSetHomeWorkViewController.m
//  EduChat
//
//  Created by Superman on 15/11/27.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <JFImagePickerController.h>
#import "DWDClassSetHomeWorkViewController.h"
#import "AIDatePickerController.h"
#import "DWDMultiSelectImageView.h"
#import "DWDHomeWorkClient.h"

@interface DWDClassSetHomeWorkViewController () <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, DWDMultiSelectImageViewDelegate, JFImagePickerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *deadlineBtn;
@property (weak, nonatomic) IBOutlet UIButton *subjectBtn;
@property (weak, nonatomic) IBOutlet DWDMultiSelectImageView *multiSelectImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollToBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *multiSelectImageHeight;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property (nonatomic) BOOL isDeadlineFill;
@property (nonatomic) BOOL isSubjectFill;

@property (strong, nonatomic) NSNumber *subjectType;
@property (copy, nonatomic) NSString *deadline;

@property (strong, nonatomic) DWDHomeWorkClient *homeWorkClient;

@end

@implementation DWDClassSetHomeWorkViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.contentWidth.constant = DWDScreenW;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"ic_release_normal"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(rightBarBtnClick)];
    self.title = @"布置作业";
}

- (void)showErrorMsg:(MBProgressHUD *)hud msg:(NSString *)msg {
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    [hud hide:msg afterDelay:1];
}

- (void)rightBarBtnClick{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSString *showTitle;
    if (self.titleTextField.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"请输入作业标题";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if ([self.contentTextView.text isEqualToString:@"输入作业内容"] || self.contentTextView.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"请输入作业内容";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if (!self.isDeadlineFill) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"请选择上交日期";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if (!self.isSubjectFill) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"请选择科目";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if (!showTitle) {
        
        showTitle = NSLocalizedString(@"Sending", nil);
        hud.labelText = showTitle;
        
        if (!self.homeWorkClient) {
            _homeWorkClient = [[DWDHomeWorkClient alloc] init];
            
            [self.homeWorkClient postHomeWorkBy:[DWDCustInfo shared].custId
                                        calssId:self.classId
                                          title:self.titleTextField.text
                                        content:self.contentTextView.text
                                        subject:self.subjectType
                                       deadline:self.deadline
                                 attachmentType:@1
                                attachmentPaths:@""
                                           from:@0
                                        success:^{
                                            
                                            hud.mode = MBProgressHUDModeText;
                                            hud.labelText = NSLocalizedString(@"SendingSuccess", nil);
                                            [hud hide:YES afterDelay:1];
                                            
                                            [[NSNotificationCenter defaultCenter]
                                             postNotificationName:DWDNeedUpateHomeWorkList
                                             object:nil];
                                            
                                        } failure:^(NSError *error) {
                                            
                                            hud.mode = MBProgressHUDModeText;
                                            hud.labelText = NSLocalizedString(@"SendingFail", nil);
                                            [hud hide:YES afterDelay:1];
                                        }];
        }
        
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.titleTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}

- (void)multiSelectImageViewDidSelectAddButton:(DWDMultiSelectImageView *)multiSelectImageView {
    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:self];
    picker.pickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];

}

- (void)imagePickerDidFinished:(JFImagePickerController *)picker {
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:9];
    
    for ( ALAsset *asset in picker.assets) {
        [[JFImageManager sharedManager] thumbWithAsset:asset resultHandler:^(UIImage *result) {
            [temp addObject:result];
        }];
    }
    
    self.multiSelectImageView.arrImages = temp;
    self.multiSelectImageHeight.constant = self.multiSelectImageView.frame.size.height;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - uitextview delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = nil;
    textView.textColor = DWDColorBody;
}

- (IBAction)pickDeadline:(id)sender {
    
    __weak DWDClassSetHomeWorkViewController *weakSelf = self;
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:[NSDate date] selectedBlock:^(NSDate *selectedDate) {
        
        __strong DWDClassSetHomeWorkViewController *strongSelf = weakSelf;
        
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            
            NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            fmt.dateFormat = @"MM/dd HH:mm";
            [strongSelf.deadlineBtn setTitle:[fmt stringFromDate:selectedDate] forState:UIControlStateNormal];
            [strongSelf.deadlineBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
            
            fmt.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            _deadline = [fmt stringFromDate:selectedDate];
            
            self.isDeadlineFill = YES;
        }];
        
    } cancelBlock:^{
        
        __strong DWDClassSetHomeWorkViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

- (IBAction)pickSubject:(id)sender {
    UIAlertController *actionVC = [UIAlertController
                                   alertControllerWithTitle:@"选择科目"
                                   message:@""
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionOne = [UIAlertAction actionWithTitle:@"语文" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"语文" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @0;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionTow = [UIAlertAction actionWithTitle:@"数学" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"数学" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @1;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionThree = [UIAlertAction actionWithTitle:@"英语" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"英语" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @2;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionCancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [actionVC addAction:actionOne];
    [actionVC addAction:actionTow];
    [actionVC addAction:actionThree];
    [actionVC addAction:actionCancle];
    
    [self presentViewController:actionVC animated:YES completion:nil];
}

- (IBAction)addImg:(id)sender {
   
    
}

@end
