//
//  DWDPersonSetupViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPersonSetupViewController.h"
#import "DWDRemarkNameViewController.h"

#import "DWDAccountClient.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDFriendApplyDataBaseTool.h"
@interface DWDPersonSetupViewController ()<DWDRemarkNameViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *remarkLab;                //备注名
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;               //删除按钮
@property (weak, nonatomic) IBOutlet UISwitch *notSeeMyPhotoSwitch;     //不让看相册按钮
@property (weak, nonatomic) IBOutlet UISwitch *joinBlackBookSwitch;     //加入黑名单按钮

@end

@implementation DWDPersonSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = @"用户设置";
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.w, 10)];
    self.tableView.backgroundColor = DWDColorBackgroud;
    [self setupNib];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    NSNumber *look = self.notSeeMyPhotoSwitch.on ? @1 : @0;
     NSNumber *black = self.joinBlackBookSwitch.on ? @1 : @0;
   
    if ([self.entity.lookPhoto isEqualToNumber:look] && [self.entity.blackList isEqualToNumber:black]) {
        //不请求更改
        return;
    }
    //request
    [self requestUpdateCustomUserInfoFriendId:self.friendCustId lookPhoto:look blackList:black];
}


#pragma mark - Setup
- (void)setupNib
{
    self.deleteBtn.layer.masksToBounds = YES;
    self.deleteBtn.layer.cornerRadius = self.deleteBtn.h/2;
    
    self.remarkLab.text = self.entity.friendRemarkName;

    //按钮状态 根据设置权限显示
    BOOL lookPhoto = [self.entity.lookPhoto isEqualToNumber:@1] ? YES : NO;
    BOOL blackList = [self.entity.blackList isEqualToNumber:@1] ? YES : NO;
    [self.notSeeMyPhotoSwitch setOn:lookPhoto animated:YES];
    [self.joinBlackBookSwitch setOn:blackList animated:YES];
}

#pragma mark - Button Action
- (IBAction)deleteFriendAction:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定删除好友？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //request delect contact
        [self requestDelegateContact];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1, in order to hidden blackList
    return 1;
}
#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - DWDRemarkNameViewController Delegate
- (void)remarkNameViewController:(DWDRemarkNameViewController *)remarkNameViewController doneRemarkName:(NSString *)doneRemarkName
{
    self.remarkLab.text = doneRemarkName;
    self.entity.friendRemarkName = doneRemarkName;
}

#pragma mark - Request
/** 删除联系人 */
- (void)requestDelegateContact
{
 
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[HttpClient sharedClient]
     postApi:@"AddressBookRestService/deleteEntity"
     params:@{DWDCustId:[DWDCustInfo shared].custId,DWDFriendId:self.friendCustId}
     success:^(NSURLSessionDataTask *task, id responseObject) {
         
         
         //删除本地库联系人
         [[DWDContactsDatabaseTool sharedContactsClient] deleteContactWithFriendCustId:self.friendCustId success:^{
              [hud showText:@"删除成功"];
             
             
             //对于 好友申请列表中的已添加 进行本地库删除
             [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] deleteWithFriendCustId:self.friendCustId MyCustId:[DWDCustInfo shared].custId];
             
             //删除会话历史聊天记录
             [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:self.friendCustId
                                                                                       chatType:DWDChatTypeFace
                                                                                        success:^{
                                                                                        }
                                                                                        failure:^(NSError *error) {
                                                                                        }];
             
             //删除会话列表
             [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:self.friendCustId success:^{
                 
                 //发送通知、是否刷新 会话列表
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];

                 [self.navigationController popToRootViewControllerAnimated:YES];
             } failure:^{
                 
             }];
             
         } failure:^{
             
         }];
        
     }
     
     failure:^(NSURLSessionDataTask *task, NSError *error) {
         
         [hud showText:@"删除失败"];
         
     }];
    
}
- (void)requestUpdateCustomUserInfoFriendId:(NSNumber *)friendId lookPhoto:(NSNumber *)lookPhoto blackList:(NSNumber *)blackList
{
    [[DWDAccountClient sharedAccountClient] updateCustomUserInfo:[DWDCustInfo shared].custId friendId: friendId friendRemarkName:nil lookPhoto:lookPhoto blackList:blackList success:^(NSDictionary *info) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationPersonDataReload object:nil];
        
    } failure:^(NSError *error) {
        
    }];
}



#pragma mark - storyboard
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushRemarkName"]) {
        DWDRemarkNameViewController *vc = segue.destinationViewController;
        vc.friendId = self.friendCustId;
        vc.delegate = self;
        vc.friendRemarkName = self.entity.friendRemarkName;
        
    }

}


@end
