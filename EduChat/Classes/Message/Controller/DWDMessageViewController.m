//
//  DWDMessageViewController.m
//  DWDSj
//
//  Created by apple  on 15/10/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMessageViewController.h"
#import "DWDChatController.h"
#import "DWDContactsViewController.h"
#import "DWDLoginViewController.h"
#import "DWDSystemMessageTableController.h"
#import "DWDClassPickUpCenterListController.h"
#import "DWDPickUpCenterChildListTableViewController.h"
#import "DWDPickUpCenterChildTableViewController.h"
#import "DWDTeacherDetailViewController.h"
#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDTabbarViewController.h"
#import "DWDIntMessageController.h"

#import "DWDChatSessionCell.h"
#import "ENMBadgedBarButtonItem.h"

#import "DWDSysMsg.h"
#import "DWDOfflineMsg.h"
#import "DWDNoteChatMsg.h"
#import "DWDAddressBookPeopleModel.h"
#import "DWDChatMsgReceipt.h"
#import "DWDRecentChatModel.h"
#import "DWDChatClient.h"
#import "DWDSystemChatMsg.h"

#import "DWDChatMsgDataClient.h"
#import "DWDMessageDatabaseTool.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDFriendApplyDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDPickUpCenterListDataBaseModel.h"

#import <AddressBook/AddressBook.h>
#import <YYModel.h>
#import <FMDB.h>

#import "UIImage+Utils.h"


@interface DWDMessageViewController () <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *chatSessionDatas;     //会话数据
@property (nonatomic) CGFloat testHeight;
@property (weak, nonatomic) DWDChatClient *chatSocketClient;

@property (nonatomic , strong) ENMBadgedBarButtonItem *badgeBarItem;
@property (weak, nonatomic)UIButton *contactBtn;  //自定义通讯录按钮
@property (nonatomic , assign) NSUInteger navBarItembadgeCount;

@property (nonatomic , strong) NSArray *offlinMsgArray;

@property (strong, nonatomic) UIView *headerDescribeView;
@end

@implementation DWDMessageViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.isShowTabbarWhenDismiss = YES;
    
    [self setupTableView];
   
    [self buildNavBarItemsContactShowRed:NO];
    
    //数据为空，显示小免崽子图片
    self.stateView = [self setupStateViewWithImageName:@"img_contact_message_empty" describe:@"暂无新消息\n快去和朋友打招呼吧~"];
    
   
      //----获取通迅录-----
    if ([DWDCustInfo shared].isLogin) {
        [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
            
            [self loadSessionData:nil];
            
        } failure:^(NSError *error) {
            
        }];
        
        //第一次登录加入引导页
        //1、判断缓存是否记录用户登录过，否则显示引导页
        NSString *flagKey = [NSString stringWithFormat:@"isLoginByCustId:%@",[DWDCustInfo shared].custId];
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:flagKey];
        if (![str isEqualToString:@"isLogin"]) {
            UIButton *guideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            guideBtn.frame = [UIApplication sharedApplication].keyWindow.bounds;
            guideBtn.highlighted = NO;
            
            NSString *imgName = [DWDCustInfo shared].isTeacher ? @"teacherGuide" : @"parentGuide";
            [guideBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            [guideBtn addTarget:self action:@selector(removeGuideBtnBackgroudImage:) forControlEvents:UIControlEventTouchDown];
            [[UIApplication sharedApplication].keyWindow addSubview:guideBtn];
            //2、标记用户登录过
            [[NSUserDefaults standardUserDefaults] setObject:@"isLogin" forKey:flagKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
       
    }else{
        
    }
    
    [self loadSessionData:nil];
    

    [self observeNotification];
    
    //检查是否登录
    [self checkLogin];
    
}


- (void)observeNotification{

    // 登录回执
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNewMsg:)
                                                 name:DWDReceiveLoginReceiptNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter]  // 新消息处理完成, 刷新tableview
