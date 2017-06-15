//
//  DWDPersonDataViewController.m
//  EduChat
//
//  Created by Gatlin on 16/3/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPersonDataViewController.h"
#import "DWDSendVerifyInfoViewController.h"
#import "DWDPersonSetupViewController.h"
#import "DWDChatController.h"
#import "DWDClassSetGagViewController.h"

#import "DWDAccountHeaderCell.h"
#import "DWDAccountSourceCell.h"
#import "DWDAccountVerifyCell.h"
#import "DWDAccountPhotosCell.h"
#import "DWDAccountActionCell.h"


#import "DWDPersonerDataEntity.h"
#import "DWDCustomUserInfoEntity.h"


#import "DWDAccountClient.h"
#import "DWDFriendVerifyClient.h"

#import "DWDFriendApplyDataBaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import <YYModel/YYModel.h>
#import "DWDImagesScrollView.h"


@interface DWDPersonDataViewController ()<DWDAccountActionDelegate>
@property (strong, nonatomic) DWDPersonerDataEntity *personerDataEntity;
@property (strong, nonatomic) DWDCustomUserInfoEntity *customUserInfoEntity;
@property (getter=isAuthority, nonatomic) BOOL authority; //有权限 自己被用户设置不看朋友圈或被用户拉黑
@end

@implementation DWDPersonDataViewController

#pragma mark Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详细资料";
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personReloadData) name:DWDNotificationPersonDataReload object:nil];
}
#pragma mark - Setup View
- (void)setupTableView
{
    UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([DWDAccountHeaderCell class]) bundle:nil];
    UINib *sourceNib = [UINib nibWithNibName:NSStringFromClass([DWDAccountSourceCell class]) bundle:nil];
    UINib *photosNib = [UINib nibWithNibName:NSStringFromClass([DWDAccountPhotosCell class]) bundle:nil];
    UINib *verifyNib = [UINib nibWithNibName:NSStringFromClass([DWDAccountVerifyCell class]) bundle:nil];
    UINib *actionNib = [UINib nibWithNibName:NSStringFromClass([DWDAccountActionCell class]) bundle:nil];
    
    [self.tableView registerNib:headerNib forCellReuseIdentifier:NSStringFromClass([DWDAccountHeaderCell class])];
    [self.tableView registerNib:sourceNib forCellReuseIdentifier:NSStringFromClass([DWDAccountSourceCell class])];
    [self.tableView registerNib:photosNib forCellReuseIdentifier:NSStringFromClass([DWDAccountPhotosCell class])];
    [self.tableView registerNib:verifyNib forCellReuseIdentifier:NSStringFromClass([DWDAccountVerifyCell class])];
    [self.tableView registerNib:actionNib forCellReuseIdentifier:NSStringFromClass([DWDAccountActionCell class])];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


#pragma mark - Setter
- (void)setCustId:(NSNumber *)custId
{
    _custId = custId;
    
    //校验好友关系 本地库查询
    BOOL isFirend = [[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:custId];
    if (isFirend) {
        //右上角设置按钮，自己是和陌生人是没有这个按钮的
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(pushPersonDataVC)];
        self.personType = DWDPersonTypeIsFriend;
    
    }else{
       //检验是否为自己
        if ([custId isEqualToNumber:[DWDCustInfo shared].custId]) {
            self.personType = DWDPersonTypeMySelf;
        }else{
            //非好友、判断是否是设置禁言的
            if (self.isNeedShowSetGag) {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(pushPersonDataVC)];
            }
        }
    }
    //request
    [self requestGetPersonDataWithMyFriendCustId:custId];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.personerDataEntity) {
        return 0;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.personType == DWDPersonTypeMySelf){
        return 1;
    }
    return self.isShowPhoneNumber ? 3 : 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //开启恶心东西 判断是否有从智能通讯录进来，是则显示电话号码。
    NSInteger phoneRow = self.isShowPhoneNumber ? 1 : 0;
    
    if (indexPath.row == 0) {
        DWDAccountHeaderCell *headerCell =
        [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDAccountHeaderCell class]) ];
        headerCell.personerDataEntity = self.personerDataEntity;
        headerCell.customUserInfoEntity = self.customUserInfoEntity;
        
        //call back
        __weak typeof(self) weakSelf = self;
        [headerCell setClickAvatarBlock:^(UIImageView *imv) {
            if (self.personType == DWDPersonTypeMySelf) {
                if([DWDCustInfo shared].photoMetaModel.photoKey.length > 0){
                    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:@[[DWDCustInfo shared].photoMetaModel]];
                    [scrollView presentViewFromImageView:imv atIndex:0 toContainer:weakSelf.view];
                }
            }else{
                if(self.personerDataEntity.photohead.photoKey.length > 0){
                    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:@[self.personerDataEntity.photohead]];
                    [scrollView presentViewFromImageView:imv atIndex:0 toContainer:weakSelf.view];
                }
            }

        }];
       
        
        return headerCell;
        
    }else if(indexPath.row == 1 + phoneRow){ //需要显示电话，此row 为 2
        if (self.personType == DWDPersonTypeIsFriend) {
            return [self accountActionCell:tableView actionType:DWDAccountActionTypeSend];
        }else if (self.personType == DWDPersonTypeIsStrangerAdd){
            return [self accountActionCell:tableView actionType:DWDAccountActionTypeAddContact];
        }else if (self.personType == DWDPersonTypeIsStrangerApply){
            return [self accountActionCell:tableView actionType:DWDAccountActionTypePassVerify];
        }
    }else if (indexPath.row == phoneRow){//需要显示电话，此row 为 1
        DWDAccountSourceCell *cell =
        [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDAccountSourceCell class]) ];
        cell.sourceTitleLabel.text = @"电话";
        cell.sourceLabel.text = self.personerDataEntity.mobile;
        return cell;
    }
    return nil;
}

