//
//  DWDAddNoteViewController.m
//  EduChat
//
//  Created by Gatlin on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDAddNoteViewController.h"
#import "AIDatePickerController.h"

#import "DWDRequestServerLeavePaper.h"

#import "DWDMyChildListEntity.h"
#import "DWDMyChildClient.h"
#import "DWDRequestServerLeavePaper.h"
#import "UIImage+Utils.h"
#import <YYModel/YYModel.h>
@interface DWDAddNoteViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *applyNameBtn;
@property (weak, nonatomic) IBOutlet UIButton *startTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *endTimeBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectNoteTypeBtn;
@property (weak, nonatomic) IBOutlet UITextView *reasonTextView;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (copy, nonatomic) NSString *startTime;  //传给服务器开始时间
@property (copy, nonatomic) NSString *endTime;  //传给服务器结束时间
@property (strong, nonatomic) NSNumber *typeFalg;   //请假类型标识
@property (strong, nonatomic) NSNumber *childCustId;  //孩子ID

@property (strong, nonatomic) NSMutableArray *dataSource; //数据源
@end

@implementation DWDAddNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"假条";
    
    //setup
    _doneBtn.layer.masksToBounds = YES;
    _doneBtn.layer.cornerRadius = self.doneBtn.h/2;
    
    [_doneBtn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [_doneBtn setBackgroundImage:[UIImage imageWithColor:DWDColorSeparator] forState:UIControlStateDisabled];
    _doneBtn.enabled = NO;
    
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    //request load child name
    [self requeustLoadChildName];
}


#pragma mark - Getter
- (NSMutableArray *)datasource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSource;
}

#pragma mark - Button Action
/** select start time action */
- (IBAction)selectStartTimeAction:(UIButton *)sender
{
    __weak DWDAddNoteViewController *weakSelf = self;
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:[NSDate date] selectedBlock:^(NSDate *selectedDate) {
        
        __strong DWDAddNoteViewController *strongSelf = weakSelf;
        
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            
            NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            fmt.dateFormat = @"YYYY/MM/dd HH:mm";
            [strongSelf.startTimeBtn setTitle:[fmt stringFromDate:selectedDate] forState:UIControlStateNormal];
            [strongSelf.startTimeBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
            
            fmt.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            _startTime = [fmt stringFromDate:selectedDate];
            
        }];
        
    } cancelBlock:^{
        
        __strong DWDAddNoteViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

/** select end time action */
- (IBAction)selectEndTimeAction:(UIButton *)sender
{
     __weak DWDAddNoteViewController *weakSelf = self;
    AIDatePickerController *datePickerViewController = [AIDatePickerController pickerWithDate:[NSDate date] selectedBlock:^(NSDate *selectedDate) {
        
        __strong DWDAddNoteViewController *strongSelf = weakSelf;
        
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            
            NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
            fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
            fmt.dateFormat = @"YYYY/MM/dd HH:mm";
            [strongSelf.endTimeBtn setTitle:[fmt stringFromDate:selectedDate] forState:UIControlStateNormal];
            [strongSelf.endTimeBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
            
            fmt.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            _endTime = [fmt stringFromDate:selectedDate];
            
        }];
        
    } cancelBlock:^{
        
        __strong DWDAddNoteViewController *strongSelf = weakSelf;
        [strongSelf dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [self presentViewController:datePickerViewController animated:YES completion:nil];
}

/** select note type */
- (IBAction)selectNoteTypeAction:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *thingAction = [UIAlertAction actionWithTitle:@"事假" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.selectNoteTypeBtn setTitle:@"事假" forState:UIControlStateNormal];
        [self.selectNoteTypeBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        _typeFalg = @1;
    }];
    UIAlertAction *illAction = [UIAlertAction actionWithTitle:@"病假" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.selectNoteTypeBtn setTitle:@"病假" forState:UIControlStateNormal];
        [self.selectNoteTypeBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        _typeFalg = @2;
    }];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.selectNoteTypeBtn setTitle:@"其他" forState:UIControlStateNormal];
        [self.selectNoteTypeBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
        _typeFalg = @3;
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:thingAction];
    [alert addAction:illAction];
    [alert addAction:otherAction];
    [alert addAction:cancleAction];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)selectOtherApplyChildAction:(UIButton *)sender
{
    //如果就只有一个孩子在这个班级、该按钮不可点击，否则弹多多个孩子名字让其选择
    if (self.dataSource.count == 1) {
        sender.enabled = NO;
    }else if (self.dataSource.count > 1){
        sender.enabled = YES;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (int i = 0; i < self.dataSource.count; i ++) {
            DWDMyChildListEntity *entity = self.dataSource[i];
            UIAlertAction *action = [UIAlertAction actionWithTitle:entity.childName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.applyNameBtn setTitle:entity.childName forState:UIControlStateNormal];
                self.childCustId = entity.childCustId;
            }];
            [alert addAction:action];
        }
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancleAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/** done action */
- (IBAction)doneAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    //校验
    if ((self.startTime == nil) || (self.endTime == nil) || (self.reasonTextView.text == nil) || [self.typeFalg isEqualToNumber:@0]) {
        [DWDProgressHUD showText:@"请完善假条"];
        return;
    }
    
    //校验后时间是否大于或等于前时间
    if (NSOrderedAscending != [self.startTime compare:self.endTime]) {
        [DWDProgressHUD showText:@"您选择时间不符合"];
        return;
    }
   
    //request [DWDCustInfo shared].custId
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    [params setObject:[DWDCustInfo shared].custId forKey:@"custId"];
    [params setObject:self.classId forKey:@"classId"];
    [params setObject:self.typeFalg forKey:@"type"];
    [params setObject:self.applyNameBtn.titleLabel.text forKey:@"applicantName"];
    [params setObject:self.childCustId forKey:@"applicantId"];
    [params setObject:self.startTime forKey:@"startTime"];
    [params setObject:self.endTime forKey:@"endTime"];
    [params setObject:self.reasonTextView.text forKey:@"excuse"];
    [self commitDataWithParams:params];
}


