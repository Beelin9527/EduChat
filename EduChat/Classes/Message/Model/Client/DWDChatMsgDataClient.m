//
//  DWDChatMsgMaker.m
//  EduChat
//
//  Created by apple on 1/5/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <YYModel/YYModel.h>
#import "DWDChatMsgDataClient.h"
#import "DWDChatClient.h"

#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDFriendApplyDataBaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDSchoolDataBaseTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"

#import "DWDTabbarViewController.h"
#import "DWDChatController.h"

#import "DWDChatMsgReceipt.h"
#import "DWDOfflineMsg.h"
#import "DWDUnreadLastMsgReceipt.h"
#import "DWDSysMsg.h"
#import "DWDNoteChatMsg.h"
#import "DWDTimeChatMsg.h"

#import "DWDPickUpCenterDataBaseModel.h"
#import "DWDIntelligentMessageModel.h"

#import "DWDPickUpCenterJsonDataModel.h"
#import "DWDGroupDataBaseTool.h"

#import "NSString+extend.h"
#import "CustLoginBean.pbobjc.h"
#import "UndoMessageBean.pbobjc.h"


@interface DWDChatMsgDataClient ()

@property (nonatomic, strong) NSTimer *disconnectTimer;
@property (nonatomic, strong) NSTimer *heartTimer;

@end

@implementation DWDChatMsgDataClient

static id client;

+ (instancetype)sharedChatMsgDataClient{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
    });
    
    return client;
}

#pragma mark public methods <Maker>

// 一对一   一对多  文本
- (NSData *)makePlainTextForO2O:(DWDTextChatMsg *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypePlainTextO2OUpload];
}

- (NSData *)makePlainTextForO2M:(DWDTextChatMsg *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypePlainTextO2MUpload];
}

// 语音
- (NSData *)makeAudioForO2O:(DWDAudioChatMsg *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeMediaO2OUpload];
}


- (NSData *)makeAudioForO2M:(DWDAudioChatMsg *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeMediaO2MUpload];
}

//视频
- (NSData *)makeVideoForO2O:(DWDVideoChatMsg *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeMediaO2OUpload];
}


- (NSData *)makeVideoForO2M:(DWDVideoChatMsg *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeMediaO2MUpload];
}

// 图片
- (NSData *)makeImageForO2O:(DWDImageChatMsg *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeMediaO2OUpload];
}

- (NSData *)makeImageForO2M:(DWDImageChatMsg *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeMediaO2MUpload];
}

// JPUSH 进入后台
- (NSData *)makeJPSHUObject:(DWDJPSHEnterBackgroundModel *)msgObj {
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeJPUSHEnterBackground];
}

/**************给后台临时的回执*******/
// 给后台回执  o2o 文本
- (NSData *)makeO2OTextReceiptToServer:(DWDMsgReceiptToServer *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeTextO2OReceiptToServer];  // 改类型  加枚举??
}

// 给后台回执  o2M 文本
- (NSData *)makeO2MTextReceiptToServer:(DWDMsgReceiptToServer *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeTextO2MReceiptToServer];  // 改类型  加枚举??
}

// 给后台回执  o2o 文件
- (NSData *)makeO2OFileReceiptToServer:(DWDMsgReceiptToServer *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeFileO2OReceiptToServer];  // 改类型  加枚举??
}

// 给后台回执  o2m 文件
- (NSData *)makeO2MFileReceiptToServer:(DWDMsgReceiptToServer *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeFileO2MReceiptToServer];  // 改类型  加枚举??
}

- (NSData *)makeSysMsgReceiptToServer:(NSDictionary *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDMsgTypeSysMsgReceiptToServer];
}

- (NSData *)makeHeartReceiptToServer:(NSDictionary *)msgObj{
    return [self innerMakeMsgDataFor:msgObj byType:DWDReceiptServerToApp];
}

// 拼接登录消息包
- (NSData *)makeMsgClientLoginData:(NSString *)userName pwd:(NSString *)pwd {  // protoc
    NSMutableData *result = [NSMutableData data];
    
    CustLogin *login = [[CustLogin alloc] init];
    login.devinfos = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    login.userName = userName;
    login.pwd = pwd;
    login.platform = @"ios";
    login.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [self appendMsgStartToData:result];
    [self appendMsgTypeToData:result byType:DWDMsgTypeClientLogin];
//    [self appendMsgData:[NSString stringWithFormat:@"{\"userName\":\"%@\", \"pwd\":\"%@\",\"devinfos\":\"%@\"}", userName, pwd,[[[UIDevice currentDevice] identifierForVendor] UUIDString]]
//                 toData:result];
    [self appendProtobufModelToData:login toData:result];
    [self appendMsgCheckMarkToData:result];
    [self appendMsgEndToData:result];
    
    return result;
}

- (NSData *)makeMsgClientLogoutData:(NSNumber *)custId
{
    NSMutableData *result = [NSMutableData data];
    
    [self appendMsgStartToData:result];
    [self appendMsgTypeToData:result byType:DWDMsgTypeClientLoginout];
    [self appendMsgData:[NSString stringWithFormat:@"{\"custId\":\"%@\"}", custId] toData:result];
    [self appendMsgCheckMarkToData:result];
    [self appendMsgEndToData:result];
    
    return result;

}
- (NSData *)makeOfflineFetchData {
    NSMutableData *result = [NSMutableData data];
    
    [self appendMsgStartToData:result];
    [self appendMsgTypeToData:result byType:DWDMsgTypeVirginUpload];
    const Byte kDWDChatDataLenBytes[] = {0x00, 0x00};
    [result appendBytes:kDWDChatDataLenBytes length:2];
    [self appendMsgCheckMarkToData:result];
    [self appendMsgEndToData:result];
    
    return result;
}

- (void)resetTimer {
//    static NSDateFormatter *datefor;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        datefor = [NSDateFormatter new];
//        datefor.locale = [NSLocale currentLocale];
//        datefor.dateFormat = @"HH:mm:ss";
//    });
//    DWDLog(@"resetTimerWithDate:%@", [datefor stringFromDate:_heartTimer.fireDate]);
    [_heartTimer invalidate];
    _heartTimer = nil;
    [_disconnectTimer invalidate];
    _disconnectTimer = nil;
    [self startTimer];
}

- (void)startTimer {
//    DWDLog(@"startTimer");
    _heartTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(sendHeart) userInfo:nil repeats:YES];
    _disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:50.0f target:self selector:@selector(disConnect) userInfo:nil repeats:YES];
}

- (void)disConnect {
    DWDLog(@"disconnect");
    [[DWDChatClient sharedDWDChatClient] disConnect];
}

- (void)sendHeart {
    DWDLog(@"sendHeartData");
    //                  包头      通道         长度        验证   包尾
    Byte _heart[] = {0x40, 0x40, 0x90, 0x00, 0x00, 0x00, 0x00, 0x24, 0x24};
    NSData *data = [NSData dataWithBytes:_heart length:9];
    if ([[DWDChatClient sharedDWDChatClient] isConnecting]) {
        [[DWDChatClient sharedDWDChatClient] sendData:data];
    }
}

