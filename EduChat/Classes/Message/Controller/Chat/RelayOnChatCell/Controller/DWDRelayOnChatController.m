//
//  DWDRelayOnChatController.m
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRelayOnChatController.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"

#import "DWDRecentChatModel.h"

#import "DWDContactModel.h"
#import "DWDClassModel.h"
#import "DWDGroupEntity.h"

#import "DWDRelayOnChatRentCell.h"

#import "DWDChooseConatctController.h"

#import "DWDBaseChatMsg.h"
#import "DWDTextChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDAudioChatMsg.h"
#import "DWDVideoChatMsg.h"


#import "DWDChatMsgDataClient.h"
#import "DWDChatMsgClient.h"
#import "DWDChatClient.h"

#import "DWDMessageTimerManager.h"

#import <YYModel.h>
@interface DWDRelayOnChatController () <UISearchBarDelegate , UIAlertViewDelegate , UISearchBarDelegate>
@property (nonatomic , strong) NSMutableArray *recentChatList;
@property (nonatomic , strong) DWDRecentChatModel *selectedModel;
@property (nonatomic , weak) UISearchBar *searchBar;

@end

@implementation DWDRelayOnChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发送给";
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.bounds = CGRectMake(0, 0, 0, 50);
    searchBar.delegate = self;
    searchBar.placeholder = @"搜索好友\\群组\\班级";
    searchBar.delegate = self;
    _searchBar = searchBar;
    self.tableView.tableHeaderView = searchBar;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 60;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick:)];
    
    [self fetchRecentChatList];
    
}

- (void)fetchRecentChatList{
    self.recentChatList = [[NSArray yy_modelArrayWithClass:[DWDRecentChatModel class] json:[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getRecentChatListByIdForRelayOnChat:[DWDCustInfo shared].custId]] mutableCopy];
    
    NSMutableArray *chatTypeClassArray = [NSMutableArray array];
    for (int i = 0; i < self.recentChatList.count; i++) {
        DWDRecentChatModel *recentChat = self.recentChatList[i];
        if (![DWDCustInfo shared].isTeacher && recentChat.chatType == DWDChatTypeClass) {
            [chatTypeClassArray addObject:recentChat];
        }
    }
    
    [self.recentChatList removeObjectsInArray:chatTypeClassArray];
}

- (void)rightBarBtnClick:(UIBarButtonItem *)btn{
    DWDLog(@"123123");
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return self.recentChatList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"创建新的聊天";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        DWDRecentChatModel *recentChat = self.recentChatList[indexPath.row];
        static NSString *ID = @"cell";
        DWDRelayOnChatRentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDRelayOnChatRentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        UIImage *placeHolder;
        if (recentChat.chatType == DWDChatTypeFace) {
            placeHolder = DWDDefault_MeBoyImage;
        }else if (recentChat.chatType == DWDChatTypeClass){
            placeHolder = DWDDefault_GradeImage;
        }else if (recentChat.chatType == DWDChatTypeGroup){
            placeHolder = DWDDefault_GroupImage;
        }
        
        [cell.iconView sd_setImageWithURL:[NSURL URLWithString:recentChat.photoKey] placeholderImage:placeHolder];
        cell.nameLabel.text = recentChat.nickname;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UILabel *label = [UILabel new];
        label.text = @"   最近聊天";
        label.backgroundColor = DWDColorBackgroud;
        label.textColor = DWDRGBColor(140, 140, 140);
        label.textAlignment = NSTextAlignmentLeft;
        label.font = DWDFontContent;
        label.frame = CGRectMake(10, 0, DWDScreenW, 40);
        return label;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 30;
    }else{
        return 0;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        // Push
        DWDChooseConatctController *chooseContactVc = [[DWDChooseConatctController alloc] init];
        chooseContactVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chooseContactVc animated:YES];
    }else{
        _selectedModel = self.recentChatList[indexPath.row];
        // 直接发送
        NSString *string = [NSString stringWithFormat:@"发送给%@?",_selectedModel.nickname];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:string delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertViewCancel:(UIAlertView *)alertView{ // 被电话打断
    DWDLog(@"123123123123123");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // 点击确定 , 转发
        DWDBaseChatMsg *baseMsg = [self handleRelayingMsg];
        
        [self relayMsgWithBaseMsg:baseMsg]; // 拼接data发送
        
        [DWDProgressHUD showText:@"转发成功!"];
        
        // 再发个通知 , 判断当前聊天界面是否要刷新即可
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatRelayJudgeCurrentTouser object:nil userInfo:@{@"msg" : baseMsg}];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil]; // 转发成功返回到聊天VC
    }
}

