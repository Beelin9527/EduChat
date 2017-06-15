//
//  DWDChooseConatctController.m
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChooseConatctController.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRelayOnChatChooseContactCell.h"
#import "DWDRelayChooseMidView.h"
#import "DWDContactModel.h"
#import "DWDGroupEntity.h"
#import "DWDClassModel.h"
#import "DWDNoteChatMsg.h"

#import "DWDRelayChooseClassController.h"
#import "DWDRelayChooseGroupController.h"

#import "DWDGroupClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDChatMsgClient.h"
#import "DWDChatClient.h"

#import "DWDMessageDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDMessageTimerManager.h"

#import <Masonry.h>
#import <YYModel.h>

@interface DWDChooseConatctController () <UITableViewDataSource , UITableViewDelegate , DWDRelayChooseMidViewDelegate , UISearchBarDelegate>

@property (nonatomic , strong) NSMutableArray *contactsBySection;
@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *sectionTitle;
@property (nonatomic , weak) UISearchBar *searchBar;
@property (nonatomic , strong) NSMutableArray *selectedArray;
@property (nonatomic , strong) NSMutableArray *selectedCustIdArray;

@end

@implementation DWDChooseConatctController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpSubViews];
    
    self.view.backgroundColor = DWDColorBackgroud;
    self.title = @"选择联系人";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarItemClick:)];
    
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)rightBarItemClick:(UIBarButtonItem *)item{
    DWDLog(@"right bar item click");
    
    NSMutableArray *selectedContactArray = [NSMutableArray array];
    self.selectedCustIdArray = [NSMutableArray array];
    for (int i = 0; i < self.contactsBySection.count; i++) {
        NSArray *a = self.contactsBySection[i];
        for (int j = 0; j < a.count; j++) {
            DWDContactModel *contact = a[j];
            if (contact.selected) {
                [self.selectedCustIdArray addObject:contact.custId];
                [selectedContactArray addObject:contact];
            }
        }
    }
    _selectedArray = selectedContactArray;
    
    DWDContactModel *first = [selectedContactArray firstObject];
    
    NSString *message = selectedContactArray.count == 1 ? [NSString stringWithFormat:@"确定发送给%@?",first.nickname] : @"创建群组并发送给群组成员?";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertViewCancel:(UIAlertView *)alertView{ // 被电话打断神马的
    DWDLog(@"123123123123123");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // 点击确定 , 转发
        
        if (self.selectedArray.count == 0){
            MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.labelText = @"您还没有选择群员";
            [HUD hide:YES afterDelay:1.5];
            return;
        }
        
        if (self.selectedArray.count == 1) {  // 转发给单人 , 可能是班级, 群组 直接发送
            
            DWDContactModel *contact = [self.selectedArray firstObject];
            
            DWDBaseChatMsg *baseMsg = [self handleRelayingMsgWithToUser:contact.custId chatType:contact.chatType createTime:[NSNumber numberWithLongLong:([NSDate date].timeIntervalSince1970 * 1000)]];
            
            [self relayMsgWithBaseMsg:baseMsg]; // 拼接data发送
            
            [DWDProgressHUD showText:@"转发成功!"];
            
            // 再发个通知 , 判断当前聊天界面是否要刷新即可
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatRelayJudgeCurrentTouser object:nil userInfo:@{@"msg" : baseMsg}];
            
            return;
        }
        
        
        DWDProgressHUD *hud = [DWDProgressHUD showHUD];  // 选了多人 , 创建群组
        [[DWDGroupClient sharedRequestGroup]
         getGroupRestAddGroup:@"群组"
         duration:@4 // 4为永久
         friendCustId:self.selectedCustIdArray
         success:^(id responseObject) {
             
             DWDGroupEntity *entity = [[DWDGroupEntity alloc] init];
             entity.groupId = responseObject[@"groupId"];
             entity.groupName = responseObject[@"groupName"];
             entity.isMian = responseObject[@"isMian"];
             entity.isShowNick = responseObject[@"isShowNick"];
             entity.memberCount = @(self.selectedArray.count + 1);
             
             DWDLog(@"zlc groupId : %@" , entity.groupId);
             
             //刷新这个新的群组到数据库
             [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                 
                 //构造系统消息模型
                 DWDNoteChatMsg *noteChatMsg = [self dealWithNoteMsgByGroupId:entity.groupId selectedArr:self.selectedCustIdArray];
                 // 转发消息
                 
                 DWDBaseChatMsg *base = [self handleRelayingMsgWithToUser:entity.groupId chatType:DWDChatTypeGroup createTime:@([noteChatMsg.createTime integerValue] + 1)];
                 
                 // 再发个通知 , 判断当前聊天界面是否要刷新即可
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatRelayJudgeCurrentTouser object:nil userInfo:@{@"msg" : base}];
                 
                 [self relayMsgWithBaseMsg:base]; // 拼接data发送
                 
                 hud.labelText = @"转发成功!";
                 [hud hide:YES afterDelay:1.5];
                 
                 
             } failure:^(NSError *error) {
                 hud.labelText = @"创建群组失败,请重试";
                 [hud hide:YES afterDelay:1.5];
             }];
             
             
             
         } failure:^(NSError *error) {
             
             [hud showText:@"创建失败"];
             [hud hide:YES afterDelay:1.5];
         }];
    }
}