#pragma mark public methods <Parser>
// 解析消息数据
- (void)parseChatMsgFromDataAndPostSomeNotification:(NSData *)data {
    DWDLog(@"\nreceivedData:%@", data);
    [self resetTimer];
   
    //通道
    unsigned char bytes[data.length];
    unsigned long len = data.length;
    DWDMsgType type;
    if (data.length > 3) {

        [data getBytes:bytes range:NSMakeRange(0, len)];
        unsigned char typeBytes[] = {bytes[2], bytes[3]};
        type = [self parseChatMsgDataType:typeBytes];
        if (type == DWDReceiveHeart) {
            Byte reply[] = {0x40, 0x40, 0x90, 0x09, 0x00, 0x00, 0x00, 0x24, 0x24};
            NSData *replyData = [NSData dataWithBytes:reply length:9];
            //        DWDLog(@"heart Receive:%@", data);
            //        DWDLog(@"heart ReplyData:%@", replyData);
            [[DWDChatClient sharedDWDChatClient] sendData:replyData];
            return;
        } else if (type == DWDReceiveHeartReplyReceived) {
            //        DWDLog(@"heart send reply received");
        }
    } else return;
    
    NSString *postNotificationName;
    NSMutableDictionary *postUserInfo = [NSMutableDictionary dictionary];
    
    NSNumber *friendId;
    if ([self isLegalMsg:bytes len:len]) {  // 判断是否合法
        
        NSString *jsonMsg = [self parseMsgBody:data];  // 解析消息体
        
        DWDLogFunc;
        DWDLog(@"parseChatMsgFromData msg body is  : %@",jsonMsg);
//        unsigned char typeBytes[] = {bytes[2], bytes[3]};
        unsigned char typeBytes[] = {bytes[2], bytes[3]};
        type = [self parseChatMsgDataType:typeBytes];
        DWDMsgType type = [self parseChatMsgDataType:typeBytes];  // 解析消息类型
        
        switch (type) {
                
            // handle message receipt (回执)
            case DWDMsgTypePlainTextO2OUpload:
            case DWDMsgTypePlainTextO2MUpload:
            case DWDMsgTypeMediaO2OUpload:
            case DWDMsgTypeMediaO2MUpload: {
                
                DWDChatMsgReceipt *result;
                result = [DWDChatMsgReceipt yy_modelWithJSON:jsonMsg];
                
                postNotificationName = DWDReceiveNewChatMsgReceiptNotification;
                
                [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                
                [self updateMsgDatabaseSendingStateWithReceipt:result];  // 根据回执更新数据库中这条消息的发送状态
                
                break;
            }
                
            // receive plain text message   1对1文本消息
            case DWDMsgTypePlainTextO2ODownload: {
                
                DWDTextChatMsg *result;
                result = [DWDTextChatMsg yy_modelWithJSON:jsonMsg];
                
                friendId = result.fromUser;
                
                postNotificationName = DWDReceiveNewChatMsgNotification;
                
                [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                
                break;
                
            }
             
            // receive media message   1对1 多媒体消息
            case DWDMsgTypeMediaO2ODownload: {
                
                DWDBaseChatMsg *result = [self conventToSpecificSubclass:[DWDBaseChatMsg yy_modelWithJSON:jsonMsg] jsonSource:jsonMsg];
                
                friendId = result.fromUser;
                
                postNotificationName = DWDReceiveNewChatMsgNotification;
                
                [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                
                break;
                
            }
            case DWDMsgTypePlainTextO2MDownload: {  // 1 to m down text
                
                DWDTextChatMsg *result = [DWDTextChatMsg yy_modelWithJSON:jsonMsg];//[self conventToSpecificSubclass:[DWDBaseChatMsg yy_modelWithJSON:jsonMsg] jsonSource:jsonMsg];
                
                friendId = result.toUser;
                
                postNotificationName = DWDReceiveNewChatMsgNotification;
                
                [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                
                break;
                
            }
            case DWDMsgTypeMediaO2MDownload: {  // 1 to m down  media
                
                DWDBaseChatMsg *result = [self conventToSpecificSubclass:[DWDBaseChatMsg yy_modelWithJSON:jsonMsg] jsonSource:jsonMsg];
                
                friendId = result.toUser;
                
                postNotificationName = DWDReceiveNewChatMsgNotification;
                
                [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                
                break;
                
            }
                
                
            case DWDMsgTypeClientLogin: {  // 登录
                
                DWDChatMsgReceipt *result;
                result = [DWDChatMsgReceipt yy_modelWithJSON:jsonMsg];
                
                postNotificationName = DWDReceiveLoginReceiptNotification;
                
                [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                
                break;
            }
                
            case DWDMsgTypeRevoke: {  // 有消息被撤回/删除 (在线)
                
                DWDLog(@"有消息被撤回");
                
                NSData *resultData = [self parseProtocBufMsgBody:data];
                
                NSError *error;
                
                UndoMessage *undoMsg = [[UndoMessage alloc] initWithData:resultData error:&error];
                
                DWDLog(@"%@ , 被撤回/删除的消息是" , undoMsg);
                
                // 给后台系统消息回执
                [[DWDChatClient sharedDWDChatClient] sendData:[self makeSysMsgReceiptToServer:@{@"code" : @"sysmsgUndoMessage" , @"uuid" : undoMsg.uuid}]];
                
                // 被撤回/删除的消息
                DWDBaseChatMsg *revokedMsg = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchMessageWithToId:[NSNumber numberWithLongLong:undoMsg.tid] MsgId:undoMsg.msgId chatType:undoMsg.chatType];
                
                // 数据库中的最后一条消息
                DWDBaseChatMsg *lastMsgInDB = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchLastMsgWithToUser:[NSNumber numberWithLongLong:undoMsg.tid] chatType:undoMsg.chatType];
                
                if (undoMsg.type == 1) { // 班主任删除消息
                    if (undoMsg.isRead) { // 被删除的是已读 本地有数据
                        
                        // 删除数据库中这条消息 , 逻辑删除
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageWithFriendId:[NSNumber numberWithLongLong:undoMsg.tid] msgs:@[revokedMsg] chatType:undoMsg.chatType success:^{
                            
                            // 发通知删除聊天界面上的这条消息 , 只做界面操作 , 数据库已删除
                            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationClassManagerDeleteMsg object:nil userInfo:@{@"deletedMsg" : revokedMsg}];
                            
                        } failure:^(NSError *error) {
                            
                        }];
                        
                        if ([revokedMsg.msgId isEqualToString:lastMsgInDB.msgId]) {  // 如果被删除的消息 是最后一条消息
                            // 取出前一条 刷新lastContent
                            DWDBaseChatMsg *backForwardMsg = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchChatMsgWithMsg:revokedMsg toUser:[NSNumber numberWithLongLong:undoMsg.tid] chatType:undoMsg.chatType];

                            
                            if (backForwardMsg == nil) { // 删除的是所有的第一条 也是最后一条
                                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : @"" , @"type" : @1 , @"isAllMsgDeleted" : @1 , @"tid" : [NSNumber numberWithLongLong:undoMsg.tid]}];
                            }else{
                                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : backForwardMsg , @"type" : @1 , @"isAllMsgDeleted" : @0 , @"tid" : [NSNumber numberWithLongLong:undoMsg.tid]}];
                            }
                            
                            
                        }
                    }else{ // 被删除的是未读 本地没有数据
                        // 判断红点是否大于 0 如果是需要-1 然后发通知刷新recentchat界面 gggggggg
                        // 判断被删除的消息 是有推 还是没推 ??
                    }
                    
                }else{ // 消息被撤回
                    if (undoMsg.isRead) { // 被撤回的消息是已读消息
                        // 1. 修改这条被撤回的消息为note类型
                        NSString *name = revokedMsg.remarkName.length > 0 ? revokedMsg.remarkName : revokedMsg.nickname;
                        NSString *noteString = [NSString stringWithFormat:@"%@撤回了一条消息", name];
                        
                        // 如果被撤回的消息 是最后一条消息
                        if ([revokedMsg.msgId isEqualToString:lastMsgInDB.msgId]) {
                            // 通知最近联系人界面 , 刷新lastConetent
                            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : noteString , @"type" : @2 , @"isAllMsgDeleted" : @0 , @"tid" : [NSNumber numberWithLongLong:undoMsg.tid]}];
                        }
                        
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] revokeMsgWithNoteString:noteString revokedMsgId:revokedMsg.msgId friendId:[NSNumber numberWithLongLong:undoMsg.tid] chatType:undoMsg.chatType success:^{
                            
                            DWDLog(@"被撤回的消息 数据库操作完毕 发通知刷新聊天界面");
                            
                            if (revokedMsg.chatType == DWDChatTypeClass) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationHaveMsgRevoked object:nil userInfo:@{@"revokeMsg" : revokedMsg, @"revokeNote" : noteString}];
                            }
                            
                            
                            if (revokedMsg.chatType == DWDChatTypeGroup) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationHaveMsgRevoked object:nil userInfo:@{@"revokeMsg" : revokedMsg, @"revokeNote" : noteString}];
                            }
                            
                            if (revokedMsg.chatType == DWDChatTypeFace) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationHaveMsgRevoked object:nil userInfo:@{@"revokeMsg" : revokedMsg, @"revokeNote" : noteString}];
                            }
                            
                            
                        } failure:^(NSError *error) {
                            
                        }];
                    }else{ // 被撤回的消息是未读消息
                        // 2. 构建一条被撤回的提示
                        DWDNoteChatMsg *revokeNote = [DWDNoteChatMsg new];
                        revokeNote.msgType = kDWDMsgTypeNote;
                        revokeNote.fromUser = [DWDCustInfo shared].custId; // 全部构造为自己发的
                        revokeNote.toUser = [NSNumber numberWithLongLong:undoMsg.tid];
                        revokeNote.createTime = [NSNumber numberWithLongLong:undoMsg.createTime];
                        revokeNote.msgId = undoMsg.msgId;
                        revokeNote.chatType = undoMsg.chatType;
                        NSString *name = undoMsg.name;
                        revokeNote.noteString = [NSString stringWithFormat:@"%@撤回了一条消息", name];
                        
                        // 后台在推离线消息时  如果被撤回的未读 是最后一条 则发上一条未读作为最后一条 如果不是最后一条, 则未读数不需要改
                        // 先收系统消息 后收离线消息推送 所以不用发通知刷界面
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:revokeNote success:^{
                            
                        } failure:^(NSError *error) {
                            
                        }];
                    }
                    
                }
                
                break;
            }
                
            case DWDMsgTypeVirginDownload: {  // 类型是收到的离线聊天消息  含最后一条离线消息  和消息总数
                
                NSMutableArray *array = [NSMutableArray array];
                NSArray *arr = nil;
                NSData *jsonData = [(NSString *)jsonMsg dataUsingEncoding : NSUTF8StringEncoding];
                if (jsonData) {
                    arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
                    if (![arr isKindOfClass:[NSArray class]]) arr = nil;
                }
                
                NSMutableArray *unreadReceiptArr = [NSMutableArray array];
                for (int i = 0; i < arr.count; i++) {
                    NSDictionary *base = arr[i];
                    NSNumber *chatTypeNum = arr[i][@"lastMsg"][@"chatType"];
                    NSNumber *friendId;
                    if ([chatTypeNum integerValue] == DWDChatTypeClass || [chatTypeNum integerValue] == DWDChatTypeGroup) {
                        friendId = arr[i][@"lastMsg"][@"toUser"];
                    }else{
                        friendId = arr[i][@"lastMsg"][@"fromUser"];
                    }
                    
                    NSDictionary *paramsDict = @{@"custId" : [DWDCustInfo shared].custId,
                                                 @"friendCustId" : friendId,
                                                 @"chatType" : arr[i][@"lastMsg"][@"chatType"],
                                                 @"msgId" : arr[i][@"lastMsg"][@"msgId"]};
                    
                    [unreadReceiptArr addObject:paramsDict];
                    
                    NSNumber *unreadCount = base[@"friendAcctMsg"][@"msgNum"];
                    
                    if ([base[@"lastMsg"][@"msgType"] isEqualToString:kDWDMsgTypeText]) {
                        
                        DWDTextChatMsg *textMsg = [DWDTextChatMsg yy_modelWithDictionary:arr[i][@"lastMsg"]];
                        textMsg.badgeCount = unreadCount;
                        textMsg.unreadMsgCount = base[@"friendAcctMsg"][@"msgNum"];
                        textMsg.state = DWDChatMsgStateSended;
                        
                        [self findoutRecentChatAndUpdateRecentChatListWithOfflineMsg:textMsg];
                        
                        [array addObject:textMsg];
                        
                    }else if ([base[@"lastMsg"][@"msgType"] isEqualToString:kDWDMsgTypeAudio]){
                        
                        DWDAudioChatMsg *audioMsg = [DWDAudioChatMsg yy_modelWithDictionary:arr[i][@"lastMsg"]];
                        audioMsg.badgeCount = unreadCount;
                        audioMsg.unreadMsgCount = base[@"friendAcctMsg"][@"msgNum"];
                        audioMsg.state = DWDChatMsgStateSended;
                        audioMsg.read = NO;
                        
                        if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:audioMsg.fileKey]) {  // 文件不存在 下载
                            [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:audioMsg.fileKey compltionBlock:^{
                                DWDLog(@"离线消息的最后一条 是语音消息 下载成功");
                                
                            }];
                        }
                        
                        [self findoutRecentChatAndUpdateRecentChatListWithOfflineMsg:audioMsg];
                        
                        [array addObject:audioMsg];
                        
                    }else if ([base[@"lastMsg"][@"msgType"] isEqualToString:kDWDMsgTypeImage]){
                        
                        DWDImageChatMsg *imageMsg = [DWDImageChatMsg yy_modelWithDictionary:arr[i][@"lastMsg"]];
                        imageMsg.badgeCount = unreadCount;
                        imageMsg.unreadMsgCount = base[@"friendAcctMsg"][@"msgNum"];
                        imageMsg.state = DWDChatMsgStateSended;
                        
                        [self findoutRecentChatAndUpdateRecentChatListWithOfflineMsg:imageMsg];
                        
                        [array addObject:imageMsg];
                        
                    }
                    else if ([base[@"lastMsg"][@"msgType"] isEqualToString:kDWDMsgTypeVideo]){ //视频
                        
                        DWDVideoChatMsg *videoMsg = [DWDVideoChatMsg yy_modelWithDictionary:arr[i][@"lastMsg"]];
                        videoMsg.badgeCount = unreadCount;
                        videoMsg.unreadMsgCount = base[@"friendAcctMsg"][@"msgNum"];
                        videoMsg.state = DWDChatMsgStateSended;
                        
                        [self findoutRecentChatAndUpdateRecentChatListWithOfflineMsg:videoMsg];
                        
                        [array addObject:videoMsg];
                    }
                    
                    if (i == arr.count - 1) {  // 最后一次遍历
                        // 发通知让会话列表刷新UI
//                        [[NSNotificationCenter defaultCenter] postNotificationName:DWDShouldReloadRecentChatData object:nil];
                        //发送通知会话列表刷新 与是否需要刷新
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad
                                                                            object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad
                                                                            object:nil
                                                                          userInfo:@{@"isNeedLoadData":@YES}];
                        
                    }
                }
                
                // 存每一个的最后一条消息  并做好未读标记
                [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addLastMsgsOfUnreadMsg:array success:^{
                    
                    DWDLog(@"批量把离线消息存到数据库成功~~~~");
                    
                    // 通知聊天界面刷新
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationInsertUnreadMsgToChatVC object:nil];
                    
                    // 更新这些最后一条未读为已读
                    [[HttpClient sharedClient] postApi:@"ChatRestService/updateLastMsgReaded" params:@{@"lastUnreadMsgs" : unreadReceiptArr} success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        DWDLog(@"更新各个未读消息的最后一条为已读到服务器 , 成功 .. ");
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                    }];
                    
                } failure:^(NSError *error) {
                    
                }];
                
                break;
            }
                
            case DWDMsgTypeSysMsg: {  // 类型是系统消息
                DWDSysMsg *result;
                result = [DWDSysMsg yy_modelWithJSON:jsonMsg];
                if([result.code isEqualToString:@"sysmsgContextual"]){ // 接送中心
                    postNotificationName = DWDReceivePickUpCenterNotification;
                    
                    [postUserInfo setObject:jsonMsg forKey:DWDReceiveNewChatMsgKey];
                    
                    friendId = @1001;
                }else if([result.code isEqualToString:@"sysMobileofficeMsgCenter"]){//智能办公
                    postNotificationName = DWDReceiveIntelligentMsgNotification;
                    
                    [postUserInfo setObject:jsonMsg forKey:DWDReceiveNewChatMsgKey];
                    
                    friendId = @1002;
                    
                }
                else {   // 其他系统消息
                    postNotificationName = DWDReceiveSysMsgNotification;
                    
                    [postUserInfo setObject:result forKey:DWDReceiveNewChatMsgKey];
                    
                    friendId = @1000;
                }
                
                break;
            }
                
            case DWDReceiptServerToApp: {  // 类型是需要回执的心跳
                
                [[DWDChatClient sharedDWDChatClient] sendData:[self makeHeartReceiptToServer:nil]];
                return;
                break;
            }
                
            default:
                break;
        }
    }
    
    
    DWDSysMsg *sysMsg;
    if ([postUserInfo[DWDReceiveNewChatMsgKey] isKindOfClass:[DWDSysMsg class]]) {
       sysMsg = postUserInfo[DWDReceiveNewChatMsgKey];
    }
    
    // 每收到一条新消息 含 新消息 和接送中心的消息 和其他的系统消息   给会话的tabbar + 1
    
    if ([postNotificationName isEqualToString:DWDReceiveNewChatMsgNotification] || [postNotificationName isEqualToString:DWDReceivePickUpCenterNotification] ||
        [postNotificationName isEqualToString:DWDReceiveIntelligentMsgNotification]) {
        
        // 处理除聊天VC 以外的其他控制器的消息存储
        // 如果当前控制器的栈顶控制器不是 聊天控制器 那么收一条消息就要存数据库 , 如果是聊天VC 因为有时间cell和Note cell 交给chat vc 处理
        
        // 如果是新消息 查找recent是否有数据 并判断是否插入时间模型
        if ([postNotificationName isEqualToString:DWDReceiveNewChatMsgNotification]) {
            
            DWDBaseChatMsg *msg = postUserInfo[DWDReceiveNewChatMsgKey];
            
            msg.state = DWDChatMsgStateSended;
            
            if ([self.receiveMessageCach containsObject:msg.msgId]) {   // 界面去重
                return;
            }
            
            if (self.receiveMessageCach.count >= 10) {
                [self.receiveMessageCach removeObjectAtIndex:0];
                [self.receiveMessageCach addObject:msg.msgId];
            }else{
                [self.receiveMessageCach addObject:msg.msgId];
            }

            // 给后台回执
            NSNumber *receiptToId = msg.chatType == DWDChatTypeFace ? msg.toUser : [DWDCustInfo shared].custId;
            DWDMsgReceiptToServer *receipToServer = [[DWDMsgReceiptToServer alloc] initWithMsgId:msg.msgId toUser:receiptToId];
            if (msg.chatType == DWDChatTypeFace) {
                if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
                    [[DWDChatClient sharedDWDChatClient] sendData:[self makeO2OTextReceiptToServer:receipToServer]];
                }else{
                    [[DWDChatClient sharedDWDChatClient] sendData:[self makeO2OFileReceiptToServer:receipToServer]];
                }
            }else{
                if ([msg.msgType isEqualToString:kDWDMsgTypeText]) {
                    [[DWDChatClient sharedDWDChatClient] sendData:[self makeO2MTextReceiptToServer:receipToServer]];
                }else{
                    [[DWDChatClient sharedDWDChatClient] sendData:[self makeO2MFileReceiptToServer:receipToServer]];
                }
            }
            
//            NSNumber *friendId = msg.chatType == DWDChatTypeFace ? msg.fromUser : msg.toUser;
            NSNumber *remarkFriendId = msg.fromUser;
            NSString *remarkName = [[DWDContactsDatabaseTool sharedContactsClient] getRemarkNameWithFriendId:remarkFriendId];
            
            msg.remarkName = remarkName.length > 0 ? remarkName : nil;
            
            [self tabbarAddOneNumber];  // tabbar number + 1
            
            [self findoutRecentChatAndUpdateRecentChatListWithMsg:msg]; // 查询recent是否有数据
            
            if ([msg.msgType isEqualToString:kDWDMsgTypeAudio]) {
                DWDAudioChatMsg *theNewAuidoMsg = (DWDAudioChatMsg *)msg;
                if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:theNewAuidoMsg.fileKey]) {  // 文件不存在 下载
                    [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:theNewAuidoMsg.fileKey compltionBlock:^{
                        DWDLog(@"在单例类下载语音mp3成功");
                    }];
                }
            }
            
            [self saveMessageToDBWithMessage:msg]; // 保存历史消息
            
        }else if ([postNotificationName isEqualToString:DWDReceivePickUpCenterNotification]){  // 接送中心
            
            [self tabbarAddOneNumber];
            
            NSString *jsonStr = postUserInfo[DWDReceiveNewChatMsgKey];
            DWDPickUpCenterJsonDataModel *jsonModel = [DWDPickUpCenterJsonDataModel yy_modelWithJSON:jsonStr];
            
            // 收到系统消息 给后台回执
            if (jsonModel.uuid != nil) {
                [[DWDChatClient sharedDWDChatClient] sendData:[self makeSysMsgReceiptToServer:@{@"code" : jsonModel.code , @"uuid" : jsonModel.uuid}]];
                if ([self.receivePickUpCenterCach containsObject:jsonModel.uuid]) {   // 界面去重
                    return;
                }
                
                if (self.receivePickUpCenterCach.count >= 10) {
                    [self.receivePickUpCenterCach removeObjectAtIndex:0];
                    [self.receivePickUpCenterCach addObject:jsonModel.uuid];
                }else{
                    [self.receivePickUpCenterCach addObject:jsonModel.uuid];
                }
            }
            
            
            //解析数据
            DWDPickUpCenterDataBaseModel *dbModel = jsonModel.entity;
            
            DWDSysMsg *sysMsg1 = [[DWDSysMsg alloc] init];
            DWDSysMsgEntity *entity = [DWDSysMsgEntity new];
            sysMsg1.entity = entity;
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            formatter.locale = [NSLocale currentLocale];
            
            NSTimeInterval time = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", dbModel.date, dbModel.time]].timeIntervalSince1970;
//            sysMsg1.entity.createTime = [NSString stringWithFormat:@"%@ %@", dbModel.date, dbModel.time]
            NSNumber *timeInterval = [NSNumber numberWithLongLong:((long long)(time * 1000))];
            sysMsg1.entity.createTime = timeInterval;
            
            NSString *parentType = [NSString parentRelationStringWithRelation:dbModel.relation];
            NSString *lastContentStr;
            if ([dbModel.contextual isEqualToString:@"Reachschool"]) {
//                【小一（2）班】小明已到校。
                lastContentStr = [NSString stringWithFormat:@"%@已安全到校。", dbModel.name];
            } else if ([dbModel.contextual isEqualToString:@"WaitparentOut"]) {
//               【小一（2）班】小明爸爸已到校门等待小明放学。
//               【%@】%@%@已到校门等待%@放学。
                lastContentStr = [NSString stringWithFormat:@"%@%@已到校门等待%@放学。", dbModel.name, parentType, dbModel.name];
            } else if ([dbModel.contextual isEqualToString:@"OnAfterschoolBus"]) {
//                【小一（2）班】小明放学啦，正准备乘坐校车回家。
//                【%@】%@放学啦，正准备乘坐校车回家。
                lastContentStr = [NSString stringWithFormat:@"%@放学啦，正准备乘坐校车回家。", dbModel.name];
            } else if ([dbModel.contextual isEqualToString:@"Getoutschool"]) {
//                【小一（2）班】小刘老师已确认小明爸爸接小明放学了。
//                【%@】%@         老师已确认 %@%@ 接 %@ 放学了。
                lastContentStr = [NSString stringWithFormat:@"%@已确认%@%@接%@放学了。", dbModel.teacher.name, dbModel.name, parentType, dbModel.name];
            } else if ([dbModel.contextual isEqualToString:@"OffAfterschoolBus"]) {
                lastContentStr = [NSString stringWithFormat:@"%@已确认%@家长接%@放学了。", dbModel.teacher.name, dbModel.name, dbModel.name];
            } else if ([dbModel.contextual isEqualToString:@"OnGotoschoolBus"]) {
//                【小一（2）班】上学啦，小明已上校车。
//                【%@】上学啦，%@已上校车。
                lastContentStr = [NSString stringWithFormat:@"上学啦，%@已上校车。", dbModel.name];
            } else if ([dbModel.contextual isEqualToString:@"OffGotoschoolBus"]) {
//               【小一（2）班】小明已安全到校。
//               【%@】%@已安全到校。
                lastContentStr = [NSString stringWithFormat:@"%@已安全到校。", dbModel.name];
            }
            
            lastContentStr = [lastContentStr stringByAppendingString:[NSString stringWithFormat:@" 【%@】", dbModel.className]];
            
            
            
            [self findoutRecentChatAndUpdateRecentChatListWithSysMsg:sysMsg1 friendId:@1001 content:lastContentStr];
            
        }else if([postNotificationName isEqualToString:DWDReceiveIntelligentMsgNotification]){
            //智能办公
            [self tabbarAddOneNumber];
            
            NSString *jsonStr = postUserInfo[DWDReceiveNewChatMsgKey];
            DWDIntelligentMessageModel *jsonModel = [DWDIntelligentMessageModel yy_modelWithJSON:jsonStr];
            
            // 收到系统消息 给后台回执
            if (jsonModel.uuid != nil) {
                [[DWDChatClient sharedDWDChatClient] sendData:[self makeSysMsgReceiptToServer:@{@"code" : jsonModel.code , @"uuid" : jsonModel.uuid}]];
                if ([self.receivePickUpCenterCach containsObject:jsonModel.uuid]) {   // 界面去重
                    return;
                }
                
                if (self.receivePickUpCenterCach.count >= 10) {
                    [self.receivePickUpCenterCach removeObjectAtIndex:0];
                    [self.receivePickUpCenterCach addObject:jsonModel.uuid];
                }else{
                    [self.receivePickUpCenterCach addObject:jsonModel.uuid];
                }
            }
            //解析数据
            DWDIntelligentMessageEntityModel *model = jsonModel.entity;
            DWDSysMsg *sysMsg1 = [[DWDSysMsg alloc] init];
            DWDSysMsgEntity *entity = [DWDSysMsgEntity new];
            sysMsg1.entity = entity;
            
            NSDate *date = [NSDate date];
            NSTimeInterval time = date.timeIntervalSince1970;
            NSNumber *timeInterval = [NSNumber numberWithLongLong:((long long)(time * 1000))];
            sysMsg1.entity.createTime = timeInterval;
             [self findoutRecentChatAndUpdateRecentChatListWithSysMsg:sysMsg1 friendId:@1002 content:model.remark];
            
        }
        
    }else if([postNotificationName isEqualToString:DWDReceiveSysMsgNotification]){// 系统消息
        // 收到系统消息 给后台回执
        if (sysMsg.code.length > 0 && sysMsg.uuid.length > 0) {
          [[DWDChatClient sharedDWDChatClient] sendData:[self makeSysMsgReceiptToServer:@{@"code" : sysMsg.code , @"uuid" : sysMsg.uuid}]];
        }
        
        if ([self.receiveSysMsgCach containsObject:sysMsg.uuid]) {   // 界面去重
            return;
        }
        
        if (self.receiveSysMsgCach.count >= 10) {
            [self.receiveSysMsgCach removeObjectAtIndex:0];
            [self.receiveSysMsgCach addObject:sysMsg.uuid];
        }else{
            [self.receiveSysMsgCach addObject:sysMsg.uuid];
        }
        
        NSString *content;
        if ([sysMsg.code isEqualToString:kDWDSysmsgNewFriendverify]) {  // 有人想添加我为好友
            
            [self tabbarAddOneNumber];
            
            //0. 取出缓存
            NSInteger chatBadgeCount = 0;
            NSInteger contactBadgeCount = 0;
            BOOL isRead = NO;
            NSDictionary *dict = [NSDictionary dictionary];
            
            NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
            NSDictionary *applayDict = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
            
            if (applayDict) {
                chatBadgeCount = [applayDict[@"chatBadgeCount"] integerValue];
                chatBadgeCount++;
                
                contactBadgeCount = [applayDict[@"contactBadgeCount"] integerValue];
                contactBadgeCount++;
                
                isRead = YES;
            }
            else
            {
                chatBadgeCount++;
                contactBadgeCount++;
                isRead = YES;
                
            }
            
            dict = @{@"chatBadgeCount":@(chatBadgeCount), @"contactBadgeCount":@(contactBadgeCount), @"isRead":@(isRead)};
            
            //1. 存入缓存
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:cacheKey];
            
            //2.发送通知，显示小红点与数字
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationShowRed object:nil];
            
        }
        
        else if ([sysMsg.code isEqualToString:kDWDSysmsgRevokeMsg]){   // 有聊天消息被撤回/删除
            DWDBaseChatMsg *revokedMsg = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchMessageWithToId:sysMsg.entity.tid MsgId:sysMsg.entity.msgId chatType:sysMsg.entity.chatType];
            
            DWDBaseChatMsg *lastMsgInDB = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchLastMsgWithToUser:sysMsg.entity.tid chatType:sysMsg.entity.chatType];
            
            if ([sysMsg.entity.type isEqualToNumber:@1]) {  // 班主任删除班级聊天消息
                if (sysMsg.entity.isRead) {
                    
                    // 删除数据库中这条消息 , 只做逻辑删除
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageWithFriendId:sysMsg.entity.tid msgs:@[revokedMsg] chatType:sysMsg.entity.chatType success:^{
                        // 发通知删除聊天界面上的这条消息 , 只做界面操作 , 数据库已删除
                        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationClassManagerDeleteMsg object:nil userInfo:@{@"deletedMsg" : revokedMsg}];
                    } failure:^(NSError *error) {
                        
                    }];
                    
                    if ([revokedMsg.msgId isEqualToString:lastMsgInDB.msgId]) {  // 如果被删除的消息 是最后一条消息
                        // 取出前一条消息 通知最近联系人界面 刷新lastContent
                        DWDBaseChatMsg *backForwardMsg = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchChatMsgWithMsg:revokedMsg toUser:sysMsg.entity.tid chatType:sysMsg.entity.chatType];
                        
                        // 向前取不到消息了证明是数据库中的第一条消息 , 也是最后一条
                        if (backForwardMsg == nil) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : @"" , @"type" : @1 , @"isAllMsgDeleted" : @1 , @"tid" : sysMsg.entity.tid}];
                        }else{
                           [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : backForwardMsg , @"type" : @1 , @"isAllMsgDeleted" : @0 ,  @"tid" : sysMsg.entity.tid}];
                        }
                    }
                }else{  // 被删除的消息是未读消息
                    // 判断红点是否大于 0 如果是需要-1 然后发通知刷新recentchat界面 gggggggg
                }
                
            }else{  // 离线时 , 有人撤回聊天消息
                if (sysMsg.entity.isRead) { // 被撤回的消息是已读消息
                    // 1. 修改被撤回消息的消息类型 赋值提示语
                    NSString *noteString = [NSString stringWithFormat:@"%@撤回了一条消息",sysMsg.entity.name];
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] revokeMsgWithNoteString:noteString revokedMsgId:sysMsg.entity.msgId friendId:sysMsg.entity.tid chatType:sysMsg.entity.chatType success:^{
                        
                        DWDLog(@"被撤回的消息 数据库操作完毕 发通知刷新聊天界面");
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationHaveMsgRevoked object:nil userInfo:@{@"revokeMsg" : revokedMsg, @"revokeNote" : noteString}];
                        
                        if ([sysMsg.entity.msgId isEqualToString:lastMsgInDB.msgId]) { // 被撤回的是最后的一条消息
                            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationRecentChatLastContentNeedChange object:nil userInfo:@{@"changedMsg" : noteString , @"type" : @2 , @"isAllMsgDeleted" : @0 ,  @"tid" : sysMsg.entity.tid}];
                        }
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }else{ // 被撤回的消息是未读的消息
                    // 1.因为后台不再推 构建一条被撤回的提示
                    DWDNoteChatMsg *revokeNote = [DWDNoteChatMsg new];
                    revokeNote.msgType = kDWDMsgTypeNote;
                    revokeNote.fromUser = [DWDCustInfo shared].custId; // 全部构造为自己发的
                    revokeNote.toUser = sysMsg.entity.tid;
                    revokeNote.createTime = sysMsg.entity.createTime;
                    revokeNote.msgId = sysMsg.entity.msgId;
                    revokeNote.chatType = sysMsg.entity.chatType;
                    NSString *name = sysMsg.entity.name;
                    revokeNote.noteString = [NSString stringWithFormat:@"%@撤回了一条消息", name];
                    
                    // 后台在推离线消息时  如果被撤回的未读 是最后一条 则发上一条未读作为最后一条 如果不是最后一条, 则未读数不需要改
                    // 先收系统消息 后收离线消息推送 所以不用发通知刷界面
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:revokeNote success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
            }
            
        }
        
        else if ([sysMsg.code isEqualToString:kDWDSysmsgFriendverifyPassed]){  // 有人通过我的好友申请
            
            //0.更新通讯录
            [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                
                // 1.通知联系人控制器刷新联系人列表
                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactsGet object:nil];
                
                NSString *lastContent = [NSString stringWithFormat:@"%@已经通过了您的好友申请",sysMsg.entity.nickname];
                // 2.插入这个最新的联系人到最近会话列表
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysMsg.entity.custId content:lastContent nickName:sysMsg.entity.nickname chatType:DWDChatTypeFace success:^{
                    
                    //3. 发通知 刷新会话列表
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.custId}];
                    
                } failure:^{
                    
                }];
                
                //构造模型
                DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:sysMsg.entity.custId chatType:DWDChatTypeFace createTime:sysMsg.entity.createTime];
                //保存历史消息
                [self saveSystemMessage:noteChatMsg];
                
                
            } failure:^(NSError *error) {
                
            }];
            
        }
        else if ([sysMsg.code isEqualToString:kDWDSysmsgNewClassMemberverify]){  // 有人申请加入我的班级
            
            [self tabbarAddOneNumber];
            
            content = [NSString stringWithFormat:@"%@想要加入%@%@",sysMsg.entity.nickname , sysMsg.entity.schoolName , sysMsg.entity.gradeName];
            
            [self findoutRecentChatAndUpdateRecentChatListWithSysMsg:sysMsg friendId:@1000 content:content];
            
            
        }
        else if ([sysMsg.code isEqualToString:kDWDSysmsgClassMemberverifyPassed]){  // 某个班级通过我的申请
            
            
            [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                
                // 1.通知联系人控制器刷新联系人列表
                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactsGet object:nil];
                
                
                //判断被操作人是否为自己
                NSString *lastContent;
                if ([sysMsg.entity.verifyId isEqualToNumber:[DWDCustInfo shared].custId])
                {
                    [self tabbarAddOneNumber];
                    lastContent = [NSString stringWithFormat:@"您已成功加入%@%@",sysMsg.entity.schoolName ,sysMsg.entity.gradeName];
                }
                else
                {
                    lastContent = [NSString stringWithFormat:@"%@加入了班级",sysMsg.entity. verifyNickname];
                }
                
                // 2.插入这个最新的内容到最近会话列表
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysMsg.entity.classId content:lastContent nickName:sysMsg.entity.gradeName chatType:DWDChatTypeClass success:^{
                    // 发通知 刷新会话列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId":sysMsg.entity.classId}];
                    
                } failure:^{
                    
                }];
                
                //3.构造模型
                DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:sysMsg.entity.classId chatType:DWDChatTypeClass createTime:sysMsg.entity.createTime];
                //4.保存历史消息
                [self saveSystemMessage:noteChatMsg];
                
                //5. 发通知 刷新班级列表
                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                
            } failure:^(NSError *error) {
                
            }];
            
        }
        else if ([sysMsg.code isEqualToString:kDWDSysmsgClassMemberverifyRefused]){ //拒绝我加入班级
            
            //            [self tabbarAddOneNumber];
            //
            //            content = [NSString stringWithFormat:@"%@已拒绝我加入%@%@",sysMsg.entity.nickname , sysMsg.entity.schoolName , sysMsg.entity.gradeName];
            //
            //            [self findoutRecentChatAndUpdateRecentChatListWithSysMsg:sysMsg friendId:@1000 content:content];
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgDeleteFriend]){ // 删除好友 有人把我删除
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDSysmsgDeleteFriendChatKey object:nil userInfo:@{@"kDWDSysmsgDeleteFriendChatKey" : sysMsg}];
            
            //0. 从本地库删除好友
            [[DWDContactsDatabaseTool sharedContactsClient] deleteContactWithFriendCustId:sysMsg.entity.custId success:^{
                // 发通知 刷通讯录列表
                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactsGet object:nil];
                
            } failure:^{
                
            }];
            
            //1. 删除会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:sysMsg.entity.custId success:^{
                
                // 发通知 刷新会话列表
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.custId}];
                
                
            } failure:^{
                
            }];
            
            //2. 删除会话历史聊天记录
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:sysMsg.entity.custId
                                                                                      chatType:DWDChatTypeFace
                                                                                       success:^{
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                       }];
            //3. 对于 好友申请列表中的已添加 进行本地库删除
            [[DWDFriendApplyDataBaseTool sharedFriendApplyDataBase] deleteWithFriendCustId:sysMsg.entity.custId MyCustId:[DWDCustInfo shared].custId];
            
                
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgAddGroupMember]){ // 添加群组成员
            
            
            //1.更新通讯录
            [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                //发送通知，更新通讯录列表
                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactsGet object:nil];
                // 发通知 刷新群组列表
                [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload object:nil];
                
            } failure:^(NSError *error) {
                
            }];
            
            //区分扫描二维码加入 还是 成员邀请成员
            NSMutableArray *nicknamesArray = [NSMutableArray arrayWithCapacity:sysMsg.entity.members.count];
            
            NSString *lastContent;
            //2.解析消息体中的members
            for (int i = 0; i < sysMsg.entity.members.count; i ++) {
                
                NSDictionary *member = sysMsg.entity.members[i];
                
                //扫描二维码加入
                if (i == 0 && [member[@"custId"] isEqualToNumber:sysMsg.entity.custId])
                {
                    if ([member[@"custId"] isEqual:[DWDCustInfo shared].custId])
                    {
                        lastContent = @"你已成功加入该群组，快来聊天吧";
                    }
                    else
                    {
                        lastContent = [NSString stringWithFormat:@"%@通过扫描二维码加入了群组",sysMsg.entity.nickname];
                    }
                    break;
                }
                else // 邀请方式加入
                {
                    //判断是否含有自己
                    if ([member[@"custId"] isEqualToNumber:[DWDCustInfo shared].custId])
                    {
                        [nicknamesArray addObject:@"我"];
                    }else{
                        [nicknamesArray addObject:member[@"nickname"]];
                    }
                }
            }
            //判断是否为nil,nil为邀请方式赋值 ，非nil为二维码方式
            lastContent =  lastContent == nil ? [NSString stringWithFormat:@"%@邀请%@加入群组", sysMsg.entity.nickname, [nicknamesArray componentsJoinedByString:@"、"]] : lastContent;
            
            
            // 3.插入这个最新的联系人到最近会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysMsg.entity.groupId content:lastContent nickName:sysMsg.entity.groupName chatType:DWDChatTypeGroup success:^{
                //4. 发通知 刷新会话列表
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.groupId}];
                
            } failure:^(NSError *error) {
                
            }];
            
            //5.构造模型
            DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:sysMsg.entity.groupId chatType:DWDChatTypeGroup createTime:sysMsg.entity.createTime];
            //6.保存历史消息
            [self saveSystemMessage:noteChatMsg];
            
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgDeleteGroupMember]){ // 群主从群中把我删除
            
            //1.从本地库删除该群
            [[DWDGroupDataBaseTool sharedGroupDataBase] deleteGroupWithMyCustId:[DWDCustInfo shared].custId gorupId:sysMsg.entity.groupId];
            // 发通知 刷新群组列表
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload object:nil];
            
            //2.从列表删除该群会话
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:sysMsg.entity.groupId success:^{
                // 发通知 刷新会话列表
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.groupId}];
            } failure:^{
            }];
            
            //3. 删除会话历史聊天记录
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:sysMsg.entity.groupId
                                                                                      chatType:DWDChatTypeGroup
                                                                                       success:^{
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                       }];
           
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgDeleteGroup]){  // 群组解散群组、所有成员收到系统消息
            
            //1.从本地库删除该群
            [[DWDGroupDataBaseTool sharedGroupDataBase] deleteGroupWithMyCustId:[DWDCustInfo shared].custId gorupId:sysMsg.entity.groupId];
            // 发通知 刷新群组列表
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload object:nil];
            
            //2.从列表删除该群会话
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:sysMsg.entity.groupId success:^{
                // 发通知 刷新会话列表
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.groupId}];
            } failure:^{
            }];
            
            //3. 删除会话历史聊天记录
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:sysMsg.entity.groupId
                                                                                      chatType:DWDChatTypeGroup
                                                                                       success:^{
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                       }];
            
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgMemberQuitGroup]){ // 群成员主动退出群组 、只有群主收到系统消息
            
            NSString *lastContent = [NSString stringWithFormat:@"%@退出了群组", sysMsg.entity.nickname];
            // 1.插入这个最新的联系人到最近会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysMsg.entity.groupId content:lastContent nickName:sysMsg.entity.groupName chatType:DWDChatTypeGroup success:^{
                // 发通知 刷新会话列表
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.groupId}];
                
            } failure:^(NSError *error) {
            }];
            
            //2.构造模型
            DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:sysMsg.entity.groupId chatType:DWDChatTypeGroup createTime:sysMsg.entity.createTime];
            //3.保存历史消息
            [self saveSystemMessage:noteChatMsg];
            
            
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgUpdateClass]){ // 更新班级头像
            
            DWDLog(@"--- %@",sysMsg.entity);
            //改班级头像
            if (sysMsg.entity.photoKey.length > 0) {
                //1. 改 tb_classes 数据库
                [[DWDClassDataBaseTool sharedClassDataBase] updateClassPhotokeyWithClassId:sysMsg.entity.classId photokey:sysMsg.entity.photoKey success:^{
                    //2. 修改recentChat 数据库
                    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:sysMsg.entity.classId photokey:sysMsg.entity.photoKey success:^{
                        //3. 刷新界面 ( 班级详情, 班级主页 , 接送中心? ...)
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeClassPhotoKeyNotification object:nil userInfo:@{@"operationId" : sysMsg.entity.classId,@"changePhotoKey" : sysMsg.entity.photoKey}];
                        //4. 发通知 刷新班级列表
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                    } failure:^{
                        
                    }];
                } failure:^{
                    
                }];
                
            }
            else if(sysMsg.entity.introduce.length > 0)
            {
                [[DWDClassDataBaseTool sharedClassDataBase] updateClassInfoWithIntroduce:sysMsg.entity.introduce ClassId:sysMsg.entity.classId myCustId:[DWDCustInfo shared].custId];
            }
            
        }
        else if ([sysMsg.code isEqualToString: kDWDSysmsgUpdateGroup]){ // 更新群组昵称或者头像
            
            if (sysMsg.entity.groupName.length > 0){ // 改群名
                //1. 改 tb_groups 数据库
                [[DWDGroupDataBaseTool sharedGroupDataBase] updateGroupNicknameWithGroupId:sysMsg.entity.groupId groupName:sysMsg.entity.groupName success:^{
                    //2. 修改recentChat 数据库
                    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateNicknameWithCusId:sysMsg.entity.groupId nickname:sysMsg.entity.groupName success:^{
                        //3. 刷新界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeGroupNicknameNotification object:nil userInfo:@{@"operationId" : sysMsg.entity.groupId,@"changeNickname" : sysMsg.entity.groupName}];
                    } failure:^{
                        
                    }];
                    
                    //4.构造模型
                    NSString *noteContent = [NSString stringWithFormat:@"%@将群组名称改为\"%@\"",sysMsg.entity.custNickname,sysMsg.entity.groupName];
                    DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:noteContent toUserId:sysMsg.entity.groupId chatType:DWDChatTypeGroup createTime:sysMsg.entity.createTime];
                    //5.保存历史消息
                    [self saveSystemMessage:noteChatMsg];
                    
                } failure:^{
                    
                }];
            }else if (sysMsg.entity.photoKey.length > 0){
                //1. 改 tb_groups 数据库 群头像
                [[DWDGroupDataBaseTool sharedGroupDataBase] updateGroupPhotokeyWithGroupId:sysMsg.entity.groupId photokey:sysMsg.entity.photoKey success:^{
                    //2. 修改recentChat 数据库
                    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:sysMsg.entity.groupId photokey:sysMsg.entity.photoKey success:^{
                        //3. 刷新界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeGroupPhotoKeyNotification object:nil userInfo:@{@"operationId" : sysMsg.entity.groupId,@"changePhotoKey" : sysMsg.entity.photoKey}];
                    } failure:^{
                        
                    }];
                    
                } failure:^{
                    
                }];
            }
        }else if ([sysMsg.code isEqualToString:kDWDSysmsgUpdateContact]) {      //更改联系人昵称或头像
            
            if (sysMsg.entity.photoKey.length > 0) {
                
                //更新联系人数据库
                [[DWDContactsDatabaseTool sharedContactsClient] updateFriendPhotoKey:sysMsg.entity.photoKey MyCustId:[DWDCustInfo shared].custId byFriendCustId:sysMsg.entity.custId success:^{
                    
                    //更新会话列表数据库
                    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:sysMsg.entity.custId photokey:sysMsg.entity.photoKey success:^{
                        
                        //刷新UI
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeContactPhotoKeyNotification object:nil userInfo:@{@"operationId" : sysMsg.entity.custId,@"changePhotoKey" : sysMsg.entity.photoKey}];
                    } failure:^{
                    }];
                } failure:^{
                }];
            }else if (sysMsg.entity.nickname.length > 0) {
                
                [[DWDContactsDatabaseTool sharedContactsClient] updateFriendNickname:sysMsg.entity.nickname MyCustId:[DWDCustInfo shared].custId byFriendCustId:sysMsg.entity.custId success:^{
                    
                    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateRecentChatNicknameWithFriendId:sysMsg.entity.custId nickname:sysMsg.entity.nickname Success:^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeContactNicknameNotification object:nil userInfo:@{@"operationId" : sysMsg.entity.custId,@"changeNickname" : sysMsg.entity.nickname}];
                    } failure:^{
                    }];
                } failure:^{
                }];
            }
        }
        
        
        else if ([sysMsg.code isEqualToString:kDWDSysmsgDeleteClassMember]){//删除班级成员。
            
            BOOL isDelete = NO;
            NSMutableArray *nicknameArray = [NSMutableArray array];
            //1.判断数组是否有自己。是则被管理者删除，否则显示管理者删除成员
            for (NSDictionary *member in sysMsg.entity.members) {
                if ([member[@"custId"] isEqualToNumber:[DWDCustInfo shared].custId]) {
                    isDelete = YES;
                    break;
                }
                
                //nickname add array
                [nicknameArray addObject:member[@"nickname"]];
            }
            
            //2.被删除 与 不被删除 逻辑 处理
            if (isDelete) {
                //1.从本地库删除该班级
                [[DWDClassDataBaseTool sharedClassDataBase] deleteClassId:sysMsg.entity.classId success:^{
                    
                    // 发通知 刷新群组列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                    
                    //2.从列表删除该群会话
                    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:sysMsg.entity.classId success:^{
                        // 发通知 刷新会话列表
                        //                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.classId}];
                        
                        //3. 删除会话历史聊天记录
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:sysMsg.entity.classId
                                                                                                  chatType:DWDChatTypeClass
                                                                                                   success:^{
                                                                                                   }
                                                                                                   failure:^(NSError *error) {
                                                                                                   }];
                        
                        
                    } failure:^{
                    }];
                    
                    //4.删除学校表与智能菜单表
                    [[DWDSchoolDataBaseTool sharedSchoolDataBase] deleteClassWithClassId:sysMsg.entity.classId success:^{
                        [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] deleteClassMenuWithClassId:sysMsg.entity.classId success:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationSmartOAMenu object:nil userInfo:nil];
                        }];
                    }];
                    
                } failure:^{
                }];
                
            }
            else
            {
                NSString *lastContent = [NSString stringWithFormat:@"%@将%@移除了班级",sysMsg.entity.nickname, [nicknameArray componentsJoinedByString:@"、"]];
                // 3.插入这个最新的联系人到最近会话列表
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysMsg.entity.classId content:lastContent nickName:sysMsg.entity.schoolName chatType:DWDChatTypeClass success:^{
                    //4. 发通知 刷新会话列表
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.classId}];
                    
                } failure:^(NSError *error) {
                    
                }];
                
                //5.构造模型
                DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:sysMsg.entity.classId chatType:DWDChatTypeClass createTime:sysMsg.entity.createTime];
                //6.保存历史消息
                [self saveSystemMessage:noteChatMsg];
            }
            
        }
        else if ([sysMsg.code isEqualToString:kDWDSysmsgMemberQuitClass]){
            
            NSString *lastContent = [NSString stringWithFormat:@"%@退出了该班级", sysMsg.entity.nickname];
            // 1.插入这个最新的联系人到最近会话列表
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysMsg.entity.classId content:lastContent nickName:sysMsg.entity.groupName chatType:DWDChatTypeClass success:^{
                // 发通知 刷新会话列表
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.classId}];
                
            } failure:^(NSError *error) {
            }];
            
            //2.构造模型
            DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:sysMsg.entity.classId chatType:DWDChatTypeClass createTime:sysMsg.entity.createTime];
            //3.保存历史消息
            [self saveSystemMessage:noteChatMsg];
            
        }
        else if ([sysMsg.code isEqualToString:kDWDSysmsgDeleteClass]){
            
            //1.从本地库删除该班级
            [[DWDClassDataBaseTool sharedClassDataBase] deleteClassId:sysMsg.entity.classId success:^{
                
                // 发通知 刷新班级列表
                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
                
                //2.从列表删除该群会话
                [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:sysMsg.entity.classId success:^{
                    // 发通知 刷新会话列表
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil userInfo:@{@"custId": sysMsg.entity.classId}];
                    
                    //3. 删除会话历史聊天记录
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:sysMsg.entity.classId
                                                                                              chatType:DWDChatTypeClass
                                                                                               success:^{
                                                                                               }
                                                                                               failure:^(NSError *error) {
                                                                                               }];
                    
                 
                } failure:^{
                }];
                
                //4.删除学校表与智能菜单表
                [[DWDSchoolDataBaseTool sharedSchoolDataBase] deleteClassWithClassId:sysMsg.entity.classId success:^{
                    [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] deleteClassMenuWithClassId:sysMsg.entity.classId success:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationSmartOAMenu object:nil userInfo:nil];
                    }];
                }];
                
            } failure:^{
            }];
            
        }
        
        else if ([sysMsg.code isEqualToString:kDWDSysmsgCrowdedUserOffline]){   // 被迫下线
            
            [DWDCustInfo shared].forceOffLine = YES;
            NSDictionary *dic = @{@"platform" : sysMsg.entity.platform , @"loginTime" : sysMsg.entity.loginTime};
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationCrowdedUserOffline object:nil userInfo:dic];
            //            return;
        }
        else if ([sysMsg.code isEqualToString:kDWDSysmsgMenu]){   // 菜单变更系统消息
           
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationSmartOAMenu object:nil userInfo:nil];
            //            return;
        }

        
        //        //发送通知会话列表刷新 与是否需要刷新
        //        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
        
        
    }
    
    
    if (postNotificationName) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:postNotificationName
         object:nil userInfo:postUserInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad
                                                             object:nil
                                                           userInfo:@{@"isNeedLoadData":@YES}];
        
        //更新智能办公班级管理的classModel
          [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassManagerClassModel object:nil];
        
    }
    
}

