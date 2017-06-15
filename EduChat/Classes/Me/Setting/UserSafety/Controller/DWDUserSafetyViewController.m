//
//  DWDUserSafetyViewController.m
//  EduChat
//
//  Created by apple on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDUserSafetyViewController.h"
#import "DWDSafetyBindingPhoneViewController.h"
#import "DWDSafetyChangePwdViewController.h"
@interface DWDUserSafetyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labMobile;
@end

@implementation DWDUserSafetyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = DWDColorBackgroud;
      self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 10)];
    
    /** 手机号 中间四位字符设置为*号 **/
    self.labMobile.text = [DWDCustInfo shared].custMobile;
    if (self.labMobile.text) {
        NSMutableString *string = [self.labMobile.text copy];
        self.labMobile.text = [string stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
  
}

#pragma mark tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDSafetyBindingPhoneViewController class]) bundle:nil];
        DWDSafetyBindingPhoneViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSafetyBindingPhoneViewController class])];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.section == 1){
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ChangePwd" bundle:nil];
        DWDSafetyChangePwdViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSafetyChangePwdViewController class])];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
@end