#pragma mark - <UISearchBarDelagte>

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        self.contactsBySection = [self createSectionArrayWithArray:[[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId]];  // 分好组的所有人的array;
        [self.tableView reloadData];
        return;
    }
    
    
    
    NSMutableArray *allContacts = [NSMutableArray array];
    
    NSArray *arr1 = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId];
    [allContacts addObjectsFromArray:arr1];
    
//    if ([DWDCustInfo shared].isTeacher) {
//        NSArray *arr2 = [[DWDClassDataBaseTool sharedClassDataBase] getClassList:[DWDCustInfo shared].custId];
//        [allContacts addObjectsFromArray:arr2];
//    }
//    
//    NSArray *arr3 = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupList:[DWDCustInfo shared].custId];
//    [allContacts addObjectsFromArray:arr3];
    
    NSMutableArray *allModels = [NSMutableArray array];
    for (int i = 0; i < allContacts.count; i++) {
        NSObject *obj = allContacts[i];
        
        DWDContactModel *recent = [DWDContactModel new];
        
        if ([obj isKindOfClass:[DWDContactModel class]]) {
            DWDContactModel *contact = (DWDContactModel *)obj;
            if ([contact.nickname containsString:searchText]) {
                
                recent.custId = contact.custId;
                recent.nickname = contact.nickname;
                recent.photoKey = contact.photoKey;
                recent.remarkName = contact.remarkName;
                recent.chatType = DWDChatTypeFace;
                
                [allModels addObject:recent];
            }
        }else if ([obj isKindOfClass:[DWDClassModel class]]){
            DWDClassModel *aClass = (DWDClassModel *)obj;
            
            if ([aClass.className containsString:searchText]) {
                
//                recent.myCustId = [DWDCustInfo shared].custId;
                recent.custId = aClass.classId;
                recent.chatType = DWDChatTypeClass;
                recent.nickname = aClass.className;
                recent.photoKey = aClass.photoKey;
                
                [allModels addObject:recent];
            }
            
        }else if ([obj isKindOfClass:[DWDGroupEntity class]]){
            DWDGroupEntity *group = (DWDGroupEntity *)obj;
            if ([group.groupName containsString:searchText]) {
//                recent.myCustId = [DWDCustInfo shared].custId;
                recent.custId = group.groupId;
                recent.chatType = DWDChatTypeGroup;
                recent.nickname = group.groupName;
                recent.photoKey = group.photoKey;
                [allModels addObject:recent];
            }
        }
        
    }
    
    NSMutableArray *resultArr = [NSMutableArray array];
    
    NSArray *sectionedArray = [self createSectionArrayWithArray:allModels];
    for (int i = 0; i < sectionedArray.count; i++) {
        NSArray *sectionArr = sectionedArray[i];
        for (int j = 0 ; j < sectionArr.count; j++) {
            DWDContactModel *recent = sectionArr[j];
            if ([recent.nickname containsString:searchText]) {
                [resultArr addObject:recent];
            }
        }
    }
    
    self.contactsBySection = [self createSectionArrayWithArray:resultArr];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)relayMsgWithBaseMsg:(DWDBaseChatMsg *)baseMsg{
    
    NSData *relayData;
    if (baseMsg.chatType == DWDChatTypeFace) {
        if ([baseMsg.msgType isEqualToString:kDWDMsgTypeText]) {
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makePlainTextForO2O:(DWDTextChatMsg *)baseMsg];
        }else if ([baseMsg.msgType isEqualToString:kDWDMsgTypeImage]){
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeImageForO2O:(DWDImageChatMsg *)baseMsg];
        }else if ([baseMsg.msgType isEqualToString:kDWDMsgTypeAudio]){
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeAudioForO2O:(DWDAudioChatMsg *)baseMsg];
        }else if ([baseMsg.msgType isEqualToString:kDWDMsgTypeVideo]){
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeVideoForO2O:(DWDVideoChatMsg *)baseMsg];
        }
    }else{
        if ([baseMsg.msgType isEqualToString:kDWDMsgTypeText]) {
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makePlainTextForO2M:(DWDTextChatMsg *)baseMsg];
        }else if ([baseMsg.msgType isEqualToString:kDWDMsgTypeImage]){
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeImageForO2M:(DWDImageChatMsg *)baseMsg];
        }else if ([baseMsg.msgType isEqualToString:kDWDMsgTypeAudio]){
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeAudioForO2M:(DWDAudioChatMsg *)baseMsg];
        }else if ([baseMsg.msgType isEqualToString:kDWDMsgTypeVideo]){
            relayData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeVideoForO2M:(DWDVideoChatMsg *)baseMsg];
        }
    }
    
    [[DWDChatClient sharedDWDChatClient] sendData:relayData];
    
    [self saveMessageToDBWithMessage:baseMsg];
    
    // 发送消息, 40s后判断超时时间
    // 缓存消息内容
    [[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict setObject:@{@"content" : [baseMsg yy_modelToJSONString], @"chatType" : @(baseMsg.chatType) , @"toUser" : baseMsg.toUser} forKey:baseMsg.msgId];
    
    DWDMessageTimerManager *timerManager = [DWDMessageTimerManager sharedMessageTimerManager];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:40 target:timerManager selector:@selector(judgeSendingError:) userInfo:@{@"msgId" : baseMsg.msgId , @"toId" : baseMsg.toUser , @"chatType" : @(baseMsg.chatType)} repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; // 加入主运行循环
    [timerManager.timerCachDict setObject:timer forKey:baseMsg.msgId];  // 缓存超时定时器
}