- (void)tabbarAddOneNumber{

    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDTabbarViewController class]]) return;
    
    DWDTabbarViewController *tabbarVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
#warning 曾经崩溃??  why ??
    //  UIApplicationRotationFollowingController 报错 找不到 tabbar  ????
    if (tabbarVc.tabBar.items > 0) {
        UITabBarItem *item = tabbarVc.tabBar.items[0];
        if ([item.badgeValue isEqualToString:@"99+"]) {
            return;
        }
        item.badgeValue = [NSString stringWithFormat:@"%zd",[item.badgeValue integerValue] + 1];
    }
    
}

- (void)saveMessageToDBWithMessage:(DWDBaseChatMsg *)msg{
    // 存消息模型到本地
    msg.state = DWDChatMsgStateSended;
    
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        DWDLog(@"历史消息在单例类中保存成功");
        
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

/** 只有发送消息时收到的回执会调用 */
- (void)updateMsgDatabaseSendingStateWithReceipt:(DWDChatMsgReceipt *)receipt{
    
    DWDChatMsgState state;
    if ([receipt.status isEqual:@1] || [receipt.status isEqual:@7]) {
        state = DWDChatMsgStateSended;
        
    }else{
        state = DWDChatMsgStateError;
    }
    
    // 更改数据库内容
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateMsgStateToState:state WithMsgReceipt:receipt chatType:receipt.chatType success:^{
        DWDLog(@"单例中收到回执 , 修改消息发送状态 ");
        
//        DWDTimeChatMsg *timeMsg = [self judgeTimeNoteWithCreateTime:receipt.createTime WithTouser:receipt.toUser chatType:receipt.chatType];
//        if (timeMsg) {
//            // 因为这个通知先发 导致排序结束才修改消息的时间为回执时间
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatNeedInsertTimeMsg object:nil userInfo:@{@"timeMsg" : timeMsg}];
//            });
//        }
        
    } failure:^(NSError *error) {
        
    }];
    
}

