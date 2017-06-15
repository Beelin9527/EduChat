//
//  DWDRelayChooseGroupController.m
//  EduChat
//
//  Created by Superman on 16/9/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRelayChooseGroupController.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDRelayOnChatRentCell.h"
#import "DWDGroupEntity.h"

#import "DWDBaseChatMsg.h"
#import "DWDChatMsgDataClient.h"
#import "DWDChatMsgClient.h"
#import "DWDChatClient.h"
#import "DWDMessageTimerManager.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import <YYModel.h>

@interface DWDRelayChooseGroupController ()
@property (nonatomic , strong) NSArray *chooseGroups;
@property (nonatomic , strong) DWDGroupEntity *selectedModel;

@end

@implementation DWDRelayChooseGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择群组";
    
    self.chooseGroups = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupList:[DWDCustInfo shared].custId];
    // test
//    NSArray *hehe = @[@"张" , @"林" , @"来" ,@"招" , @"哦" , @"没" , @"中" , @"额" , @"饿" , @"啊" , @"锕" , @"吖" , @"把" , @"不", @"别" , @"过" , @"都"];
//    NSMutableArray *yaya = [NSMutableArray array];
//    for (int i = 0; i < hehe.count; i++) {
//        DWDGroupEntity *contact = [[DWDGroupEntity alloc] init];
//        contact.groupName = hehe[i];
//        [yaya addObject:contact];
//    }
//    self.chooseGroups = yaya;
    // test
    
    self.tableView.rowHeight = 60;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chooseGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    DWDRelayOnChatRentCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDRelayOnChatRentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    DWDGroupEntity *model = self.chooseGroups[indexPath.row];
    [cell.iconView sd_setImageWithURL:[NSURL URLWithString:model.photoKey] placeholderImage:DWDDefault_GroupImage];
    NSString *name = [model.groupName stringByAppendingString:[NSString stringWithFormat:@"(%zd人)",[model.memberCount integerValue]]];
    cell.nameLabel.text = name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedModel = self.chooseGroups[indexPath.row];
    NSString *string = [NSString stringWithFormat:@"发送给%@?",_selectedModel.groupName];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:string delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertViewCancel:(UIAlertView *)alertView{
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // 点击确定 , 转发
        
        DWDBaseChatMsg *baseMsg = [self handleRelayingMsg];
        
        [self relayMsgWithBaseMsg:baseMsg]; // 拼接data发送
        
        [DWDProgressHUD showText:@"转发成功!"];
        
        // 再发个通知 , 判断当前聊天界面是否要刷新即可
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatRelayJudgeCurrentTouser object:nil userInfo:@{@"msg" : baseMsg}];
    }
}

- (DWDBaseChatMsg *)handleRelayingMsg{
    
    DWDBaseChatMsg *base = [DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
    
    DWDBaseChatMsg *needRelayMsg;
    
    if ([base.msgType isEqualToString:kDWDMsgTypeText]) {
        
        DWDTextChatMsg *textMsg = (DWDTextChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDTextChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] createTextMsgWithText:textMsg.content from:[DWDCustInfo shared].custId to:self.selectedModel.groupId chatType:DWDChatTypeGroup];
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeAudio]){
        
        DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDAudioChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatAudioMsgFrom:[DWDCustInfo shared].custId to:self.selectedModel.groupId duration:audioMsg.duration observe:nil mp3FileName:audioMsg.fileName chatType:DWDChatTypeGroup];
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeImage]){
        
        DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDImageChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatImageMsgFrom:[DWDCustInfo shared].custId to:self.selectedModel.groupId observe:nil chatType:DWDChatTypeGroup];
        relayMsg.fileName = imageMsg.fileName;
        relayMsg.fileKey = imageMsg.fileKey;
        relayMsg.photo = imageMsg.photo;
        
        needRelayMsg = relayMsg;
        
    }else if ([base.msgType isEqualToString:kDWDMsgTypeVideo]){
        
        DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)[DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg;
        DWDVideoChatMsg *relayMsg = [[[DWDChatMsgClient alloc] init] creatVideoMsgFrom:[DWDCustInfo shared].custId to:self.selectedModel.groupId observe:nil mp4FileName:videoMsg.fileName chatType:DWDChatTypeGroup];
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
@end