- (void)saveMessageToDBWithMessage:(DWDBaseChatMsg *)msg{
    // 存消息模型到本地
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        DWDLog(@"历史消息保存成功");
        NSNumber *friendId;
        if ([msg.fromUser isEqual:[DWDCustInfo shared].custId]) { // 自己发的
            friendId = msg.toUser;
        }else{  //  别人发的
            if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) {
                friendId = msg.toUser;
            }else{
                friendId = msg.fromUser;
            }
        }
        
        if (([msg.msgType isEqualToString:kDWDMsgTypeText] || [msg.msgType isEqualToString:kDWDMsgTypeAudio] || [msg.msgType isEqualToString:kDWDMsgTypeImage] || [msg.msgType isEqualToString:kDWDMsgTypeVideo]) && [msg.fromUser isEqual:[DWDCustInfo shared].custId]) {
            
            //插一个数据到会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:msg FriendCusId:friendId myCusId:[DWDCustInfo shared].custId success:^{
                
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                // 是否要发通知 ???
            } failure:^{
                
            }];
        }
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

/** 系统消息 私有处理 */
- (DWDNoteChatMsg *)dealWithNoteMsgByGroupId:(NSNumber *)groupId selectedArr:(NSArray *)selectedCustIdFlagArray
{
    DWDNoteChatMsg *noteChatMsg;
    //判断组数是否有成员 ???
    if(selectedCustIdFlagArray.count)
    {
        //插入消息 “你邀请了xxx加入了群组”
        //获取邀请群成员的昵称
        NSMutableArray *memberNames = [NSMutableArray array];
        for (int i = 0; i < self.contactsBySection.count; i++) {
            NSArray *a = self.contactsBySection[i];
            for (int j = 0; j < a.count; j++) {
                DWDContactModel *contact = a[j];
                if (contact.selected) {
                    [memberNames addObject:contact.nickname];
                }
            }
        }
        
        NSString *noteContent = [NSString stringWithFormat:@"你邀请%@加入了群组",[memberNames componentsJoinedByString:@"、"]];
        
        noteChatMsg = [self createNoteMsgWithString:noteContent toUserId:groupId chatType:DWDChatTypeGroup];
        //5.插入历史消息
        [self saveSystemMessage:noteChatMsg];
    }
    return noteChatMsg;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

/** 构造 系统消息 谁加入、移除班级 */
- (DWDNoteChatMsg *)createNoteMsgWithString:(NSString *)str toUserId:(NSNumber *)toUserId chatType:(DWDChatType)chatType{
    DWDNoteChatMsg *noteMsg = [[DWDNoteChatMsg alloc] init];
    noteMsg.noteString = str;
    noteMsg.fromUser = [DWDCustInfo shared].custId;
    noteMsg.toUser = toUserId;
    noteMsg.createTime = [NSNumber numberWithLongLong:([NSDate date].timeIntervalSince1970 * 1000)];
    noteMsg.msgType = kDWDMsgTypeNote;
    noteMsg.chatType = chatType;
    return noteMsg;
}
// 存消息模型到本地
- (void)saveSystemMessage:(DWDBaseChatMsg *)msg
{
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        
        //0. 发通知 ，刷新聊天控制器
//        NSDictionary *dict = @{@"msg":msg};
//        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationSystemMessageReload object:nil userInfo:dict];
        
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.contactsBySection.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = self.contactsBySection[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *ID = @"cell";
    DWDRelayOnChatChooseContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDRelayOnChatChooseContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    DWDContactModel *contact = self.contactsBySection[indexPath.section][indexPath.row];
    
    [cell.iconView sd_setImageWithURL:[NSURL URLWithString:contact.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    cell.nameLabel.text = contact.nickname;
    cell.multSelect = contact.selected;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DWDContactModel *model = self.contactsBySection[indexPath.section][indexPath.row];
    
    if (model.chatType == DWDChatTypeFace) {
        model.selected = !model.selected;
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        // 做转发
        DWDBaseChatMsg *baseMsg = [self handleRelayingMsgWithToUser:model.custId chatType:model.chatType createTime:[NSNumber numberWithLongLong:([NSDate date].timeIntervalSince1970 * 1000)]];
        
        [self relayMsgWithBaseMsg:baseMsg]; // 拼接data发送
        
        [DWDProgressHUD showText:@"转发成功!"];
        
        // 再发个通知 , 判断当前聊天界面是否要刷新即可
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatRelayJudgeCurrentTouser object:nil userInfo:@{@"msg" : baseMsg}];
        
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

/** 设置区头名 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitle[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    return self.sectionTitle;
    
}

/** 选择索引触发事件 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

/** 修改这里 设置分区高度、无数据的区设置为0 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0000001;
}

#pragma mark - <DWDRelayChooseMidViewDelegate>
- (void)tapMidView:(DWDRelayChooseMidView *)midView{
    if (midView.tag == 1) {  // 班级
        DWDRelayChooseClassController *classVc = [[DWDRelayChooseClassController alloc] init];
        [self.navigationController pushViewController:classVc animated:YES];
    }else if (midView.tag == 2){ // 群组
        DWDRelayChooseGroupController *groupVc = [[DWDRelayChooseGroupController alloc] init];
        [self.navigationController pushViewController:groupVc animated:YES];
    }
}

#pragma mark - <private>

- (void)setUpSubViews{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"搜索好友";
    searchBar.delegate = self;
    searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar = searchBar;
    [self.view addSubview:searchBar];
    
    DWDRelayChooseMidView *chooseClassView;
    if ([DWDCustInfo shared].isTeacher) {
        chooseClassView = [[DWDRelayChooseMidView alloc] init];
        chooseClassView.label.text = @"选择班级";
        chooseClassView.tag = 1;
        chooseClassView.delegate = self;
        [self.view addSubview:chooseClassView];
    }
    
    DWDRelayChooseMidView *chooseGroupView = [[DWDRelayChooseMidView alloc] init];
    chooseGroupView.label.text = @"选择群组";
    chooseGroupView.tag = 2;
    chooseGroupView.delegate = self;
    [self.view addSubview:chooseGroupView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 60;
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    tableView.sectionIndexColor = DWDColorMain;
    tableView.showsVerticalScrollIndicator = YES;
    
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.top.equalTo(self.view.top);
        make.height.equalTo(@50);
    }];
    
    if ([DWDCustInfo shared].isTeacher) {
        [chooseClassView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(searchBar.bottom);
            make.left.equalTo(self.view.left);
            make.right.equalTo(self.view.right);
            make.height.equalTo(@40);
        }];
    }
    
    [chooseGroupView makeConstraints:^(MASConstraintMaker *make) {
        
        if ([DWDCustInfo shared].isTeacher) {
            make.top.equalTo(chooseClassView.bottom).offset(1);
        }else{
            make.top.equalTo(searchBar.bottom);
        }
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@40);
    }];
    
    [tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(chooseGroupView.bottom);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
    }];
}

#pragma mark - <getter>

- (NSMutableArray *)contactsBySection{  // 把取出的联系人分成多个数组
    if (!_contactsBySection) {
        _contactsBySection = [self createSectionArrayWithArray:[[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId]];
        
    }
    return _contactsBySection;
}

- (NSMutableArray *)createSectionArrayWithArray:(NSArray *)contactArr{
    
    NSMutableArray *allArray = [NSMutableArray array];
    
    // test
    //        NSArray *hehe = @[@"张" , @"林" , @"来" ,@"招" , @"哦" , @"没" , @"中" , @"额" , @"饿" , @"啊" , @"锕" , @"吖" , @"把" , @"不", @"别" , @"过" , @"都"];
    //        NSMutableArray *yaya = [NSMutableArray array];
    //        for (int i = 0; i < hehe.count; i++) {
    //            DWDContactModel *contact = [[DWDContactModel alloc] init];
    //            contact.nickname = hehe[i];
    //            [yaya addObject:contact];
    //        }
    //        NSArray *contactsArr = yaya;
    // test
    
    //英文和中文、是27区。  “A、B、C.....#" 26字母加#号、27区
    NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    
    //初始化一个数据、空间大小27组
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    for (int i = 0; i < contactArr.count; i++) {  // 遍历所有联系人
        DWDContactModel *contact = contactArr[i];
        //判断是否有备注，无则用nickname;
        NSString *str =  [[[DWDPersonDataBiz alloc] init] checkoutExistRemarkName:contact.remarkName nickname:contact.nickname];
        //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:str collationStringSelector:@selector(uppercaseString)];
        //加入newSectionsArray中
        
        NSMutableArray *sectionSingleArray = newSectionsArray[sectionNumber];
        [sectionSingleArray addObject:contact];
    }
    
    _sectionTitle = [NSMutableArray array];
    for (int i = 0; i < newSectionsArray.count; i++) {
        NSArray *arr = newSectionsArray[i];
        if (arr.count > 0) {
            [allArray addObject:arr];
            [_sectionTitle addObject:[[UILocalizedIndexedCollation currentCollation] sectionTitles][i]];
        }
    }
    
    return allArray;
}

- (DWDBaseChatMsg *)handleRelayingMsgWithToUser:(NSNumber *)toUser chatType:(DWDChatType)chatType createTime:(NSNumber *)createTime{
    
    DWDBaseChatMsg *base = [DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
    
    DWDBaseChatMsg *needRelayMsg;
    
    if ([base.msgType isEqualToString:kDWDMsgTypeText]) {
        
        DWDTextChatMsg *textMsg = (DWDTextChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDTextChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] createTextMsgWithText:textMsg.content from:[DWDCustInfo shared].custId to:toUser chatType:chatType];
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeAudio]){
        
        DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDAudioChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatAudioMsgFrom:[DWDCustInfo shared].custId to:toUser duration:audioMsg.duration observe:nil mp3FileName:audioMsg.fileName chatType:chatType];
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeImage]){
        
        DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDImageChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatImageMsgFrom:[DWDCustInfo shared].custId to:toUser observe:nil chatType:chatType];
        relayMsg.fileName = imageMsg.fileName;
        relayMsg.fileKey = imageMsg.fileKey;
        relayMsg.photo = imageMsg.photo;
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeVideo]){
        
        DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDVideoChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatVideoMsgFrom:[DWDCustInfo shared].custId to:toUser observe:nil mp4FileName:videoMsg.fileName chatType:chatType];
        relayMsg.thumbFileKey = videoMsg.thumbFileKey;
        relayMsg.fromType = videoMsg.fromType;
        relayMsg.fileKey = videoMsg.fileKey;
        
        needRelayMsg = relayMsg;
        
    }
    
    return needRelayMsg;
}
@end
