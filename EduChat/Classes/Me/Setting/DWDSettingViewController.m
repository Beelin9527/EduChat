//
//  DWDSettingViewController.m
//  EduChat
//
//  Created by apple on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSettingViewController.h"
#import "DWDNewMessageAlertViewController.h"
#import "DWDNoDisturbingViewController.h"
#import "DWDPrivacyViewController.h"
#import "DWDCommonlyUsedViewController.h"
#import "DWDUserSafetyViewController.h"
#import "DWDAboutUsViewController.h"
#import "DWDTabbarViewController.h"
#import "DWDMessageViewController.h"
#import "DWDInfoViewController.h"

#import "DWDCustBaseClient.h"
#import "DWDChatClient.h"
#import "DWDChatMsgDataClient.h"

#import "DWDRecentChatDatabaseTool.h"

#import "DWDChatClient.h"

#import "DWDKeyChainTool.h"
typedef enum{
   UserSafety=0,AboutUs,NewMeageeAlert,NoDisturbing,Privacy,CommonlyUsed,
}sectionContent;

@interface DWDSettingViewController ()


@end

@implementation DWDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
   
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.w, 10)];
    self.tableView.backgroundColor = DWDColorBackgroud;

}


#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //获取点击cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case NewMeageeAlert:
                //push 新消息提醒
                [self pushToVcWithClassName:NSStringFromClass([DWDNewMessageAlertViewController class]) title:cell.textLabel.text];
                break;
            case NoDisturbing:
                //push 勿扰模式
                [self pushToVcWithClassName:NSStringFromClass([DWDNoDisturbingViewController class]) title:cell.textLabel.text];
                break;
            case Privacy:
                //push 隐私
                [self pushToVcWithClassName:NSStringFromClass([DWDPrivacyViewController class]) title:cell.textLabel.text];
                break;
            case CommonlyUsed:
                //push 通用
                [self pushToVcWithClassName:NSStringFromClass([DWDCommonlyUsedViewController class]) title:cell.textLabel.text];
                break;
            case UserSafety:
                //push 帐号安全
                [self pushToVcWithClassName:NSStringFromClass([DWDUserSafetyViewController class]) title:cell.textLabel.text];
                break;
            case AboutUs:
                //push 关于我们
                [self pushToVcWithClassName:NSStringFromClass([DWDAboutUsViewController class]) title:cell.textLabel.text];
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 1){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否确认退出" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self backAction];
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:sureAction];
        [alert addAction:cancleAction];
        
        [self presentViewController:alert animated:YES completion:nil];

    }
}

//退出登录
- (void)backAction{
    [[DWDCustBaseClient sharedCustBaseClient] requestAcctCustLogout:[DWDCustInfo shared].custId success:^{
        [self getoutLogic];
    } failure:^(NSError *error) {
        [self getoutLogic];
    }];
    
}

- (void)getoutLogic{
    __weak typeof(self) weakSelf = self;
    
    DWDTabbarViewController *tabbarVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarItem *item = tabbarVc.tabBar.items[0];
    tabbarVc.selectedIndex = 2;
    
    //从本地删除toke KeyChainTypePassword  KeyChainTypeRefreshToken
    [[DWDKeyChainTool sharedManager] deleteKeyWithType:KeyChainTypePassword];
    [[DWDKeyChainTool sharedManager] deleteKeyWithType:KeyChainTypeToken];
    [[DWDKeyChainTool sharedManager] deleteKeyWithType:KeyChainTypeRefreshToken];
    
    //退出 Xcom
    NSData *loginData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeMsgClientLogoutData:[DWDCustInfo shared].custId];
    [[DWDChatClient sharedDWDChatClient] sendData:loginData];
    //断开Socket
    [[DWDChatClient sharedDWDChatClient] disConnect];
   
    //清除本地缓存
    [[DWDCustInfo  shared] clearUserInfoData];
    
    if ([DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId || [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId) {
        // 证明在聊天界面退出了程序
        // 清空该界面相关badgeCount
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId myCusId:[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId success:^{
            
        } failure:^{
            
        }];
    }
    
    item.badgeValue = nil;
    
    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationRefreshInformation" object:nil];
}

- (void)pushToVcWithClassName:(NSString *)VCName title:(NSString*)title{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:VCName bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:VCName];
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