//     addObserver:self
//     selector:@selector(receivedNewChatMsgShouldReload:)
//     name:DWDShouldReloadRecentChatData
//     object:nil];
    

    
//    [[NSNotificationCenter defaultCenter]  // 收到最近联系人会话列表刷新通知
//     addObserver:self
//     selector:@selector(updateTbRecentChatList)
//     name:@"update_tb_recentChatList_success"
//     object:nil];

    
    // 监听有人申请加我为好友，显示小红点
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRedNotificaton:)
                                                 name:kDWDNotificationShowRed
                                               object:nil];
    
    
    //监听网络超时、scoket 一直未连接 显示headerView
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(netState:)
                                                 name:kDWDNotificationNetState
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(calssPhotoChange:) name:kDWDChangeClassPhotoKeyNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupPhotoChange:) name:kDWDChangeGroupPhotoKeyNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupNicknameChange:) name:kDWDChangeGroupNicknameNotification object:nil];
    
    //监听 实时更新 联系人昵称
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContactName:)
                                                 name:kDWDChangeContactNicknameNotification
                                               object:nil];
    
    //监听 实时更新 联系人头像
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateContactPhotoKey:)
                                                 name:kDWDChangeContactPhotoKeyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recentChatLastMsgNeedChanged:) name:DWDNotificationRecentChatLastContentNeedChange object:nil];
    
    
    //检查是否登录
    [self checkLogin];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //移除
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDWDNotificationNeedRecentChatLoad
                                                  object:nil];
    //监听 刷新 会话列表 刷新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSessionData:)
                                                 name:kDWDNotificationRecentChatLoad
                                               object:nil];

    //从本地库 刷新列表
    if (self.isNeedGlobleLoadData) {
        self.isNeedGlobleLoadData = NO;
        [self loadSessionData:nil];
    }
    
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //监听 是否需要刷新会话列表
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(isNeedLoadData:)
                                                 name:kDWDNotificationNeedRecentChatLoad
                                               object:nil];
    //移除
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDWDNotificationRecentChatLoad
                                                  object:nil];

}

// view 即将出现 , 取所有的badgeCount显示
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
     NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
    //申请好友条数是否为nil ,nil则不显示小红点
    NSDictionary *applayDict = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    if (applayDict) {
        BOOL isRead = [applayDict[@"isRead"] boolValue];
        [self buildNavBarItemsContactShowRed:isRead];
    }else{
        [self buildNavBarItemsContactShowRed:NO];
    }
    
}

- (void)dealloc
{
    DWDLog(@"会话列表控制器销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Setup
- (void)setupTableView
{
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([DWDChatSessionCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NSStringFromClass([DWDChatSessionCell class])];
    
    self.tableView.rowHeight = 70.5;
    
//    self.tableView.tableHeaderView = self.searchController.searchBar;
  
//    self.tableView.contentOffset = CGPointMake(0, self.searchController.searchBar.frame.size.height);
}


#pragma mark Getter
- (NSMutableArray *)chatSessionDatas{
    if (!_chatSessionDatas) {
        _chatSessionDatas = [NSMutableArray array];
    }
    return _chatSessionDatas;
}

- (UIView *)headerDescribeView
{
    if (!_headerDescribeView) {
        _headerDescribeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40)];
        _headerDescribeView.backgroundColor = DWDRGBColor(254, 239, 182);
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40/2 - 22/2, 22, 22)];
        imv.image = [UIImage imageNamed:@"ic_network_failure"];
        [_headerDescribeView addSubview:imv];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imv.frame) + 10, imv.cenY - 20/2, 280, 20)];
        lab.font = DWDFontContent;
        lab.textColor = DWDColorContent;
        lab.text = @"当前网络不可用，请检查你的网络设置";
        [_headerDescribeView addSubview:lab];
    }
    return _headerDescribeView;
}
#pragma mark - Private Method
- (void)buildNavBarItemsContactShowRed:(BOOL)showRed
{
    //加号按钮
    UIBarButtonItem *addContactItem = [self buildPublicNavBarItem];
    
    //自定义通讯录按钮
    NSString *str = NSLocalizedString(@"Contacts", nil);
    CGSize realSize = [str realSizeWithfont:DWDFontContent];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0,0,realSize.width+10, realSize.height);
    [button addTarget:self
               action:@selector(showContacts)
     forControlEvents:UIControlEventTouchDown];
    button.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [button setTitle:str forState:UIControlStateNormal];
    [button.titleLabel setFont:DWDFontContent];
    
    //判断是否需要显示小红点
    if (showRed) {
        UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(button.w-10, 0, 10, 10)];
        redView.backgroundColor = [UIColor redColor];
        redView.layer.masksToBounds = YES;
        redView.layer.cornerRadius = redView.h/2;
        [button addSubview:redView];
    }
    
    UIBarButtonItem *showContactItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItems = @[addContactItem, showContactItem];
}