- (DWDTimeChatMsg *)judgeTimeNoteWithCreateTime:(NSNumber *)createTime WithTouser:(NSNumber *)toUser chatType:(DWDChatType)chatType{
    DWDTimeChatMsg *timeMsg = nil;
    NSTimeInterval beyondTime;
    if (chatType == DWDChatTypeFace) {
        beyondTime = 180;
    }else{
        beyondTime = 120;
    }
    
    DWDBaseChatMsg *base = [[DWDBaseChatMsg alloc] init];
    base.chatType = chatType;
    base.fromUser = [DWDCustInfo shared].custId;
    base.toUser = toUser;
    base.createTime = createTime;
    
    
    BOOL isBeyond = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFindTimeMsgBeyond5MinuteWithmsg:base isUnreadMsg:NO beyondTime:beyondTime];
    if (isBeyond) { // 超出5分钟了
        timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:toUser aboveCreateTime:createTime chatType:chatType];
        
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:timeMsg success:^{
            
        } failure:^(NSError *error) {
            
        }];
    }
    return timeMsg;
}

/** 根据离线消息  找出会话列表是否有发消息的这个人  有则更新数据  没有则插入数据到表 */
- (void)findoutRecentChatAndUpdateRecentChatListWithOfflineMsg:(DWDBaseChatMsg *)offlineMsg{
    
    // 此friendId 在这里一定是别人 因为要插入数据到recentChat表格 可能是班级ID
    
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithOfflineLastMsg:offlineMsg FriendCusId:offlineMsg.fromUser myCusId:[DWDCustInfo shared].custId success:^{
        
    } failure:^{
        
    }];
    
}

