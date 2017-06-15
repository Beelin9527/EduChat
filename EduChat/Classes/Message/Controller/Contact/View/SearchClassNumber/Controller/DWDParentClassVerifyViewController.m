//
//  DWDParentClassVerifyViewController.m
//  EduChat
//
//  Created by Gatlin on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDParentClassVerifyViewController.h"
#import "DWDSetupChildEduchatViewController.h"

#import "DWDMyChildClient.h"
#import "DWDMyChildListEntity.h"
#import "DWDMyChildInfoModel.h"

#import <YYModel/YYModel.h>

@interface DWDParentClassVerifyViewController ()<UITextFieldDelegate,DWDSetupChildEduchatViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *genderLab;
@property (weak, nonatomic) IBOutlet UILabel *identifyLab;
@property (weak, nonatomic) IBOutlet UITextField *childNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *childEduAcctTextField;

@property (strong, nonatomic) NSNumber *genderFalg;  //性别标识 1：男 2：女
@property (strong, nonatomic) NSNumber *identifyFaly; //身份标识    21：爸爸 22 23 ..

@property (nonatomic, strong) DWDMyChildInfoModel *childInfoModel; //孩子个人详细信息
@end

@implementation DWDParentClassVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"班级验证";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendData)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.w, 10)];
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    //初始化
    self.genderFalg = @1;
    self.identifyFaly = @0;
    
    [self.childNameTextField setValue:DWDColorSecondary forKeyPath:@"_placeholderLabel.textColor"];
    [self.childEduAcctTextField setValue:DWDColorSecondary forKeyPath:@"_placeholderLabel.textColor"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    //验证用户是否已申请孩子多维度、有则显示
    NSString *cache = [NSString stringWithFormat:@"childInfo-%@",[DWDCustInfo shared].custId];
    NSDictionary *childInfo = [[NSUserDefaults standardUserDefaults] objectForKey:cache];
    if (childInfo) {
        [self assignChildInfo:childInfo];
    }else{
        if ([DWDCustInfo shared].custMyChildName) {
            [self requestGetChildInfo];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods
/** 选择性别 */
- (void)selectIndexPathRowWithGender
{
    [self.view endEditing:YES];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.genderLab.text = @"男";
        self.genderFalg = @1;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.genderLab.text = @"女";
         self.genderFalg = @2;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action_1];
    [alert addAction:action_2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}
/** 选择身份 */
- (void)selectIndexPathRowWithIdentify
{
    [self.view endEditing:YES];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"爸爸" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.childEduAcctTextField.text.length >= 6 && self.childNameTextField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.identifyLab.text = @"爸爸";
        self.identifyLab.textColor = DWDColorBody;
        self.identifyFaly = @21;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"妈妈" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.childEduAcctTextField.text.length >= 6 && self.childNameTextField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.identifyLab.text = @"妈妈";
        self.identifyLab.textColor = DWDColorBody;
        self.identifyFaly = @22;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    UIAlertAction *action_3 = [UIAlertAction actionWithTitle:@"爷爷" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.childEduAcctTextField.text.length >= 6 && self.childNameTextField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.identifyLab.text = @"爷爷";
        self.identifyLab.textColor = DWDColorBody;
        self.identifyFaly = @23;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    UIAlertAction *action_4 = [UIAlertAction actionWithTitle:@"奶奶" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.childEduAcctTextField.text.length >= 6 && self.childNameTextField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.identifyLab.text = @"奶奶";
        self.identifyLab.textColor = DWDColorBody;
        self.identifyFaly = @24;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    UIAlertAction *action_5 = [UIAlertAction actionWithTitle:@"外公" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.childEduAcctTextField.text.length >= 6 && self.childNameTextField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.identifyLab.text = @"外公";
        self.identifyLab.textColor = DWDColorBody;
        self.identifyFaly = @25;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    UIAlertAction *action_6 = [UIAlertAction actionWithTitle:@"外婆" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.childEduAcctTextField.text.length >= 6 && self.childNameTextField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        self.identifyLab.text = @"外婆";
        self.identifyLab.textColor = DWDColorBody;
        self.identifyFaly = @26;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action_1];
    [alert addAction:action_2];
    [alert addAction:action_3];
    [alert addAction:action_4];
    [alert addAction:action_5];
    [alert addAction:action_6];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/** 赋值孩子信息 */
- (void)assignChildInfo:(NSDictionary *)dict
{
    self.childInfoModel = [DWDMyChildInfoModel yy_modelWithDictionary:dict];
    
    self.genderFalg = self.childInfoModel.gender;
    self.genderLab.text = [self.childInfoModel.gender isEqualToNumber:@1] ? @"男" : @"女";
    
    self.identifyFaly = self.childInfoModel.type;
    switch ([self.childInfoModel.type intValue]) {
        case 21:
            self.identifyLab.text = @"爸爸";
            break;
        case 22:
            self.identifyLab.text = @"妈妈";
            break;
        case 23:
            self.identifyLab.text = @"爷爷";
            break;
        case 24:
            self.identifyLab.text = @"奶奶";
            break;
        case 25:
            self.identifyLab.text = @"外公";
            break;
        case 26:
            self.identifyLab.text = @"外婆";
            break;
            
        default:
            break;
    }
   self.identifyLab.textColor = DWDColorBody;
    
    self.childNameTextField.text = self.childInfoModel.childName;
    self.childEduAcctTextField.text = self.childInfoModel.childEduAcct;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
 
}
#pragma mark - Button Action
- (IBAction)showApplyVC:(UIButton *)sender
{
    DWDSetupChildEduchatViewController *verifyVC = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDSetupChildEduchatViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSetupChildEduchatViewController class])];
    verifyVC.delegate = self;
    [self.navigationController pushViewController:verifyVC animated:YES];
}


#pragma mark - Notification
-(void)textFielDidChange
{
    /** 空字符按钮不可点击 **/
    if (self.childEduAcctTextField.text.length < 6 || self.childNameTextField.text.length == 0 || [self.identifyFaly isEqualToNumber:@0]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - DWDSetupChildEduchatViewControllerDelegate
- (void)setupChildEduchatViewController:(DWDSetupChildEduchatViewController *)SetupChildEduchatViewController childName:(NSString *)childName educhatAccount:(NSString *)educhatAccount
{
    if (![self.identifyFaly isEqualToNumber:@0]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.childNameTextField.text = childName;
    self.childEduAcctTextField.text = educhatAccount;
    NSIndexPath *indexPath_0 = [NSIndexPath indexPathForRow:0 inSection:0];
     NSIndexPath *indexPath_3 = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath_0,indexPath_3] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.childNameTextField) {
        [self.childEduAcctTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    if (textField == self.childEduAcctTextField) {
        if (textField.text.length + string.length - range.length > 16) {
            if (range.length) {
                textField.text = [textField.text substringToIndex:16];
            }
            return NO;
        }
        
    }else if(textField == self.childNameTextField){
        if (textField.text.length + string.length - range.length > 10) {
            if (range.length) {
                textField.text = [textField.text substringToIndex:10];
            }
            return NO;
        }
    }
    return  YES;
}

#pragma mark - TalbeView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [self selectIndexPathRowWithGender];
    }else if(indexPath.row == 2){
        [self selectIndexPathRowWithIdentify];
    }
}
#pragma mark - Request
- (void)sendData
{
    //校验
    if (self.childEduAcctTextField.text.length < 6 || self.childNameTextField.text.length == 0 || [self.identifyFaly isEqualToNumber:@0]) {
        [DWDProgressHUD showText:@"请完善孩子信息"];
        return;
    }
   
    self.childNameTextField.text = [self.childNameTextField.text trim];
    self.childEduAcctTextField.text = [self.childEduAcctTextField.text trim];
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    __weak typeof(self) weakSelf = self;
    
    NSDictionary *params = @{DWDCustId:[DWDCustInfo shared].custId,@"classId":self.classId,@"childName":self.childNameTextField.text,@"childEduAcct":self.childEduAcctTextField.text,@"gender":self.genderFalg,@"type":self.identifyFaly};
    [[HttpClient sharedClient]
     postApi:@"ClassVerifyRestService/parentVerify"
     params:params
     success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud showText:@"申请成功" afterDelay:DefaultTime];
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error.localizedFailureReason.length > 0) {
            [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
        }
        else
        {
            [hud showText:@"申请失败"];
        }
    }];
}


- (void)requestGetChildInfo
{
    [[DWDMyChildClient sharedMyChildClient]
     requestGetMyChildrenListWithCustId:[DWDCustInfo shared].custId
     success:^(id responseObject) {
        for (NSDictionary *dict in responseObject) {
            DWDMyChildListEntity *entity = [DWDMyChildListEntity yy_modelWithDictionary:dict];
           
            //获取孩子详细信息，别问我为何这样写，后台设计如此
            [self requestDataWithChildCustId:entity.childCustId];
            break;
        }
        
    } failure:^(NSError *error) {
      
    }];

}
- (void)requestDataWithChildCustId:(NSNumber *)childCustId
{
    
    [[DWDMyChildClient sharedMyChildClient]
     requestGetMyChildInfoWithCustId:[DWDCustInfo shared].custId
     childCustId:childCustId
     success:^(id responseObject) {
         
         //缓存
         NSString *cache = [NSString stringWithFormat:@"childInfo-%@",[DWDCustInfo shared].custId];
         [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"childInfo"] forKey:cache];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         //赋值孩子信息
         [self assignChildInfo:responseObject[@"childInfo"]];
         [self.tableView reloadData];
         
     } failure:^(NSError *error) {
         
     }];
    
}
@end
