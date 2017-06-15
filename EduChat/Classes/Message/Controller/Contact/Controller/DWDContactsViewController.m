//
//  DWDContactsViewController.m
//  EduChat
//
//  Created by Gatlin on 11/5/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDContactsViewController.h"

#import "DWDNewFriendsListViewController.h"
#import "DWDRemarkNameViewController.h"
#import "DWDGroupListViewController.h"
#import "DWDClassListViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDTabbarViewController.h"

#import "DWDContactListCell.h"
#import "DWDContactHeaderCell.h"

#import "DWDRecentChatModel.h"
#import "DWDTextChatMsg.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDLocalizedIndexedCollation.h"
#import "DWDSysMsg.h"

#import <Masonry/Masonry.h>
@interface DWDContactsViewController () <DWDContactHeaderCellDelegate>

@property (strong, nonatomic) NSArray *contactsGroupData;
@property (strong, nonatomic) NSMutableArray *contactsData;        //联系人
@property (strong, nonatomic) NSMutableArray *arrSearchContact;

@property (strong, nonatomic) DWDLocalizedIndexedCollation *collation;  //字母索引封装类
@property (strong, nonatomic) UIBarButtonItem *addContactItem;

//@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (nonatomic , strong) DWDContactHeaderCell *contactHeaderCell;

@property (nonatomic, assign) NSUInteger applayCouny;  //申请条数



@end

@implementation DWDContactsViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //从数据库取出联系人
    __block NSArray *arrContacts = [NSArray array];
    
    [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId
                                                                     success:^{
                                                                         
                                                                     } failure:^(NSError *error) {
                                                                                                                                  
                                                                     }];
    
    
    arrContacts = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId];
   
    //为字母索引封装类传入数据源
    self.collation.arrDataSource = arrContacts;
    
    //清除ChatBadgeCount
    [self cleanChatBadgeCount];
    
    [self setupNavigation];
    [self setupTableView];
    
    [self addObserver];
    
    //数据为空，显示小免崽子图片
    self.stateView = [self setupStateViewWithImageName:@"img_contacts_empty" describe:@"一个好友都没有\n淡淡的优伤~"];
    self.stateView.cenY += 100;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //清除ChatBadgeCount
    [self cleanChatBadgeCount];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - Setup
- (void)setupNavigation
{
    self.navigationItem.rightBarButtonItem = [self buildPublicNavBarItem];
    self.navigationItem.title = NSLocalizedString(@"Contacts", nil);
}

- (void)setupTableView
{
    //通讯录控制器，无好友显示图片需重置下移60位
     self.noDataImv.y = 80 + 64;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDContactListCell class]) bundle:nil ] forCellReuseIdentifier:NSStringFromClass([DWDContactListCell class])];
    
    //搜索UITableViewController 注册Cell
    [self.searchTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDContactListCell class]) bundle:nil ] forCellReuseIdentifier:NSStringFromClass([DWDContactListCell class])];
    
    // setup searchBar placeholder
    self.searchController.searchBar.placeholder = @"搜索好友";
    
    //设置 tableHeaderView
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, DWDScreenW, 40 + 80);
    
    [headerView addSubview:self.searchController.searchBar];
    
    DWDContactHeaderCell *headerBoby = [[DWDContactHeaderCell alloc] initWithFrame:CGRectMake(0, self.searchController.searchBar.h, DWDScreenW, 80)];
    headerBoby.actionDelegate = self;
    _contactHeaderCell = headerBoby;
    
    
    
    if (self.applayCouny != 0) {
        headerBoby.badgeLabel.hidden = NO;
        _contactHeaderCell.badgeLabel.text = [NSString stringWithFormat:@"%zd", self.applayCouny];
    }else{
        headerBoby.badgeLabel.hidden = YES;
    }
    
    [headerView addSubview:headerBoby];
    
    self.tableView.tableHeaderView = headerView;
    
    //设置字母索引背景色为透明
    if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)]) {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexColor = DWDColorMain;
    }
}

#pragma mark - Add Observer
- (void)addObserver
{
    //监听服务器有新加好友的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadContacts:)
                                                 name:DWDNotificationContactUpdate object:nil];
    
    //监听获取本地库联系人、刷新列表
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getContacts:)
                                                 name:DWDNotificationContactsGet
                                               object:nil];
    
    // 监听有人申请加我为好友，显示小红点
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRedNotificaton:)
                                                 name:kDWDNotificationShowRed
                                               object:nil];
    
}


#pragma mark - Getter


- (NSMutableArray *)contactsData
{
    return self.collation.arrSectionsArray;
}

- (DWDLocalizedIndexedCollation *)collation
{
    if (!_collation) {
        _collation = [DWDLocalizedIndexedCollation currentCollation];
    }
    return _collation;
}