/**  专门用于处理 @1000  @1001 的系统消息 插入或更新recentChat列表*/
- (void)findoutRecentChatAndUpdateRecentChatListWithSysMsg:(DWDSysMsg *)sysMsg friendId:(NSNumber *)sysId content:(NSString *)content{
    
    if ([[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] haveSysDataInRecentChatWithSysId:sysId]) {
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updateNewMsgToRecentChatListWithSysMsg:sysMsg sysId:sysId content:content success:^{
            // 发通知 刷新会话列表
//            [[NSNotificationCenter defaultCenter] postNotificationName:DWDShouldReloadRecentChatData object:nil userInfo:nil];
            
            //发送通知会话列表刷新 与是否需要刷新
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
           
            
        } failure:^{
            
        }];
    }else{
        NSString *nickName = nil;
        if ([sysId isEqual:@1000]) {
            nickName = @"消息中心";
        }else if ([sysId isEqual:@1001]){
            nickName = @"接送中心";
        }else if ([sysId isEqual:@1002]){
            nickName = @"智能办公";
        }
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithSysMsg:sysMsg friendId:sysId content:content nickName:nickName chatType:DWDChatTypeNone success:^{
            // 发通知 刷新会话列表
//            [[NSNotificationCenter defaultCenter] postNotificationName:DWDShouldReloadRecentChatData object:nil userInfo:nil];
            
            //发送通知会话列表刷新 与是否需要刷新
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
           
        } failure:^{
            
        }];
    }
    
}

