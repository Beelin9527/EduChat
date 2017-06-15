//
//  DWDNewFriendsListViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/3.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDNewFriendsListViewController.h"
#import "DWDNewFriendNeedInviteController.h"
#import "DWDFindNewFriendsViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDChatController.h"

#import "DWDContactsInviteViewController.h"

// 通讯录数据库工具
#import "DWDContactsDatabaseTool.h"

#import "DWDNewFriendsListCell.h"

#import "DWDRecentChatModel.h"
#import "DWDFriendApplyEntity.h"

#import "DWDFriendApplyDataBaseTool.h"

#import "DWDFriendVerifyClient.h"

#import <YYModel/YYModel.h>
#import <Masonry/Masonry.h>
@interface DWDNewFriendsListViewController ()<DWDNewFriendsListCellDelegate>
@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, strong) UIButton *inviteIconBtn;
@property (nonatomic, strong) UIButton *inviteBtn;

@property (nonatomic, strong) UIButton *addIconBtn;
@property (nonatomic, strong) UIButton *addBtn;

@end

@implementation DWDNewFriendsListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"新的朋友";
    self.view.backgroundColor = DWDColorBackgroud;
    //request
    [self requestFriendVerifyData];

//    数据为空，显示小免崽子图片
    self.stateView = [self setupStateViewWithImageName:@"img_contacts_empty" describe:@"暂无好友申请~"];
    
    [self setupHeaderView];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
      //清除申请条数
    [self cleanContactCount];
}

- (void)dealloc
{
    //清除申请条数
    [self cleanContactCount];
}

#pragma mark - Setup

- (void)setupHeaderView{
    [self.view addSubview:({
        _inviteBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"邀请朋友" forState:UIControlStateNormal];
            [btn setTitleColor:DWDColorSecondary forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"ic_invite_newfriend"] forState:UIControlStateNormal];
             [btn setImage:[UIImage imageNamed:@"ic_invite_newfriend_press"] forState:UIControlStateHighlighted];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
            [btn addTarget:self action:@selector(pushInviteVC) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = DWDFontContent;
            btn.backgroundColor = [UIColor whiteColor];
            btn;
        });
    })];
    [self.view addSubview:({
        _addBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:@"添加朋友" forState:UIControlStateNormal];
            [btn setTitleColor:DWDColorSecondary forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"ic_add_newfriend"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"ic_add_newfriend_press"] forState:UIControlStateHighlighted];
             [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
            [btn addTarget:self action:@selector(pushAddFriendVC) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = DWDFontContent;
            btn.backgroundColor = [UIColor whiteColor];
            btn;
        });
    })];
    
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(DWDScreenW/2 - 0.5, 20, 1, 40);
    line.backgroundColor = DWDColorSeparator;
    [self.view addSubview:line];
    
    //masonry
    [self.inviteBtn makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.5).mas_offset(-1);
        make.height.mas_equalTo(80);
    }];
    [self.addBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self.view);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.5).mas_offset(1);
        make.height.mas_equalTo(80);
    }];
    
    
}
- (void)setupTableView
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[DWDNewFriendsListCell class] forCellReuseIdentifier:NSStringFromClass([DWDNewFriendsListCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDNewFriendsListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DWDNewFriendsListCell class])];
    self.tableView.frame = CGRectMake(0, 90, DWDScreenW, DWDScreenH - DWDTopHight - 90);
    
    self.stateView.frame = self.tableView.frame;
}

#pragma mark - Getter
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:5];
    }
    return _dataSource;
}