- (NSMutableArray *)arrSearchContact
{
    if (!_arrSearchContact) {
        _arrSearchContact = [NSMutableArray array];
    }
    return _arrSearchContact;
}



#pragma mark - Private Method
/** 清除 Tabbar 条数*/
- (void)cleanChatBadgeCount
{
    //0. 取出缓存
    NSInteger chatBadgeCount = 0;
    BOOL isRead = NO;
    
     NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
    NSDictionary *applayDict = [[[NSUserDefaults standardUserDefaults] objectForKey:cacheKey] mutableCopy];
    
    if (applayDict)
    {
        chatBadgeCount = [applayDict[@"chatBadgeCount"] integerValue];
       
        _applayCouny = [applayDict[@"contactBadgeCount"] integerValue];
        
        
        DWDTabbarViewController *tabbarVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UITabBarItem *item = tabbarVc.tabBar.items[0];
        
        if ([item.badgeValue isEqualToString:@"99+"]) {
            NSUInteger afterMinusBadgeNum = [[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue];
            NSString *visualBadgeString = afterMinusBadgeNum >= 99 ? @"99+" : [NSString stringWithFormat:@"%zd",afterMinusBadgeNum];
            item.badgeValue = visualBadgeString;
        }else{
            
            NSInteger badgeCount = [item.badgeValue integerValue] - chatBadgeCount;
            item.badgeValue = badgeCount <= 0 ? nil : [NSString stringWithFormat:@"%zd" , badgeCount];
        }
        
        chatBadgeCount = 0;
        
        [applayDict setValue:@(chatBadgeCount) forKey:@"chatBadgeCount"];
        
        isRead = NO;
        [applayDict setValue:@(isRead) forKey:@"isRead"];
        
        //1. 存入缓存
        [[NSUserDefaults standardUserDefaults] setObject:applayDict forKey:cacheKey];
    }
    
}




#pragma mark - Notification

/** 显示红点 */
- (void)showRedNotificaton:(NSNotification *)nofi
{
    //0. 取出缓存
     NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
    NSDictionary *applayDict = [[[NSUserDefaults standardUserDefaults] objectForKey:cacheKey] mutableCopy];
    
    if (applayDict)
    {
        _applayCouny = [applayDict[@"contactBadgeCount"] integerValue];
        _contactHeaderCell.badgeLabel.hidden = NO;
        _contactHeaderCell.badgeLabel.text = [NSString stringWithFormat:@"%d", _applayCouny];
    }
    
    //    NSNumber *applayCouny = [[NSUserDefaults standardUserDefaults] objectForKey:@"applyCount"];
    //    _badgeCount = [applayCouny intValue];
    //    _contactHeaderCell.badgeLabel.hidden = NO;
    //    _contactHeaderCell.badgeLabel.text = [NSString stringWithFormat:@"%d", _badgeCount];
    //    [[NSUserDefaults standardUserDefaults] setObject:@(_badgeCount) forKey:@"applyCount"];
    
}


// 收到上传新加好友 , 或者新建班级  群组成功 的通知
- (void)reloadContacts:(NSNotification *)notification {
    
    NSDictionary *userinfo = notification.object;
    
    // 先增量更新
    [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
        
        // (从服务器获取最新的联系人成功  插入新好友到联系人表成功)
        
        NSArray *arrContacts = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId];
        // 插入最新添加的好友到 会话列表 在内部会获取传入好友ID的好友
        
        DWDRecentChatModel *recentChat = userinfo[@"recentChat"];
        /*
         发通知时构造的模型结构:
         DWDRecentChatModel *recentChat = [[DWDRecentChatModel alloc] init];
         recentChat.myCustId = [DWDCustInfo shared].custId;
         recentChat.custId = rowData[@"friendCustId"];
         recentChat.photoKey = rowData[@"photoKey"];
         recentChat.lastContent = rowData[@"verifyInfo"];
         recentChat.nickname = rowData[@"friendNickname"];
         */
        DWDTextChatMsg *msg = [[DWDTextChatMsg alloc] init];
        msg.msgType = kDWDMsgTypeText;
        msg.content = recentChat.lastContent;
        
        
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithRecentChatModel:recentChat success:^{
            // 发通知更新会话列表
              [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
            
        } failure:^{
            
        }];
        
        self.collation.arrDataSource = arrContacts;
        //刷新自己的列表
        [self.tableView reloadData];
        
        
    } failure:^(NSError *error) {
        
    }];
}
/** 获取联系人 */
- (void)getContacts:(NSNotification *)notification
{
    NSArray *arrContacts =  [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId];
    self.collation.arrDataSource = arrContacts;
    [self.tableView reloadData];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableView == tableView){
        //如果无联系人，显示无数据默认页
        if (self.collation.arrDataSource.count == 0) {
            [self.view addSubview:self.stateView];
        }
        else{
            if ([self.view.subviews containsObject:self.stateView]) {
                [self.stateView removeFromSuperview];
            }
        }
        return self.contactsData.count;
    }
    else{
        if (self.arrSearchResult.count == 0) {
            [self.searchTableView addSubview:self.notDataResultLab];
        }
        else{
            if ([self.searchTableView.subviews containsObject:self.notDataResultLab]) {
                [self.notDataResultLab removeFromSuperview];
            }
        }
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView) {
        return [self.contactsData[section] count];
    }
    else{
        return self.arrSearchResult.count;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDContactListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactListCell class]) ];
    
    NSDictionary *contact;
    
    if(tableView == self.tableView){
        contact = self.contactsData[indexPath.section][indexPath.row];
    }else{
        contact = self.arrSearchResult[indexPath.row];
    }
    
    [cell.headerImv sd_setImageWithURL:[NSURL URLWithString:contact[@"photoKey"]] placeholderImage:DWDDefault_MeBoyImage];
    
    cell.nameLab.text = [[DWDPersonDataBiz new] checkoutExistRemarkName:contact[@"remarkName"] nickname:contact[@"nickname"]];
    switch ([contact[@"custType"] intValue]) {
        case 4:
            cell.roleIcon.image = [UIImage imageNamed:@"msg_teacher_ic"];
            break;
        case 6:
            cell.roleIcon.image = [UIImage  imageNamed:@"msg_parent_ic"];
        default:
            break;
    }
    return cell;
}