#pragma mark - TextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"请填写理由"]) textView.text = nil;
    textView.textColor = DWDColorBody;

}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ((textView.text.length + text.length - range.length) > 100) {
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        self.doneBtn.enabled = NO;
    }else{
        self.doneBtn.enabled = YES;
    }
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.reasonTextView resignFirstResponder];
}


#pragma mark - Request
- (void)requeustLoadChildName
{
     DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    
    __weak typeof(self) weakSelf = self;
    [[DWDMyChildClient sharedMyChildClient] requestGetMyChildrenNameListWithCustId:[DWDCustInfo shared].custId
                                                                           classId:self.classId
                                                                           success:^(id responseObject) {
                                                                               
                                                                               [hud hideHud];
                                                                               __strong typeof(self) strongSelf = weakSelf;
                                                                               
                                                                               for (NSDictionary *dict in responseObject) {
                                                                                   
                                                                                   DWDMyChildListEntity *entity = [DWDMyChildListEntity yy_modelWithDictionary:dict];
                                                                                   [strongSelf.datasource addObject:entity];
                                                                               }
                                                                               
                                                                               DWDMyChildListEntity *entity = strongSelf.dataSource[0];
                                                                               strongSelf.childCustId = entity.childCustId;
                                                                               [strongSelf.applyNameBtn setTitle:entity.childName forState:UIControlStateNormal];
                                                                               
                                                                           }
                                                                           failure:^(NSError *error) {
                                                                                 [hud showText:@"加载失败" afterDelay:DefaultTime];
                                                                           }];
    
   
}
- (void)commitDataWithParams:(NSDictionary *)params
{
    __weak typeof(self) weakSelf = self;
    [[DWDRequestServerLeavePaper sharedDWDRequestServerLeavePaper]
     requestAddEntityWithParams:params
     success:^(id responseObject) {
         __strong typeof(self) strongSelf = weakSelf;
         [strongSelf.navigationController popViewControllerAnimated:YES];
         
    } failure:^(NSError *error) {
        
    }];
}
@end