/** 移除引导页 */
- (void)removeGuideBtnBackgroudImage:(UIButton *)sender
{
    [sender removeFromSuperview];
}


#pragma mark - Notification Implementation

- (void)loadSessionData:(NSNotification *)note {
    
    DWDLog(@"%@" , note.userInfo);
    
    [self.chatSessionDatas removeAllObjects];
    
    NSArray *chatDatas = [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getRecentChatListById:[DWDCustInfo shared].custId];
    
    
    for (int i = 0; i < chatDatas.count; i++) {
        DWDRecentChatModel *recentChat = [DWDRecentChatModel yy_modelWithDictionary:chatDatas[i]];
        [self.chatSessionDatas addObject:recentChat];
    }
    
    // 排序
    [self.chatSessionDatas sortUsingComparator:^NSComparisonResult(DWDRecentChatModel *obj1,DWDRecentChatModel *obj2) {
        //lastCreatTime must not be nil,so ,if nil setup @0
        NSComparisonResult result = [obj1.lastCreatTime? obj1.lastCreatTime : @0 compare:obj2.lastCreatTime ? obj2.lastCreatTime : @0];
        
        if (result == NSOrderedAscending) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
         NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
        NSDictionary *applayDict = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
        NSInteger chatBadgeCount = [applayDict[@"chatBadgeCount"] integerValue];
        // 获取所有的badgeCount总数显示 ,加上申请条数
        
        if ([[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue] + chatBadgeCount == 0) {
            self.tabBarItem.badgeValue = nil;
        }else{
            NSString *visualCountString = [[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue] + chatBadgeCount >= 99 ? @"99+" : [NSString stringWithFormat:@"%zd",[[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue] + chatBadgeCount];
            self.tabBarItem.badgeValue = visualCountString;
        }
    });
}

- (void)isNeedLoadData:(NSNotification *)note{
    NSDictionary *dict = note.userInfo;
    self.isNeedGlobleLoadData = [dict[@"isNeedLoadData"] boolValue];
    
}

- (void)calssPhotoChange:(NSNotification *)note{
    NSDictionary *dict = note.object;
    NSNumber *operationId = dict[@"operationId"];
    NSString *changePhotoKey = dict[@"changePhotoKey"];
    
    for (DWDRecentChatModel *recentChat in self.chatSessionDatas) {
        
        if ([recentChat.custId isEqual:operationId]) {
            recentChat.photoKey = changePhotoKey;
            NSUInteger index = [self.chatSessionDatas indexOfObject:recentChat];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
    
}

- (void)groupPhotoChange:(NSNotification *)note{
    NSDictionary *dict = note.object;
    NSNumber *operationId = dict[@"operationId"];
    NSString *changePhotoKey = dict[@"changePhotoKey"];
    
    for (DWDRecentChatModel *recentChat in self.chatSessionDatas) {
        if ([recentChat.custId isEqual:operationId]) {
            recentChat.photoKey = changePhotoKey;
            NSUInteger index = [self.chatSessionDatas indexOfObject:recentChat];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        
    }
}

- (void)groupNicknameChange:(NSNotification *)note{
    NSDictionary *dict = note.userInfo;
    
    NSNumber *operationId = dict[@"operationId"];
    NSString *changeNickname = dict[@"changeNickname"];
    
    for (DWDRecentChatModel *recentChat in self.chatSessionDatas) {
        if ([recentChat.custId isEqual:operationId]) {
            recentChat.nickname = changeNickname;
            NSUInteger index = [self.chatSessionDatas indexOfObject:recentChat];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)updateContactPhotoKey:(NSNotification *)note{
    NSDictionary *dict = note.userInfo;
    NSNumber *operationId = dict[@"operationId"];
    NSString *changePhotoKey = dict[@"changePhotoKey"];
    
    for (DWDRecentChatModel *recentChat in self.chatSessionDatas) {
        if ([recentChat.custId isEqual:operationId]) {
            recentChat.photoKey = changePhotoKey;
            NSUInteger index = [self.chatSessionDatas indexOfObject:recentChat];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        
    }
}

- (void)updateContactName:(NSNotification *)note{
    NSDictionary *dict = note.userInfo;
    
    NSNumber *operationId = dict[@"operationId"];
    NSString *changeNickname = dict[@"changeNickname"];
    
    for (DWDRecentChatModel *recentChat in self.chatSessionDatas) {
        if ([recentChat.custId isEqual:operationId]) {
            recentChat.nickname = changeNickname;
            NSUInteger index = [self.chatSessionDatas indexOfObject:recentChat];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

- (void)recentChatLastMsgNeedChanged:(NSNotification *)notification{
    NSDictionary *dict = notification.userInfo;
    
    DWDBaseChatMsg *changedMsg = dict[@"changedMsg"];  // 被删除或被撤回的消息 / 可能是noteString
    NSNumber *type = dict[@"type"];  // 1 被删除 2 被撤回
    NSNumber *isAllDeleted = dict[@"isAllMsgDeleted"]; // 是否主动删除操作中,所有历史消息的第一条消息
    
    NSNumber *friendId = dict[@"tid"];
    
    // 显示上一条消息内容
    NSString *content;
    if ([isAllDeleted isEqualToNumber:@1]) {
        content = @"";
    }else{
        if ([changedMsg isKindOfClass:[NSString class]]) {
            content = (NSString *)changedMsg;
        }else{ // 需要取出上一条消息来显示的情况
            if ([type isEqualToNumber:@1]) {
                if ([changedMsg.msgType isEqualToString:kDWDMsgTypeText]) {
                    DWDTextChatMsg *textMsg = (DWDTextChatMsg *)changedMsg;
                    content = textMsg.content;
                }else if ([changedMsg.msgType isEqualToString:kDWDMsgTypeAudio]){
                    content = @"[语音消息]";
                }else if ([changedMsg.msgType isEqualToString:kDWDMsgTypeImage]){
                    content = @"[图片消息]";
                }else if ([changedMsg.msgType isEqualToString:kDWDMsgTypeVideo]){
                    content = @"[视频消息]";
                }else if ([changedMsg.msgType isEqualToString:kDWDMsgTypeNote]){
                    DWDNoteChatMsg *noteMsg = (DWDNoteChatMsg *)changedMsg;
                    content = noteMsg.noteString;
                }
            }else{
                NSString *name;
                if ([changedMsg.fromUser isEqualToNumber:[DWDCustInfo shared].custId]) { // 自己发的消息
                    name = @"你";
                }else{
                    name = changedMsg.remarkName.length > 0 ? changedMsg.remarkName : changedMsg.nickname;
                }
                content = [NSString stringWithFormat:@"%@撤回了一条消息",name];
            }
        }
    }
    
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateLastContentWithCusId:friendId content:content success:^{
        
        for (DWDRecentChatModel *recent in self.chatSessionDatas) {
            if ([recent.custId isEqualToNumber:friendId]) { // 需更新的数据在界面上
                NSUInteger index = [self.chatSessionDatas indexOfObject:recent];
                
                recent.lastContent = content;
                
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
    } failure:^{
        
    }];
}


#pragma mark - checkLogin
- (void)checkLogin
{
    if ([DWDCustInfo shared].isLogin) {
        
        
    }
}

#pragma mark - Button Action
/** 进入联系人 **/
- (void)showContacts {
    
    [self buildNavBarItemsContactShowRed:NO];
    
    
//    DWDContactsViewController *contactsController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDContactsViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDContactsViewController class])];
    DWDContactsViewController *contactsController = [[DWDContactsViewController alloc] init];
    contactsController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contactsController animated:YES];
}



/** 根据网络状态 是否显示HeaderView */
- (void)netState:(NSNotification *)noti
{
    NSNumber *state = noti.userInfo[@"state"];
    
    if ([state isEqualToNumber:@(-1)])
    {
        if(self.tableView.tableHeaderView == nil)
        {
            self.tableView.tableHeaderView = self.headerDescribeView;
            [self.tableView reloadData];
        }
    }
    else
    {
        if (self.tableView.tableHeaderView == self.headerDescribeView)
        {
            self.tableView.tableHeaderView = nil;
            [self.tableView reloadData];
        }
        
    }
}
- (void)receivedNewMsg:(NSNotification *)notification {  // 登录
    NSDictionary *userInfo = notification.userInfo;
    DWDChatMsgReceipt *msg = userInfo[DWDReceiveNewChatMsgKey];
    DWDLog(@"login msg: %@", msg);
    
    if ([msg.status isEqualToNumber:@1])
    {
        DWDLog(@"login success!");
        DWDJPSHEnterBackgroundModel *jpshu = [[DWDJPSHEnterBackgroundModel alloc] init];
        jpshu.code = @"sysmsgAppFrontRun";
        jpshu.entity = @{@"custId" : [DWDCustInfo shared].custId};
        
        [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeJPSHUObject:jpshu]];
    }
    else if ([msg.status isEqualToNumber:@3])
    {
        //登录异常、重新
        if ([DWDCustInfo shared].isLogin)
        {
            //发送通知、会话列表头部提醒
            NSDictionary *dict = @{@"state":@(-1)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNetState object:nil userInfo:dict];
        }
    }
}

/** 应该只刷新单行 重构时改进 */
- (void)receivedNewChatMsgShouldReload:(NSNotification *)note{   // 收到新的消息 通知
    [self loadSessionData:nil];
}

/** 显示红点 */
- (void)showRedNotificaton:(NSNotification *)nofi
{
   
    [self buildNavBarItemsContactShowRed:YES];
}


// 到"新的朋友" 中 点击了接受好友申请  新加的好友已经加入到最近会话列表的通知
- (void)updateTbRecentChatList{
    // 移除当前所有列表数据刷新tableview表格
    [self loadSessionData:nil];
}

#pragma mark - Tableview Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //如果无联系人，显示无数据默认页
    if (self.chatSessionDatas.count == 0) {
      
        [self.view addSubview:self.stateView];
    }
    else{
        if ([self.view.subviews containsObject:self.stateView]) {
            [self.stateView removeFromSuperview];
        }
    }
    return self.chatSessionDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DWDRecentChatModel *recentChat = self.chatSessionDatas[indexPath.row];
    
    DWDChatSessionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDChatSessionCell class])];
    
    NSNumber *currentBadgeNum = [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getRecentChatBadgeNumWithFriendId:recentChat.custId];
    recentChat.badgeCount = currentBadgeNum;
    cell.recentChatModel = recentChat;
    
    if (indexPath.row == self.chatSessionDatas.count - 1) {  // 最后一个cell分割线满宽
        cell.seperatorLayer.hidden = NO;
    }else{
        cell.seperatorLayer.hidden = YES;
    }
    return cell;
}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    DWDAddressBookPeopleModel *addressbookPeople = self.chatSessionDatas[indexPath.row];
//    NSString *unreadString = @"15";
//    BOOL isRead = [unreadString isEqualToString:@"0"];
//
//    NSString *readActionTitle = isRead ? NSLocalizedString(@"MarkToUnread", nil) : NSLocalizedString(@"MarkToRead", nil);
//
//    UITableViewRowAction *readAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:readActionTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        NSMutableDictionary *lineData = [currentLineData mutableCopy];
//
//        if (isRead) {
//
//            [lineData setValue:@"1" forKey:@"unread"];
//
//        } else {
//
//            [lineData setValue:@"0" forKey:@"unread"];
//
//        }
//
//        [self.chatSessionDatas  replaceObjectAtIndex:indexPath.row withObject:lineData];
//
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }];
//
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        [self.chatSessionDatas removeObjectAtIndex:indexPath.row];
//
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//
//    }];
//
//    return @[deleteAction, readAction];
//}

// we need this void method, you maybe want to konw why, i gone to tell you "i do not konw"
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDRecentChatModel *recentChat = self.chatSessionDatas[indexPath.row];
    
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:recentChat.custId success:^{
        [self.chatSessionDatas removeObject:recentChat];
        
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:recentChat.custId myCusId:[DWDCustInfo shared].custId success:^{
            
            NSInteger badgeValue = [[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue];
            NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
            NSDictionary *applayDict = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
            NSInteger chatBadgeCount = [applayDict[@"chatBadgeCount"] integerValue];
            badgeValue += chatBadgeCount;
            
            if (badgeValue - [recentChat.badgeCount integerValue] <= 0) {
                self.tabBarItem.badgeValue = nil;
            }else{
                NSString *visualCountString = badgeValue - [recentChat.badgeCount integerValue] > 99 ? @"99+" : [NSString stringWithFormat:@"%zd",badgeValue - [recentChat.badgeCount integerValue]];
                self.tabBarItem.badgeValue = visualCountString;
            }
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            
        } failure:^{
            
        }];
        
        
    } failure:^{
        
    }];
}

#pragma mark - Tableview Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //加入班级验证讯息
    //通过验证 DWDRecentChatModel type 选择push到哪个控制器
    
    DWDRecentChatModel *recentChat = self.chatSessionDatas[indexPath.row];
    
    recentChat.badgeCount = @0;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    // 控制器跳转
    if ([recentChat.custId isEqual:[DWDCustInfo shared].systemCustId]) {
        //在下一个控制器启动的时候 读取数据库数据 不要再启动前读取
        DWDSystemMessageTableController *systemController = [[DWDSystemMessageTableController alloc] init];
        systemController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:systemController animated:YES];
    }
    //接送中心
    else if ([recentChat.custId isEqualToNumber:@1001]) {
        if ([DWDCustInfo shared].isTeacher) {
            DWDMarkLog(@"Teacher List");
            NSArray *listArray =  [[DWDPickUpCenterDatabaseTool sharedManager] selectTeacherList];
            if (listArray.count == 1) {
                DWDPickUpCenterListDataBaseModel *dataModel = listArray[0];
//                [[DWDPickUpCenterDatabaseTool sharedManager] clearTeacherListBadgeNumberWithClassId:dataModel.classId];
                DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.classId = dataModel.classId;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                DWDClassPickUpCenterListController *vc = [[DWDClassPickUpCenterListController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            NSArray *ar = [[DWDPickUpCenterDatabaseTool sharedManager] selectChildList];
            if ([ar count] > 1) {
                DWDMarkLog(@"Child List");
                DWDPickUpCenterChildListTableViewController *vc = [[DWDPickUpCenterChildListTableViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                if (ar.count) {
                    DWDPickUpCenterListDataBaseModel *model = ar[0];
                DWDMarkLog(@"Child Detail");
                DWDPickUpCenterChildTableViewController *vc = [[DWDPickUpCenterChildTableViewController alloc] init];
                vc.classId = model.classId;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }
    //智能办公
    else if ([recentChat.custId isEqualToNumber:@1002]) {
        DWDIntMessageController *vc = [[DWDIntMessageController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        chatController.hidesBottomBarWhenPushed = YES;
        
        chatController.chatType = recentChat.chatType;
        
        chatController.toUserId = recentChat.custId;
        
        if (recentChat.chatType == DWDChatTypeClass) {
            
            //根据ClassId 从本地库获取班级信息
            DWDClassModel *model = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:recentChat.custId myCustId:recentChat.myCustId];
            if (model == nil) {
                [DWDProgressHUD showText:@"你已经不在这个班级"];
                // 删除这个cell
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:recentChat.custId success:^{
                    
                    [self.chatSessionDatas removeObject:recentChat];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    
                } failure:^{
                    
                }];
                return;
            }
            chatController.myClass = model;
            
        }else if (recentChat.chatType == DWDChatTypeGroup){
            
            //根据groupId 从本地库获取群组信息
              DWDGroupEntity * model = [[DWDGroupDataBaseTool sharedGroupDataBase]getGroupInfoWithMyCustId:recentChat.myCustId groupId:recentChat.custId];
            if (model == nil) {
                [DWDProgressHUD showText:@"你已经不在这个群组"];
                // 删除这个cell
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:recentChat.custId success:^{
                    
                    [self.chatSessionDatas removeObject:recentChat];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    
                } failure:^{
                    
                }];
                return;
            }
        
            chatController.groupEntity = model;
            
        }else{
            chatController.recentChatModel = recentChat;
        }
        
        [self.navigationController pushViewController:chatController animated:YES];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



@end