#pragma mark Private Method
/** 初始化DWDAccountActionCell方法 按钮 **/
- (DWDAccountActionCell *)accountActionCell:(UITableView *)tableView actionType:(DWDAccountActionType )actionType
{
    DWDAccountActionCell *actionCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDAccountActionCell class])];
    actionCell.actionDelegate = self;
    [actionCell setActionType:actionType];
  
    return actionCell;
    
}


#pragma mark Button Action
- (void)pushPersonDataVC
{
    if (self.isNeedShowSetGag) {
        DWDClassSetGagViewController *vc = [[DWDClassSetGagViewController alloc] init];
        vc.custId = self.custId;
        vc.classId = self.classId;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DWDPersonData" bundle:nil];
        DWDPersonSetupViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDPersonSetupViewController class])];
        vc.entity = self.customUserInfoEntity;
        vc.friendCustId = self.custId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Notification
- (void)personReloadData
{
    //request
    [self requestAuthorityWithFriendCustId:self.custId];
}

#pragma mark -  DWDAccountAction Delegate
/** 发送消息 **/
- (void)accountActionDidSendMsg
{
    
    DWDRecentChatModel *recentChat = [[DWDRecentChatModel alloc] init];
    recentChat.myCustId = [DWDCustInfo shared].custId;
    recentChat.custId = self.personerDataEntity.custId;
    recentChat.photoKey = self.personerDataEntity.photoKey;
    recentChat.nickname = self.personerDataEntity.nickname;
    recentChat.remarkName = self.customUserInfoEntity.friendRemarkName;

    
    DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    
    chatController.toUserId = self.custId;
    chatController.recentChatModel = recentChat;
    [self.navigationController pushViewController:chatController animated:YES];
    
}
/** 添加为好友 **/
- (void)accountActionDidAddContact
{
    
    DWDSendVerifyInfoViewController *vc = [[DWDSendVerifyInfoViewController alloc] initWithNibName:NSStringFromClass([DWDSendVerifyInfoViewController class]) bundle:nil];
    vc.friendCustId = self.custId;
    vc.source = [NSNumber numberWithInteger:self.sourceType];
    [self.navigationController pushViewController:vc animated:YES];
    
}

/** 通过验证 **/
- (void)accountActionDidPassVerify
{
    [self requestPassVerifyWithCustId:self.custId state:@1];
}


#pragma mark - Request
/** 获取好友信息 */
- (void)requestGetPersonDataWithMyFriendCustId:(NSNumber *)custId
{
  
    
    //调 getUserInfoEx 接口
    [[DWDAccountClient sharedAccountClient]
     getUserInfoEx:[DWDCustInfo shared].custId
     friendId:custId extensions:nil
     success:^(NSDictionary *info) {
        
         self.personerDataEntity = [DWDPersonerDataEntity yy_modelWithDictionary:info];
         [self requestAuthorityWithFriendCustId:custId];
     }
     failure:^(NSError *error) {
         self.navigationItem.rightBarButtonItem.enabled = NO;
     }];

}
// 是否设置权限
-(void)requestAuthorityWithFriendCustId:(NSNumber *)friendCustId
{
    WEAKSELF;
    [[DWDAccountClient sharedAccountClient]
     getCustomUserInfo:[DWDCustInfo shared].custId
     friendId:friendCustId
     success:^(NSDictionary *info) {
         
         weakSelf.customUserInfoEntity = [DWDCustomUserInfoEntity yy_modelWithDictionary:info];
         
         if ([weakSelf.customUserInfoEntity.lookPhoto isEqualToNumber:@1] || [weakSelf.customUserInfoEntity .blackList isEqualToNumber:@1]) {
             
             weakSelf.authority = YES;
             
         }else{
             //无权限
             weakSelf.authority = NO;
         }
         
         //刷新tableView
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.tableView reloadData];
         });
         
     }
     failure:^(NSError *error) {
         [weakSelf.tableView reloadData];
     }];
}

/** 通过验证 */
- (void)requestPassVerifyWithCustId:(NSNumber *)custId state:(NSNumber *)state
{
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    hud.labelText = nil;
    [[DWDFriendVerifyClient sharedFriendVerifyClient] updateFirendVerifyState:[DWDCustInfo shared].custId friendId:custId state:state success:^(NSArray *info) {
        
        [hud hide:YES];
        
        //发通知，上传新添加的好友到服务器保存 , 再刷新本地数据库
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactUpdate object:nil];
        //刷新会话列表
        NSDictionary *dict = @{@"recentChat" : self.recentChatModel};
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:dict];
        
        [[DWDContactsDatabaseTool sharedContactsClient] updateFriendShipWithCustId:custId isFriend:YES];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
        DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        vc.chatType = DWDChatTypeFace;
        //判断是否有备注名
        vc.title = [[DWDPersonDataBiz new] checkoutExistRemarkName:self.customUserInfoEntity.friendRemarkName nickname:self.personerDataEntity.nickname];
        vc.toUserId = custId;
        
        [self.navigationController pushViewController:vc animated:YES];
        
        //刷新本地库好友状态
        [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] updateWithStatus:state MyCustId:[DWDCustInfo shared].custId friendCustId:self.custId];
       
    } failure:^(NSError *error) {
        [hud showText:@"验证失败" afterDelay:DefaultTime];
    }];
    
}

@end