/** 根据收到的新消息  找出会话列表是否有发消息的这个人  有则更新数据  没有则插入数据到表 */
- (void)findoutRecentChatAndUpdateRecentChatListWithMsg:(DWDBaseChatMsg *)msg{
    NSNumber *friendId;// 此friendId 在这里一定是别人 因为要插入数据到recentChat表格 可能是班级ID
    if (msg.chatType == DWDChatTypeClass || msg.chatType == DWDChatTypeGroup) {
        friendId = msg.toUser;
    }else{
        friendId = msg.fromUser;
    }
    
    // 插入新字段, 并且badgeCount = 1
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:msg FriendCusId:friendId myCusId:[DWDCustInfo shared].custId success:^{
        // 发通知 刷新会话列表
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDShouldReloadRecentChatData object:nil userInfo:nil];
        
    } failure:^{
        
    }];
    
}

#pragma mark private methods <Parser>
/** 构造 系统消息 谁加入、移除班级 */
- (DWDNoteChatMsg *)createNoteMsgWithString:(NSString *)str toUserId:(NSNumber *)toUserId chatType:(DWDChatType)chatType createTime:(NSNumber *)createTime{
    DWDNoteChatMsg *noteMsg = [[DWDNoteChatMsg alloc] init];
    noteMsg.noteString = str;
    noteMsg.fromUser = [DWDCustInfo shared].custId;
    noteMsg.toUser = toUserId;
    noteMsg.createTime = createTime;
    noteMsg.msgType = kDWDMsgTypeNote;
    noteMsg.chatType = chatType;
    return noteMsg;
}


