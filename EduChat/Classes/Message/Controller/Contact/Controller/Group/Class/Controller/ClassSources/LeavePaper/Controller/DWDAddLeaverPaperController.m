//
//  DWDAddLeaverPaperController.m
//  EduChat
//
//  Created by KKK on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDAddLeaverPaperController.h"
#import "DWDLeavePaperDateTimeLabel.h"
#import "NSString+extend.h"

#import <UIImageView+WebCache.h>
#import <YYModel.h>

@interface DWDAddLeaverPaperController () <UITextViewDelegate, DWDLeavePaperDateTimeLabelDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *headName;
@property (weak, nonatomic) IBOutlet UILabel *parentNameLabel;
//@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet DWDLeavePaperDateTimeLabel *startTimeLabel;

//@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (weak, nonatomic) IBOutlet DWDLeavePaperDateTimeLabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeTypeLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;

//support
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, assign) NSInteger timeType;
@property (nonatomic, assign) NSInteger leaveType;

@property (nonatomic, copy) NSString *childName;
@property (nonatomic, strong) NSNumber *childId;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@end

@implementation DWDAddLeaverPaperController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"假条";
    _textView.delegate = self;
//    _startTimeTextField.delegate = self;
//    _endTimeTextField.delegate = self;
    _startTimeLabel.delegate = self;
    _endTimeLabel.delegate = self;
    [self requestChildInfo];
    [self setupRightBarButtonItem];
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            //开始时间
            [self presentDatePickerWithType:1];
        } else if (indexPath.row == 2) {
            //结束时间
            [self presentDatePickerWithType:2];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            //请假类型
            [self presentAlertController];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate
//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
//    NSInteger row = [self.tableView indexPathForCell:cell].row;
//    if (row == 1) {
//        _datePicker.minimumDate = nil;
//    }
//    _timeType = row;
//}
#pragma mark - DWDLeavePaperDateTimeLabelDelegate
- (void)label:(DWDLeavePaperDateTimeLabel *)label didClickToolbarDoneButton:(NSDate *)date {
    if ([_startTimeLabel isFirstResponder] && ![_endTimeLabel isFirstResponder]) {
        //给startdate赋值
        _startDate = date;
    } else if ([_endTimeLabel isFirstResponder]) {
        //给enddate赋值
        _endDate = date;
    }
    [label resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请填写不同意理由"]) {
        textView.textColor = DWDColorBody;
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""] || textView.text.length == 0) {
        textView.textColor = DWDRGBColor(153, 153, 153);
        textView.text = @"请填写不同意理由";
    }
}

#pragma mark - Event Response
//- (void)datePickerDidClickDoneButton {
//    _formatter.dateFormat = @"YYYY/MM/dd HH:mm";
//    if (_timeType == 1) {
//        //开始时
//        NSDate *date = _datePicker.date;
//        _startDate = date;
//        _datePicker.minimumDate = date;
//        NSString *dateStr = [_formatter stringFromDate:date];
//        _startTimeTextField.text = dateStr;
//        _startTimeTextField.textColor = DWDRGBColor(51, 51, 51);
//        [_startTimeTextField resignFirstResponder];
//    } else if (_timeType == 2) {
//        //结束时间
//        NSDate *date = _datePicker.date;
//        _endDate = date;
//        NSString *dateStr = [_formatter stringFromDate:date];
//        _endTimeTextField.text = dateStr;
//        _endTimeTextField.textColor = DWDRGBColor(51, 51, 51);
//        [_endTimeTextField resignFirstResponder];
//    }
//    self.navigationItem.rightBarButtonItem.enabled = YES;
//}

- (void)commitButtonDidClick {
    //校验
    NSString *contentStr = [_textView.text trim];
//    if ([self.startTimeTextField.text isEqualToString:@"选择开始的时间"] || [self.endTimeTextField.text isEqualToString:@"选择结束的时间"] || (_textView.text == nil || _textView.text.length == 0) || !(_leaveType == 1 || _leaveType == 2 || _leaveType == 3)) {
    if ([self.startTimeLabel.text isEqualToString:@"选择开始的时间"] || [self.endTimeLabel.text isEqualToString:@"选择结束的时间"] || (contentStr == nil || contentStr.length == 0 || [contentStr isEqualToString:@""]) || !(_leaveType == 1 || _leaveType == 2 || _leaveType == 3)) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请完善假条";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    
    if (NSOrderedAscending != [_startDate compare:_endDate] || _startDate == nil || _endDate == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"您选择时间不符合";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5f];
        return;
    }
    