- (DWDBaseChatMsg *)handleRelayingMsg{
    
    DWDBaseChatMsg *base = [DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
    
    DWDBaseChatMsg *needRelayMsg;
    
    if ([base.msgType isEqualToString:kDWDMsgTypeText]) {
        
        DWDTextChatMsg *textMsg = (DWDTextChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDTextChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] createTextMsgWithText:textMsg.content from:[DWDCustInfo shared].custId to:self.selectedModel.custId chatType:self.selectedModel.chatType];
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeAudio]){
        
        DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDAudioChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatAudioMsgFrom:[DWDCustInfo shared].custId to:self.selectedModel.custId duration:audioMsg.duration observe:nil mp3FileName:audioMsg.fileName chatType:self.selectedModel.chatType];
        
        needRelayMsg = relayMsg;
    
    }else if ([base.msgType isEqualToString:kDWDMsgTypeImage]){
        
        DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDImageChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatImageMsgFrom:[DWDCustInfo shared].custId to:self.selectedModel.custId observe:nil chatType:self.selectedModel.chatType];
        relayMsg.fileName = imageMsg.fileName;
        relayMsg.fileKey = imageMsg.fileKey;
        relayMsg.photo = imageMsg.photo;
        
        needRelayMsg = relayMsg;
    
    }else if ([base.msgType isEqualToString:kDWDMsgTypeVideo]){
        
        DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDVideoChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatVideoMsgFrom:[DWDCustInfo shared].custId to:self.selectedModel.custId observe:nil mp4FileName:videoMsg.fileName chatType:self.selectedModel.chatType];
        relayMsg.thumbFileKey = videoMsg.thumbFileKey;
        relayMsg.fromType = videoMsg.fromType;
        relayMsg.fileKey = videoMsg.fileKey;
        
        needRelayMsg = relayMsg;
        
    }
    
    return needRelayMsg;
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

#pragma mark - <UISearchBarDelagte>

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length == 0) {
        [self fetchRecentChatList];
        [self.tableView reloadData];
        return;
    }
    
    NSMutableArray *allContacts = [NSMutableArray array];
    
    NSArray *arr1 = [[DWDContactsDatabaseTool sharedContactsClient] getContactsById:[DWDCustInfo shared].custId];
    [allContacts addObjectsFromArray:arr1];
    
    if ([DWDCustInfo shared].isTeacher) {
        NSArray *arr2 = [[DWDClassDataBaseTool sharedClassDataBase] getClassList:[DWDCustInfo shared].custId];
        [allContacts addObjectsFromArray:arr2];
    }
    
    NSArray *arr3 = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupList:[DWDCustInfo shared].custId];
    [allContacts addObjectsFromArray:arr3];
    
    
    NSMutableArray *resultArr = [NSMutableArray array];
    
    for (int i = 0; i < allContacts.count; i++) {
        NSObject *obj = allContacts[i];
        
        DWDRecentChatModel *recent = [DWDRecentChatModel new];
        
        if ([obj isKindOfClass:[DWDContactModel class]]) {
            DWDContactModel *contact = (DWDContactModel *)obj;
            if ([contact.nickname containsString:searchText]) {
                
                recent.myCustId = [DWDCustInfo shared].custId;
                recent.custId = contact.custId;
                recent.chatType = DWDChatTypeFace;
                recent.nickname = contact.nickname;
                recent.photoKey = contact.photoKey;
                recent.remarkName = contact.remarkName;
                
                [resultArr addObject:recent];
            }
        }else if ([obj isKindOfClass:[DWDClassModel class]]){
            DWDClassModel *aClass = (DWDClassModel *)obj;
            
            if ([aClass.className containsString:searchText]) {
                recent.myCustId = [DWDCustInfo shared].custId;
                recent.custId = aClass.classId;
                recent.chatType = DWDChatTypeClass;
                recent.nickname = aClass.className;
                recent.photoKey = aClass.photoKey;
                
                [resultArr addObject:recent];
            }
            
        }else if ([obj isKindOfClass:[DWDGroupEntity class]]){
            DWDGroupEntity *group = (DWDGroupEntity *)obj;
            if ([group.groupName containsString:searchText]) {
                recent.myCustId = [DWDCustInfo shared].custId;
                recent.custId = group.groupId;
                recent.chatType = DWDChatTypeGroup;
                recent.nickname = group.groupName;
                recent.photoKey = group.photoKey;
                [resultArr addObject:recent];
            }
        }
        
    }
    
    self.recentChatList = resultArr;
    [self.tableView reloadData];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}
@end