- (DWDTimeChatMsg *)createTimeMsgWithFromId:(NSNumber *)from toId:(NSNumber *)toId aboveCreateTime:(NSNumber *)createTime chatType:(DWDChatType)chatType{
    
    DWDTimeChatMsg *timeMsg = [[DWDTimeChatMsg alloc] init];
    timeMsg.fromUser = from;
    timeMsg.toUser = toId;
    timeMsg.msgType = kDWDMsgTypeTime;
    timeMsg.createTime = @([createTime longLongValue] - 1);
    timeMsg.chatType = chatType;
    return timeMsg;
}

// 存消息模型到本地
- (void)saveSystemMessage:(DWDBaseChatMsg *)msg
{
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        
        //0. 发通知 ，刷新聊天控制器
        NSDictionary *dict = @{@"msg":msg};
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationSystemMessageReload object:nil userInfo:dict];
        
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

- (BOOL)isLegalMsg:(unsigned char[])bytes len:(long)len{  // 检验校验码
    
    BOOL result = NO;
    
    if (len < 9) return result;
    
    Byte checkMark = [self getCheckMark:bytes len:len];
    
    result = checkMark == bytes[len - 3];
    
    unsigned char startBytes[2] = {bytes[0], bytes[1]};
    unsigned char endBytes[2] = {bytes[len - 2], bytes[len - 1]};

    for (int i = 0; i < 2; i++) {
        result = startBytes[i] == 0x40;
        result = endBytes[i] == 0x24;
    }
    
    unsigned char typeBytes[2] = {bytes[2], bytes[3]};
    
    result = [self parseChatMsgDataType:typeBytes] != DWDMsgTypeUnknow;
    
    return result;
}

- (Byte)getCheckMark:(unsigned char[])bytes len:(long)len{  // 校验码
    
    Byte result = bytes[1];
    for (int i = 6; i < len - 3; i++) {
        result = result ^ bytes[i];
    }
    
    return result;
}

// 系统消息 Command:0x9100(上行，移动端发出) 0x9101(下行，服务端发出)
- (DWDMsgType)parseChatMsgDataType:(unsigned char []) typeBytes {  // 解析消息协议code
    
    DWDMsgType result = DWDMsgTypeUnknow;
    
    if (typeBytes[0] == 0x90 && typeBytes[1] == 0x00) {
        //收到心跳
        return DWDReceiveHeart;
    } else if (typeBytes[0] == 0x90 && typeBytes[1] == 0x09) {
        return DWDReceiveHeartReplyReceived;
    }
    
    
    
    if (typeBytes[0] == 0x60) {
        
        switch (typeBytes[1]) {
                
            case 0x00:
                result = DWDMsgTypeClientLogin;  //  登出
                break;
                
            case 0x01:
                result = DWDMsgTypeClientLoginout;   // 登录
                break;
                
            case 0x10:
                result = DWDMsgTypePlainTextO2OUpload;     // 1 to 1 text  up
                break;
                
            case 0x11:
                result = DWDMsgTypePlainTextO2ODownload;  //  1 to 1 text  down ***
                break;
                
            case 0x20:
                result = DWDMsgTypeVirginUpload;   // 未读消息  up
                break;
                
            case 0x21:
                result = DWDMsgTypeVirginDownload;  // 未读消息  down ***
                break;
                
            case 0x60:
                result = DWDMsgTypePlainTextO2MUpload;  // 1 to m text up
                break;
                
            case 0x61:
                result = DWDMsgTypePlainTextO2MDownload;  //  1 to m text down ***
                break;

            default:
                result = DWDMsgTypeUnknow;
                break;
        }
        
    }
    
    else if (typeBytes[0] == 0x61) {
        
        switch (typeBytes[1]) {
                
            case 0x00:
                result = DWDMsgTypeMediaO2OUpload;
                break;
                
            case 0x01:
                result = DWDMsgTypeMediaO2ODownload;
                break;
                
            case 0x60:
                result = DWDMsgTypeMediaO2MUpload;   // 1 to m up
                break;
                
            case 0x61:
                result = DWDMsgTypeMediaO2MDownload;  // 1 to m down ***
                break;
                
            default:
                result = DWDMsgTypeUnknow;
                break;
        }
    }
    
    else if (typeBytes[0] == 0x66){  // 系统消息
        switch (typeBytes[1]) {
            case 0x00:
                result = DWDMsgTypeRevoke;
                break;
                
            default:
                result = DWDMsgTypeUnknow;
                break;
        }
    }
    
    else if (typeBytes[0] == 0x91){  // 系统消息
        switch (typeBytes[1]) {
            case 0x01:
                result = DWDMsgTypeSysMsg;
                break;
                
            default:
                result = DWDMsgTypeUnknow;
                break;
        }
    }
    
    else if (typeBytes[0] == 0x90){  // 系统消息
        switch (typeBytes[1]) {
            case 0x00:
                result = DWDReceiptServerToApp;
                break;
                
            default:
                result = DWDMsgTypeUnknow;
                break;
        }
    }
    
    else result = DWDMsgTypeUnknow;
    
    
    return result;
}

- (NSString *)parseMsgBody:(NSData *)data {
    
    NSString *result;
    
    unsigned char msgBtyes[data.length - 9];
    
    [data getBytes:msgBtyes range:NSMakeRange(6, data.length - 9)];
    
    NSData *msgData = [NSData dataWithBytes:msgBtyes length:data.length - 9];
    
    result = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSData *)parseProtocBufMsgBody:(NSData *)data {
    
    unsigned char msgBtyes[data.length - 9];
    
    [data getBytes:msgBtyes range:NSMakeRange(6, data.length - 9)];
    
    NSData *resultData = [NSData dataWithBytes:msgBtyes length:data.length - 9];
    
    return resultData;
}

#pragma mark private methods <Maker>
- (void)appendMsgStartToData:(NSMutableData *)taget {
    const Byte kDWDChatDataStart[] = {0x40, 0x40};
    [taget appendBytes:kDWDChatDataStart length:sizeof(kDWDChatDataStart)/sizeof(Byte)];
}

