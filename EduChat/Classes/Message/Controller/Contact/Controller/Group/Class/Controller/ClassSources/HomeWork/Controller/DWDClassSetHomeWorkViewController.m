//
//  DWDClassSetHomeWorkViewController.m
//  EduChat
//
//  Created by Superman on 15/11/27.
//  Copyright © 2015年 dwd. All rights reserved.
//

#define kMaxTitleLength 16

#import <MBProgressHUD/MBProgressHUD.h>
//#import <JFImagePickerController.h>
#import "DWDClassSetHomeWorkViewController.h"
#import "AIDatePickerController.h"
//#import "DWDMultiSelectImageView.h"
#import "DWDHomeWorkClient.h"
#import "DWDPlaceholderTextView.h"

#import "KKAlbumsListController.h"
#import "KKImagePreviewController.h"
#import "KKSelectImageView.h"
#import "DWDPhotosHelper.h"

#import <Masonry.h>

@interface DWDClassSetHomeWorkViewController () <UIScrollViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, KKSelectImageViewDelegate, KKAlbumsListControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet DWDPlaceholderTextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *deadlineBtn;
@property (weak, nonatomic) IBOutlet UIButton *subjectBtn;
@property (weak, nonatomic) KKSelectImageView *selectImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollToBottom;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property (nonatomic) BOOL isDeadlineFill;
@property (nonatomic) BOOL isSubjectFill;

@property (strong, nonatomic) NSNumber *subjectType;
@property (copy, nonatomic) NSString *deadline;

@property (strong, nonatomic) DWDHomeWorkClient *homeWorkClient;
//@property (nonatomic , strong) NSMutableArray *arrSelectImgs;
//@property (nonatomic , strong) NSMutableArray *imageNames;
@property (nonatomic, strong) NSArray *photosArray;

@property (nonatomic, assign) CGRect lastFrame;

@end

@implementation DWDClassSetHomeWorkViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.scrollView.alwaysBounceVertical = YES;
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
//    self.scrollView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    
    [self.titleTextField addTarget:self
                            action:@selector(textFieldDidChange:)
                  forControlEvents:UIControlEventEditingChanged];
    
    self.contentTextView.placeholder = @"输入作业内容";
    self.contentTextView.textColor = DWDColorBody;
    self.contentWidth.constant = DWDScreenW;
    [self addContentTextViewToolBar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"ic_release_normal"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(rightBarBtnClick)];
    self.title = @"布置作业";
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    
    
    _lastFrame = CGRectMake(0, 0, DWDScreenW, 300);
    KKSelectImageView *imgsView = [[KKSelectImageView alloc] initWithFrame:(CGRect){0, _subjectBtn.superview.frame.origin.y, DWDScreenW, 300}];
    //    imgsView.backgroundColor = [UIColor redColor];
    imgsView.eventDelegate = self;
    //    [_scrollView addSubview:imgsView]
    [self.scrollView addSubview:imgsView];
    _selectImageView = imgsView;

}

- (void)viewDidAppear:(BOOL)animated {
    CGSize size = self.scrollView.contentSize;
    if (size.height < (DWDScreenH + 10)) {
        size.height = DWDScreenH + 10;
        self.scrollView.contentSize = size;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _selectImageView.frame = (CGRect){0, _subjectBtn.superview.frame.origin.y + 120, DWDScreenW, _selectImageView.bounds.size.height};
}


- (void)addContentTextViewToolBar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(inputViewCompeleteButtonDidClick)];
    [doneButton setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],
      NSForegroundColorAttributeName,nil]
                              forState:UIControlStateNormal];
    UIBarButtonItem *flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = @[flexibleSeparator, doneButton];
    self.contentTextView.inputAccessoryView = toolbar;
    self.titleTextField.inputAccessoryView = toolbar;
}

- (void)inputViewCompeleteButtonDidClick {
    [self.contentTextView resignFirstResponder];
    [self.titleTextField resignFirstResponder];
}


- (void)showErrorMsg:(MBProgressHUD *)hud msg:(NSString *)msg {
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    [hud hide:msg afterDelay:1];
}