#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

/** 修改这里 设置分区高度、无数据的区设置为0 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.contactsData objectAtIndex:section] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

/** 设置区头名 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.collation.localizedIndexedCollation sectionTitles][section];
}


/** 过滤无数据索引字母 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //右边索引、这里去掉没有数据的索引字线
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [[self.collation.localizedIndexedCollation sectionTitles] count]; i++) {
        if ([[self.collation.arrSectionsArray objectAtIndex:i] count] > 0) {
            [existTitles addObject:[[self.collation.localizedIndexedCollation sectionTitles] objectAtIndex:i]];
        }
    }
    return existTitles;
    
}

/** 选择索引触发事件 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.collation.localizedIndexedCollation sectionForSectionIndexTitleAtIndex:index];
}



/** 左滑事件 */
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *currentLineData = self.contactsData[indexPath.section][indexPath.row];
    
    
    UITableViewRowAction *remarksAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Remarks", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DWDPersonData" bundle:nil];
        DWDRemarkNameViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDRemarkNameViewController class])];
        vc.friendId = currentLineData[@"custId"];
        vc.friendRemarkName = currentLineData[@"remarkName"];
        vc.nickname = currentLineData[@"nickname"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    return @[remarksAction];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *contact;
    if (self.tableView == tableView) {
        contact = self.contactsData[indexPath.section][indexPath.row];
    }else{
        contact = self.arrSearchResult[indexPath.row];
    }
    
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    vc.personType = DWDPersonTypeIsFriend;
    vc.custId = contact[@"custId"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - DWDContactHeaderCell Delegate 
- (void)contactHeaderCellDidShowNewFriendsWithTitle:(NSString *)title {
    
    _contactHeaderCell.badgeLabel.hidden = YES;
    
    DWDNewFriendsListViewController *vc = [[DWDNewFriendsListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)contactHeaderCellDidShowGroupsWithTitle:(NSString *)title  {
     DWDGroupListViewController *groupVC = [[DWDGroupListViewController alloc] init];
    groupVC.title = title;
    [self.navigationController pushViewController:groupVC animated:YES];
    
}

- (void)contactHeaderCellDidShowClassesWithTitle:(NSString *)title  {
    DWDClassListViewController *classVC = [[DWDClassListViewController alloc] init];
    [self.navigationController pushViewController:classVC animated:YES];
}

#pragma mark - SearchController Delegate
// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // Set searchString equal to what's typed into the searchbar
    NSString *searchString = self.searchController.searchBar.text;
    
    [self updateFilteredContentForAirlineName:searchString];
    [self.searchTableView reloadData];
    
}

- (void)updateFilteredContentForAirlineName:(NSString *)airlineName
{
    if (airlineName == nil) {
        
        // If empty the search results are the same as the original data
        self.arrSearchResult = [self.contactsData mutableCopy];
    } else {
        
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        // Else if the airline's name is
        for (NSArray *array in self.contactsData) {
            for (NSDictionary *airline in array) {
                if ([airline[@"nickname"] containsString:airlineName] || [airline[@"remarkName"] containsString:airlineName]) {
                    
                    [searchResults addObject:airline];
                }
                self.arrSearchResult = searchResults;
            }
        }
        
    }
}




@end