#pragma mark - Private Methoc
/** 清除联系人控制器 的 申请 条数 */
- (void)cleanContactCount
{
    //0. 取出缓存
     NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
    NSDictionary *applayDict = [[[NSUserDefaults standardUserDefaults] objectForKey:cacheKey] mutableCopy];
    
    if (applayDict)
    {
        [applayDict setValue:@(0) forKey:@"contactBadgeCount"];
        
        //1. 存入缓存
        [[NSUserDefaults standardUserDefaults] setObject:applayDict forKey:cacheKey];
    }
    
}
#pragma mark - Button Action
- (void)pushInviteVC {
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeContacts withController:self authorized:^{
        DWDContactsInviteViewController *vc = [[DWDContactsInviteViewController alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
//    DWDNewFriendNeedInviteController *tableViewVc = [[DWDNewFriendNeedInviteController alloc] init];
//    [self.navigationController pushViewController:tableViewVc animated:YES];

}

- (void)pushAddFriendVC
{
    DWDFindNewFriendsViewController *vc = [[DWDFindNewFriendsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //如果无联系人，显示无数据默认页
    if (self.dataSource.count == 0) {
        [self.view addSubview:self.stateView];
    }
    else{
        if ([self.view.subviews containsObject:self.stateView]) {
            [self.stateView removeFromSuperview];
        }
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDNewFriendsListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDNewFriendsListCell class])];
    cell.delegate = self;
    DWDFriendApplyEntity *entity = self.dataSource[indexPath.row];
    cell.entity = entity;

     return cell;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    DWDFriendApplyEntity *entity = self.dataSource[indexPath.row];
    
    DWDRecentChatModel *recentChat = [[DWDRecentChatModel alloc] init];
    recentChat.myCustId = [DWDCustInfo shared].custId;
    recentChat.custId = entity.friendCustId;
    recentChat.photoKey = entity.photoKey;
    recentChat.lastContent = entity.verifyInfo;
    recentChat.nickname = entity.friendNickname;
    recentChat.lastCreatTime = entity.addTime;

    
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    if ([entity.status isEqualToNumber:@0]) {
        
        vc.personType = DWDPersonTypeIsStrangerApply;
        vc.custId = entity.friendCustId;
        vc.recentChatModel = recentChat;
        
    }else{
        
        vc.personType = DWDPersonTypeIsFriend;
        vc.custId = entity.friendCustId;
        
    }
    
    [self.navigationController pushViewController:vc animated:YES];
      
}


/** 提交编辑操作时会调用这个方法(删除，添加) */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DWDFriendApplyEntity *entity = self.dataSource[indexPath.row];
    // 删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 对未接受进行 删除 。需要请求接口。状态置为2（拒绝）
        if ([entity.status isEqualToNumber:@0]) {
            [self requestRejectWithCustId:entity.friendCustId indexPath:indexPath];
            return;
        }
        
        //0.删除本地库
        [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] deleteWithFriendCustId:entity.friendCustId MyCustId:[DWDCustInfo shared].custId];
        // 1.删除数据
        [self.dataSource removeObjectAtIndex:indexPath.row];
        
        // 2.更新UITableView UI界面
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/** 决定tableview的编辑模式 */ 
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - DWDNewFriendsListCell Delegate
/** 接受好友请求 */
- (void)newfriendsListCell:(DWDNewFriendsListCell *)newfriendsListCell didSelectAcceptButtonOfFriendEntity:(DWDFriendApplyEntity *)entity
{
    
    
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    
    __weak typeof(self) weakSelf = self;
    // 上传新加的好友到服务器
    [[DWDFriendVerifyClient sharedFriendVerifyClient] updateFirendVerifyState:[DWDCustInfo shared].custId friendId:entity.friendCustId state:@1 success:^(NSArray *info) {
        
        [hud hide:YES];
        
        DWDRecentChatModel *recentChat = [[DWDRecentChatModel alloc] init];
        recentChat.myCustId = [DWDCustInfo shared].custId;
        recentChat.custId = entity.friendCustId;
        recentChat.photoKey = entity.photoKey;
        recentChat.lastContent = entity.verifyInfo;
        recentChat.nickname = entity.friendNickname;
        long long timeStamp = [NSDate date].timeIntervalSince1970 * 1000;
        recentChat.lastCreatTime = [NSNumber numberWithLongLong:timeStamp];
        
        // 添加通讯录临时状态,确保聊天控制器显示正常
        [[DWDContactsDatabaseTool sharedContactsClient] addNewFriendTempStatus:entity.friendCustId nickname:entity.friendNickname];
        //发通知，上传新添加的好友到服务器保存 , 再刷新本地数据库
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactUpdate object:nil];
        //刷新会话列表
        NSDictionary *dict = @{@"recentChat" : recentChat};
        //发送通知、是否刷新 会话列表
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
        
        //进入聊天控制器
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
            DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
            vc.chatType = DWDChatTypeFace;
            vc.toUserId = entity.friendCustId;
            vc.recentChatModel = recentChat;
            [weakSelf.navigationController pushViewController:vc animated:YES];
            
        });
        //刷新本地库好友状态
        [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] updateWithStatus:@1 MyCustId:[DWDCustInfo shared].custId friendCustId:entity.friendCustId];
    } failure:^(NSError *error) {
        
        [hud showText:@"请求失败"];
        
    }];
}


#pragma mark - Request
/** 获取好友申请数据 */
- (void)requestFriendVerifyData
{
    __weak typeof(self) weakSelf = self;
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[DWDFriendVerifyClient sharedFriendVerifyClient] getFriendInviteList:[DWDCustInfo shared].custId success:^(NSMutableArray *invites) {
        
        [hud hide:YES];
        
        NSMutableArray *entityArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *dict in invites) {
            DWDFriendApplyEntity *entity = [DWDFriendApplyEntity yy_modelWithDictionary:dict];
            [entityArray addObject:entity];
        }
        
        //插入数据库
        [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] insertToTableWithMyCustId:[DWDCustInfo shared].custId friendApplyArray:entityArray];

        //从本地库获取所有好友申请名单
        _dataSource =[[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] getAllFriendsApplyWithMyCustId:[DWDCustInfo shared].custId].mutableCopy;
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        
    }];
}

/** 拒绝 */
- (void)requestRejectWithCustId:(NSNumber *)custId indexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
     DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[DWDFriendVerifyClient sharedFriendVerifyClient] updateFirendVerifyState:[DWDCustInfo shared].custId friendId:custId state:@2 success:^(NSArray *info) {
        [hud hide:YES];
        //0.删除本地库
        [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] deleteWithFriendCustId:custId MyCustId:[DWDCustInfo shared].custId];
        // 1.删除数据
        [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
        
        // 2.更新UITableView UI界面
        [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 
    } failure:^(NSError *error) {
        [hud showText:@"删除失败"];
    }];

}

@end