//    custId	√	long	(0,)	用户id
//    classId	√	long	(0,)	班级id
//    type		int	1:事假|2:病假|3:其他	请假类型
//    applicantName	√	String		请假人名字
//    applicantId		long	(0,)	请假人
//    如果为空，且custId为学生身份，则custId为请假人
//    内部需校验applicant和custId是否家长学生关系
//    startTime	√	String		请假时间
//    endTime		String		结束时间
//    如果不填写，则表示请一天假
//    excuse		String		请假事由
//    病假可以不填写，其他类型必须填写
    
    NSDictionary *dict = @{
                           @"custId" : [DWDCustInfo shared].custId,
                           @"classId" : _classId,
                           @"type" : [NSNumber numberWithInteger:_leaveType],
                           @"applicantName" : _childName,
                           @"applicantId" : _childId,
                           @"startTime" : [self.formatter stringFromDate:_startDate],
                           @"endTime" : [self.formatter stringFromDate:_endDate],
                           @"excuse" : contentStr,
                           };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"请稍候";
    [hud show:YES];
    WEAKSELF;
    [[HttpClient sharedClient] postAddClassLeavePaperWithParams:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hide:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"上传失败";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5f];
    }];
}

#pragma mark - Private Method

- (void)requestChildInfo {
    NSDictionary *dict = @{
                           @"custId" : [DWDCustInfo shared].custId,
                           @"classId" : self.classId,
                           };
    WEAKSELF;
    /**
     获取孩子
     
     有一个家长一个班级多个孩子情况,需要做选择器
     */
#warning several child at one class
    [[HttpClient sharedClient] getChildListWithParams:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDPhotoMetaModel *photo = [DWDPhotoMetaModel yy_modelWithJSON:responseObject[@"data"][0][@"childPhotohead"]];
        weakSelf.childId = responseObject[@"data"][0][@"childCustId"];
        weakSelf.childName = responseObject[@"data"][0][@"childName"];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.tableView.userInteractionEnabled = YES;
            [weakSelf.headImgView sd_setImageWithURL:[NSURL URLWithString:[photo thumbPhotoKey]] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
            if ([responseObject[@"data"] count] == 0) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            weakSelf.headName.text = responseObject[@"data"][0][@"childName"];
            weakSelf.parentNameLabel.text = [weakSelf.headName.text stringByAppendingString: [NSString parentRelationStringWithRelation:(NSNumber *)responseObject[@"data"][0][@"relationType"]]];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.tableView.userInteractionEnabled = NO;
    }];
}



- (void)setupRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_release_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(commitButtonDidClick)];
}

/**
 0 - start
 1 - end
 */
- (void)presentDatePickerWithType:(NSInteger)type {
//    self.navigationItem.rightBarButtonItem.enabled = NO;
    _timeType = type;
    if (type == 1) {
        [_startTimeLabel becomeFirstResponder];
    } else if (type == 2) {
        [_endTimeLabel becomeFirstResponder];
    }
}

//show datePicker

- (void)presentAlertController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *thingAction = [UIAlertAction actionWithTitle:@"事假" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _timeTypeLabel.text = @"事假";
        _timeTypeLabel.textColor = DWDRGBColor(51, 51, 51);
        _leaveType = 1;
    }];
    UIAlertAction *illAction = [UIAlertAction actionWithTitle:@"病假" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _timeTypeLabel.text = @"病假";
        _timeTypeLabel.textColor = DWDRGBColor(51, 51, 51);
        _leaveType = 2;
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _timeTypeLabel.text = @"其他";
        _timeTypeLabel.textColor = DWDRGBColor(51, 51, 51);
        _leaveType = 3;
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:thingAction];
    [alert addAction:illAction];
    [alert addAction:otherAction];
    [alert addAction:cancleAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Setter / Getter

- (NSDateFormatter *)formatter {
    if (!_formatter) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
        _formatter = formatter;
    }
    return _formatter;
}

@end