- (void)appendMsgTypeToData:(NSMutableData *)taget byType:(DWDMsgType)type{
    
    switch (type) {
        
        case DWDMsgTypePlainTextO2OUpload: {   // 1对1 上行
            const Byte kDWDChatDataTypeO2O[] = {0x60, 0x10};
            [taget appendBytes:kDWDChatDataTypeO2O length:sizeof(kDWDChatDataTypeO2O)/sizeof(Byte)];
            break;
        }
            
        case DWDMsgTypePlainTextO2MUpload: {  // 1对多 上行  (群聊)文本
            const Byte kDWDChatDataTypeO2M[] = {0x60, 0x60};
            [taget appendBytes:kDWDChatDataTypeO2M length:sizeof(kDWDChatDataTypeO2M)/sizeof(Byte)];
            break;
        }
        case DWDMsgTypeMediaO2MUpload: {  // 1对多 上行  (群聊)图片,语音
            const Byte kDWDChatDataTypeO2M[] = {0x61, 0x60};
            [taget appendBytes:kDWDChatDataTypeO2M length:sizeof(kDWDChatDataTypeO2M)/sizeof(Byte)];
            break;
        }
         
        case DWDMsgTypeVirginUpload: {  // 第一次上行
            const Byte kDWDChatDataTypeVirgin[] = {0x60, 0x20};
            [taget appendBytes:kDWDChatDataTypeVirgin length:sizeof(kDWDChatDataTypeVirgin)/sizeof(Byte)];
            break;
        }
        
//        case DWDMsgTypeClientLogin: {  // 登录
//            const Byte kDWDChatDataTypeClientLogin[] = {0x60, 0x00};
//            [taget appendBytes:kDWDChatDataTypeClientLogin length:sizeof(kDWDChatDataTypeClientLogin)/sizeof(Byte)];
//            break;
//        }
            
        case DWDMsgTypeClientLogin: {  // 登录
            const Byte kDWDChatDataTypeClientLogin[] = {0x62, 0x00};
            [taget appendBytes:kDWDChatDataTypeClientLogin length:sizeof(kDWDChatDataTypeClientLogin)/sizeof(Byte)];
            break;
        }
            
        case DWDMsgTypeClientLoginout: {
            const Byte kDWDChatDataTypeClientLogout[] = {0x60, 0x01};
            [taget appendBytes:kDWDChatDataTypeClientLogout length:sizeof(kDWDChatDataTypeClientLogout)/sizeof(Byte)];
            break;
        }
            
        case DWDMsgTypeMediaO2OUpload: {  // 1对1 上行
            const Byte kDWDChatDataTypeMediaO2OUpload[] = {0x61, 0x00};
            [taget appendBytes:kDWDChatDataTypeMediaO2OUpload length:sizeof(kDWDChatDataTypeMediaO2OUpload)/sizeof(Byte)];
            break;
        }
            
        case DWDMsgTypeMediaO2ODownload: {  //  1对1 下行
            const Byte kDWDChatDataTypeMediaO2ODownload[] = {0x61, 0x01};
            [taget appendBytes:kDWDChatDataTypeMediaO2ODownload length:sizeof(kDWDChatDataTypeMediaO2ODownload)/sizeof(Byte)];
            break;
        }
        case DWDMsgTypeJPUSHEnterBackground: {  //  1对1 上
            const Byte DWDMsgTypeJPUSHEnterBackground[] = {0x91, 0x02};
            [taget appendBytes:DWDMsgTypeJPUSHEnterBackground length:sizeof(DWDMsgTypeJPUSHEnterBackground)/sizeof(Byte)];
            break;
        }
            // 回执给后台   **********************************************************************************
        case DWDMsgTypeTextO2OReceiptToServer: {  //  1对1 上
            const Byte DWDMsgTypeTextO2OReceiptToServer[] = {0x60, 0x11};
            [taget appendBytes:DWDMsgTypeTextO2OReceiptToServer length:sizeof(DWDMsgTypeTextO2OReceiptToServer)/sizeof(Byte)];
            break;
        }
        case DWDMsgTypeTextO2MReceiptToServer: {  //  1对1 上
            const Byte DWDMsgTypeTextO2MReceiptToServer[] = {0x60, 0x61};
            [taget appendBytes:DWDMsgTypeTextO2MReceiptToServer length:sizeof(DWDMsgTypeTextO2MReceiptToServer)/sizeof(Byte)];
            break;
        }
        case DWDMsgTypeFileO2OReceiptToServer: {  //  1对1 上
            const Byte DWDMsgTypeFileO2OReceiptToServer[] = {0x61, 0x01};
            [taget appendBytes:DWDMsgTypeFileO2OReceiptToServer length:sizeof(DWDMsgTypeFileO2OReceiptToServer)/sizeof(Byte)];
            break;
        }
        case DWDMsgTypeFileO2MReceiptToServer: {  //  1对1 上
            const Byte DWDMsgTypeFileO2MReceiptToServer[] = {0x61, 0x61};
            [taget appendBytes:DWDMsgTypeFileO2MReceiptToServer length:sizeof(DWDMsgTypeFileO2MReceiptToServer)/sizeof(Byte)];
            break;
        }
        case DWDMsgTypeSysMsgReceiptToServer: {  //  1对1 上
            const Byte DWDMsgTypeSysMsgReceiptToServer[] = {0x91, 0x01};
            [taget appendBytes:DWDMsgTypeSysMsgReceiptToServer length:sizeof(DWDMsgTypeSysMsgReceiptToServer)/sizeof(Byte)];
            break;
        }
        case DWDReceiptServerToApp: {  //  1对1 上
            const Byte DWDReceiptServerToApp[] = {0x90, 0x00};
            [taget appendBytes:DWDReceiptServerToApp length:sizeof(DWDReceiptServerToApp)/sizeof(Byte)];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)appendMsgData:(NSString *)jsonStr toData:(NSMutableData *)taget { // 拼接消息体的长度  和 消息体
    
    DWDLog(@"msgObj str: %@", jsonStr);  // 打印系统
    
    NSData *msgData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    long len = NSSwapHostLongToLittle(msgData.length);
    
    char *charLen = (char *)&len;
    
    Byte b[] = {0,0};
    memcpy(&b[0], &charLen[1], 1);
    memcpy(&b[1], &charLen[0], 1);
    
    [taget appendBytes:b length:2];
    [taget appendData:msgData];
}

- (void)appendProtobufModelToData:(GPBMessage *)msg toData:(NSMutableData *)taget{
    DWDLog(@"msgObj protoc buf : %@" , [msg description]);
    
    long len = NSSwapHostLongToLittle([msg data].length);
    
    char *charLen = (char *)&len;
    
    Byte b[] = {0,0};
    memcpy(&b[0], &charLen[1], 1);
    memcpy(&b[1], &charLen[0], 1);
    
    [taget appendBytes:b length:2];
    [taget appendData:[msg data]];
}

- (void)appendMsgCheckMarkToData:(NSMutableData *)taget {   // 校验
    Byte checkMark[] = {0xFF};
    [taget appendBytes:checkMark length:sizeof(checkMark)/sizeof(Byte)];
}

- (void)appendMsgEndToData:(NSMutableData *)taget {  //  包尾
    const Byte kDWDChatDataEnd[] = {0x24, 0x24};
    [taget appendBytes:kDWDChatDataEnd length:sizeof(kDWDChatDataEnd)/sizeof(Byte)];
}

- (DWDBaseChatMsg *)conventToSpecificSubclass:(DWDBaseChatMsg *)source jsonSource:(NSString *)json { // 转换为特定子类
    
    if ([source.msgType isEqualToString:kDWDMsgTypeAudio]) {
        source = [DWDAudioChatMsg yy_modelWithJSON:json]; // Audio
    }
    
    else if ([source.msgType isEqualToString:kDWDMsgTypeImage]) {
        source = [DWDImageChatMsg yy_modelWithJSON:json];  // image
    }
    
    else if ([source.msgType isEqualToString:kDWDMsgTypeVideo]) {
        source = [DWDVideoChatMsg yy_modelWithJSON:json];   // Video --fzg
    }
    
    return source;
}

- (NSData *)innerMakeMsgDataFor:(id)msgObj byType:(DWDMsgType)type {   // 拼接json包
    NSMutableData *result = [NSMutableData data];
    
    [self appendMsgStartToData:result];
    [self appendMsgTypeToData:result byType:type];
    
    if (msgObj == nil) {
        [self appendMsgData:nil toData:result];
        [self appendMsgCheckMarkToData:result];
        [self appendMsgEndToData:result];
        return result;
    }
    
    if ([msgObj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)msgObj;
        [self appendMsgData:[dict yy_modelToJSONString] toData:result];
    }else if ([msgObj isKindOfClass:[DWDMsgReceiptToServer class]]){
        DWDMsgReceiptToServer *receipt = (DWDMsgReceiptToServer *)msgObj;
        [self appendMsgData:[receipt yy_modelToJSONString] toData:result];
    }else{
        DWDBaseChatMsg *base = (DWDBaseChatMsg *)msgObj;
        if ([base.msgType isEqualToString:kDWDMsgTypeAudio]) {   // body
            
            DWDAudioChatMsg *audioMsg = (DWDAudioChatMsg *)msgObj;
            [self appendMsgData:[audioMsg getJSONString] toData:result];
            
        }else if ([base.msgType isEqualToString:kDWDMsgTypeText]){
            
            DWDTextChatMsg *textMsg = (DWDTextChatMsg *)msgObj;
            
            [self appendMsgData:[textMsg getJSONString] toData:result];
            
        }
        else if ([base.msgType isEqualToString:kDWDMsgTypeVideo]) {//fzg
            
            DWDVideoChatMsg *videoMsg = (DWDVideoChatMsg *)msgObj;
            [self appendMsgData:[videoMsg getJSONString] toData:result];
        }else if ([base.msgType isEqualToString:kDWDMsgTypeImage]) {
            
            DWDImageChatMsg *imageMsg = (DWDImageChatMsg *)msgObj;
            [self appendMsgData:[imageMsg getJSONString] toData:result];
        }else {
            if ([base isKindOfClass:[DWDJPSHEnterBackgroundModel class]]) {
                DWDJPSHEnterBackgroundModel *jpMsg = (DWDJPSHEnterBackgroundModel *)msgObj;
                [self appendMsgData:[jpMsg yy_modelToJSONString] toData:result];
            }
        }
    }
    
    [self appendMsgCheckMarkToData:result];
    [self appendMsgEndToData:result];
    
    return result;
}

- (NSMutableDictionary *)sendingMsgCachDict{
    static NSMutableDictionary *dict;  // 单例中的属性 想要全局 , 也必须是静态变量
    if (!dict) {
        NSMutableDictionary *dicta = [NSMutableDictionary dictionary];
        dict = dicta;
    }
    return dict;
}

- (NSMutableArray *)receiveMessageCach{
    if (!_receiveMessageCach) {
        _receiveMessageCach = [NSMutableArray array];
    }
    return _receiveMessageCach;
}

- (NSMutableArray *)receiveSysMsgCach{
    if (!_receiveSysMsgCach) {
        _receiveSysMsgCach = [NSMutableArray array];
    }
    return _receiveSysMsgCach;
}

- (NSMutableArray *)receivePickUpCenterCach{
    if (!_receivePickUpCenterCach) {
        _receivePickUpCenterCach = [NSMutableArray array];
    }
    return _receivePickUpCenterCach;
}
@end