- (void)rightBarBtnClick{
    
    DWDMarkLog(@"rightBarBtnClick");
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    NSString *showTitle;
    if (self.titleTextField.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"请输入作业标题";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if ([self.titleTextField.text trim].length == 0) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"作业标题不能为空格";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if ([self.contentTextView.text isEqualToString:@"输入作业内容"] || self.contentTextView.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"请输入作业内容";
        [self showErrorMsg:hud msg:showTitle];
        return;
    }
    
    if ([self.contentTextView.text trim].length == 0) {
        hud.mode = MBProgressHUDModeText;
        showTitle = @"作业内容不能为空格";
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
    [hud hide:YES];
    if (!showTitle) {
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"作业发布成功后不可更改" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertV show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    // 1. 先上传图片
    if (buttonIndex == 0) {
        return;
    }
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在上传...请稍候";
    [hud show:YES];
    
//    dispatch_group_t groupGCD = dispatch_group_create();
//    DWDMarkLog(@"Upload Start Upload Pics");
//    __block BOOL allsuccess = YES;
//    
//    WEAKSELF;
//    for (int i = 0; i < self.arrSelectImgs.count; i ++) {
//        dispatch_group_enter(groupGCD);
//        DWDMarkLog(@"Upload Pic:--%d--", i);
//        UIImage *image = self.arrSelectImgs[i];
//        NSString *imageName = DWDUUID;
//        NSString *imageUrlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:imageName];
//        
//        [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:imageName progressBlock:^(CGFloat progress) {
//        } success:^{
//            DWDMarkLog(@"Upload Pic:--%d-- Success", i);
//            DWDMarkLog(@"photoKey:%@", imageUrlStr);
//            
//            [weakSelf.imageNames addObject:imageUrlStr];
//            dispatch_group_leave(groupGCD);
//            
//        } Failed:^(NSError *error) {
//            DWDMarkLog(@"Upload Pic:--%d-- Failed", i);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [hud hide:YES];
//                [hud showText:@"上传失败" afterDelay:1.5f];
//                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
//            });
//            allsuccess = NO;
//            dispatch_group_leave(groupGCD);
//        }];
//        if (allsuccess == NO) {
//            weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
//            return;
//        }
//    }
//    
//    dispatch_group_notify(groupGCD, dispatch_get_main_queue(), ^{
//        DWDMarkLog(@"Upload Pics End");
//        if (self.imageNames.count == weakSelf.arrSelectImgs.count) {
//            
//            //上传到服务器
//            DWDMarkLog(@"%@", self.imageNames);
//        }
//    });
    
    [self requestDataWithHud:hud];
}


- (void)requestDataWithHud:(MBProgressHUD *)hud
{
    
    if (!self.homeWorkClient) {
        _homeWorkClient = [[DWDHomeWorkClient alloc] init];
    }
    
    
    WEAKSELF;
    
    
    
    
    [[DWDPhotosHelper defaultHelper] uploadPhotosWithPhotosArray:_photosArray completion:^(NSArray *photoNames, BOOL success) {
        
        if (success) {
            //上传成功
            //            [[HttpClient sharedClient] postGrowUpRecordWithParams:weakSelf.dictParams success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.homeWorkClient postHomeWorkBy:[DWDCustInfo shared].custId calssId:weakSelf.classId title:[weakSelf.titleTextField.text trim] content:[weakSelf.contentTextView.text trim] subject:weakSelf.subjectType deadline:weakSelf.deadline attachmentType:@1 attachmentPaths:photoNames from:@0 success:^{
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"SendingSuccess", nil);
                [hud hide:YES afterDelay:1.0f];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:DWDNeedUpateHomeWorkList
                 object:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            } failure:^(NSError *error) {
                
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"SendingFail", nil);
                [hud hide:YES afterDelay:1.0f];
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            }];
        } else {
            //上传失败
            //reason : 上传图片失败
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"发布通知失败";
                [hud hide:YES afterDelay:1.5f];
                weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
            });
        }
    }];
   
}

#pragma mark - KKSelectImageViewDelegate
- (void)selectImageView:(KKSelectImageView *)view didClickAddImagesButtonWithMaxCount:(NSUInteger)maxCount {
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:self authorized:^{
        KKAlbumsListController *vc = [[KKAlbumsListController alloc] initWithMaxCount:(9 -_photosArray.count)];
        vc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        navi.navigationItem.backBarButtonItem.title = @"所有相册";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:navi animated:YES completion:nil];
        });
    }];
}

- (void)selectImageViewDidChangedPhotosArray:(NSArray<PHAsset *> *)photosArray {
    _photosArray = photosArray;
}

- (void)selectImageViewFrameChanged:(CGRect)frame {
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height += (frame.size.height - _lastFrame.size.height);
    _lastFrame = frame;
    self.scrollView.contentSize = contentSize;
}

#pragma mark - KKAlbumsListControllerDelegate
- (void)listControllerShouldCancel:(KKAlbumsListController *)listController {
    [listController dismissViewControllerAnimated:YES completion:nil];
}

- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array {
    [listController dismissViewControllerAnimated:YES completion:^{
        if (_selectImageView && [_selectImageView respondsToSelector:@selector(addImagesWithArray:)]) {
            [_selectImageView addImagesWithArray:array];
        }
    }];
}
#pragma mark - uitextview delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.contentTextView setNeedsDisplay];
    return YES;
}

- (IBAction)pickDeadline:(id)sender {
    [self.titleTextField resignFirstResponder];
    
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
    [self.titleTextField resignFirstResponder];
    UIAlertController *actionVC = [UIAlertController
                                   alertControllerWithTitle:@"选择科目"
                                   message:@""
                                   preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *actionOne = [UIAlertAction actionWithTitle:@"语文" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"语文" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @1;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionTow = [UIAlertAction actionWithTitle:@"数学" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"数学" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @2;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionThree = [UIAlertAction actionWithTitle:@"英语" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"英语" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @3;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionFour = [UIAlertAction actionWithTitle:@"美术" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"美术" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @4;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionFive = [UIAlertAction actionWithTitle:@"音乐" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"音乐" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @5;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionSix = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.subjectBtn setTitle:@"其他" forState:UIControlStateNormal];
        [self.subjectBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        self.subjectType = @6;
        self.isSubjectFill = YES;
    }];
    
    UIAlertAction *actionCancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [actionVC addAction:actionOne];
    [actionVC addAction:actionTow];
    [actionVC addAction:actionThree];
    [actionVC addAction:actionFour];
    [actionVC addAction:actionFive];
    [actionVC addAction:actionSix];
    [actionVC addAction:actionCancle];
    
    [self presentViewController:actionVC animated:YES completion:nil];
}

- (IBAction)addImg:(id)sender {
    
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField {
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {// 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxTitleLength) {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxTitleLength];
                if (rangeIndex.length == 1) {
                    textField.text = [toBeString substringToIndex:kMaxTitleLength];
                }
                else {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxTitleLength)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else {
        if (toBeString.length > kMaxTitleLength) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxTitleLength];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:kMaxTitleLength];
            }
            else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxTitleLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}


#pragma mark - setter / getter

@end
