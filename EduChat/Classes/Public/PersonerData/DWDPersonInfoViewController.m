//
//  DWDPersonInfoViewController.m
//  EduChat
//
//  Created by apple on 16/4/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPersonInfoViewController.h"

#import "DWDContactModel.h"
#import "DWDGroupClient.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"

#import "DWDInfoHeaderCell.h"
#import "DWDPersonInfoSetCell.h"
#import "DWDContactSelectViewController.h"
#import "DWDNavViewController.h"
#import "DWDChatController.h"
#import "DWDTipOffViewController.h"
#import "DWDSearchMsgRecordViewController.h"

@interface DWDPersonInfoViewController ()<UITableViewDelegate, UITableViewDataSource, DWDContactSelectViewControllerDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
}

@property (nonatomic, strong) NSMutableArray *selectArray;
@end

@implementation DWDPersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    
    [self setSubviews];
}

- (void)setSubviews
{
    _titleArray = @[@"",@[@"置顶聊天",@"消息免打扰",@"聊天图片"],@[@"查找聊天内容",@"清空聊天记录"],@[@"举报"]];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)setCustId:(NSNumber *)custId
{
    _custId = custId;
    [self.selectArray addObject:custId];
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectArray;
}

#pragma mark - TableViewDelegate && DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
            break;
        case 3:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        static NSString *ID = @"headerCell";
        DWDInfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDInfoHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.avatarImg = self.avatarImg;
        cell.nickName = self.nickname;
        [cell setAddContactBlock:^{
            
            DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc]init];
            vc.delegate = self;
            vc.type = DWDSelectContactTypeAddEntity;
            
            //从本地库获取联系人，若已添加的需要排除
            vc.dataSource =  [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId exclude:self.selectArray];
            
            DWDNavViewController *naviVC = [[DWDNavViewController alloc] initWithRootViewController:vc];
            [self.navigationController presentViewController:naviVC animated:YES completion:nil];
        }];
        return cell;
        
    }else {
        
        static NSString *ID = @"infoCell";
        DWDPersonInfoSetCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDPersonInfoSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLbl.text = _titleArray[indexPath.section][indexPath.row];
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 0 || indexPath.row == 1) {
                cell.rightViewType = DWDCellRightViewTypeSwitch;
            }else {
                cell.rightViewType = DWDCellRightViewTypeArrow;
            }

        }else if (indexPath.section == 2 && indexPath.row == 0) {
            
            cell.rightViewType = DWDCellRightViewTypeArrow;
            
        }else {
            
            cell.rightViewType = DWDCellRightViewTypeNone;
            
        }
        
        return cell;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 70;
    }else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2) {
        DWDLogFunc;
    }else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            
            DWDSearchMsgRecordViewController *searchVC = [[DWDSearchMsgRecordViewController alloc] init];
            searchVC.friendCustId = @(1);
            [self.navigationController pushViewController:searchVC animated:YES];
        }else {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = @"正在删除...";
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:self.custId
                                                                                      chatType:DWDChatTypeFace
                                                                                       success:^{
                                                                                            [hud hide:YES afterDelay:1];
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                            [hud hide:YES afterDelay:1];
                                                                                       }];
        }
    }else if (indexPath.section == 3){
        DWDTipOffViewController *tipOffVC = [[DWDTipOffViewController alloc] init];
        [self.navigationController pushViewController:tipOffVC animated:YES];
    }
}

#pragma mark - DWDContactSelectViewController delegate
- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type
{
    if (type == DWDSelectContactTypeAddEntity) {
        [self.selectArray addObjectsFromArray:contactsIds];
    }else if (type == DWDSelectContactTypeDeleteEntity){
        [self.selectArray removeObjectsInArray:contactsIds];
    }
    
    //从本地库获取联系人
    NSMutableString *groupName = [[NSMutableString alloc] init];
    NSArray *contactsArray = [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId ByIds:self.selectArray];
    for (DWDContactModel *contact in contactsArray) {
        groupName = [NSMutableString stringWithFormat:@"%@、%@",groupName,contact.nickname];
    }
    [groupName deleteCharactersInRange:NSMakeRange(0, 1)];
    if (groupName.length >= 20) {
        [groupName substringWithRange:NSMakeRange(0, 20)];
    }

    __weak DWDPersonInfoViewController *weakSelf = self;
    [[DWDGroupClient sharedRequestGroup] getGroupRestAddGroup:groupName duration:@4 friendCustId:self.selectArray success:^(id responseObject) {
        
        //刷新数据库  通知
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload object:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
            DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
            vc.chatType = DWDChatTypeGroup;
            vc.toUserId = responseObject[@"groupId"];
            DWDGroupEntity *entity = [[DWDGroupEntity alloc] init];
            entity.groupId = responseObject[@"groupId"];
            entity.groupName = responseObject[@"groupName"];
            entity.isMian = responseObject[@"isMian"];
            entity.isShowNick = responseObject[@"isShowNick"];
            vc.groupEntity = entity;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
        
    } failure:^(NSError *error) {
        
        [DWDProgressHUD showText:error.localizedFailureReason];
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
