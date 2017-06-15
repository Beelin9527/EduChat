//
//  DWDChatDataHandler.m
//  EduChat
//
//  Created by Superman on 16/6/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatDataHandler.h"
#import "DWDMessageDatabaseTool.h"

#import "DWDTextChatMsg.h"
#import "DWDImageChatMsg.h"
#import "DWDAudioChatMsg.h"
#import "DWDVideoChatMsg.h"
#import "DWDTimeChatMsg.h"
#import "DWDNoteChatMsg.h"

#import <YYModel.h>
#import <MJRefresh.h>

@implementation DWDChatDataHandler

+ (instancetype)loadHistoryMsgWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType fetchCount:(NSUInteger)count success:(void (^)(NSMutableArray *handleDatas))success{
    return [[DWDChatDataHandler alloc] initWithHistoryMsgWithTid:tid chatType:chatType fetchCount:(NSUInteger)count success:^(NSMutableArray *handleDatas) {
        success(handleDatas);
    }];
}

+ (instancetype)fetchUnreadMsgFromServerWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType msgId:(NSString *)msgId fetchCount:(NSInteger)count success:(void (^)(NSMutableArray *handleDatas))success{
    return [[DWDChatDataHandler alloc] unreadMsgFromServerWithTid:tid chatType:chatType msgId:msgId fetchCount:count success:^(NSMutableArray *handleDatas) {
        success(handleDatas);
    }];
}

+ (instancetype)handlerHistoryMessageWithtoUser:(NSNumber *)toUser chatType:(DWDChatType)chatType success:(void (^)(NSArray *handleDatas))successGET{
    
    return [[DWDChatDataHandler alloc] initWithtoUser:toUser chatType:chatType success:^(NSArray *handleDatas) {
        successGET(handleDatas);
    }];
    
}

+ (instancetype)handlerUnreadMessageWithTouser:(NSNumber *)toUser chatType:(DWDChatType)chatType tableView:(UITableView *)tableView chatDatas:(NSMutableArray *)chatData success:(void (^)(NSMutableArray *handleDatas))successGET{
    return [[DWDChatDataHandler alloc] initWithUnreadMessageTouser:toUser chatType:chatType tableView:(UITableView *)tableView chatDatas:(NSMutableArray *)chatData success:^(NSMutableArray *handleDatas){
        successGET(handleDatas);
    }];
}

+ (instancetype)handlerUnreadMessageForEnterAppWithMsg:(DWDBaseChatMsg *)base success:(void (^)(NSArray *handleDatas))successGET{
    
    return [[DWDChatDataHandler alloc] initWithUnreadMessageForEnterAppWithMsg:base success:^(NSArray *handleDatas) {
        successGET(handleDatas);
    }];
}

+ (instancetype)revokeMsgWithMsg:(DWDBaseChatMsg *)msg touser:(NSNumber *)toUser chatType:(DWDChatType)chatType success:(void (^)(NSString *note))success failure:(void (^)(NSError *error))failure{
    return [[DWDChatDataHandler alloc] initWithRevokeMsgWithMsg:msg touser:toUser chatType:chatType success:^(NSString *note) {
        success(note);
    } failure:^(NSError *error){
        failure(error);
    }];
}

- (instancetype)initWithHistoryMsgWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType fetchCount:(NSUInteger)count success:(void (^)(NSMutableArray *handleDatas))success{
    NSMutableArray *arr = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchHistoryMessageWithToId:tid chatType:chatType fetchCount:count];
    success(arr);
    return self;
}

// 获取离线消息
- (instancetype)unreadMsgFromServerWithTid:(NSNumber *)tid chatType:(DWDChatType)chatType msgId:(NSString *)msgId fetchCount:(NSInteger)count success:(void (^)(NSMutableArray *handleDatas))success{
    
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"friendCustId" : tid,
                             @"chatType" : [NSNumber numberWithInt:chatType],
                             @"msgId" : msgId,
                             @"count" : @(count)};
    
    [[HttpClient sharedClient] getApi:@"ChatRestService/getLatestUnreceivedList2" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *unreadMsgs = responseObject[@"data"];
        
        DWDLog(@"下拉刷新时, 获取到的未读消息数据 : %@" , unreadMsgs);
        NSMutableArray *msgs = [NSMutableArray array];
        
        // 遍历 转模型
        for (int i = (int)(unreadMsgs.count - 1); i >=0; i--) {
            NSString *msgType = unreadMsgs[i][@"msgType"];
            if ([msgType isEqualToString:kDWDMsgTypeText]) {  // 文本
                DWDTextChatMsg *tMsg = [DWDTextChatMsg yy_modelWithJSON:unreadMsgs[i]];
                tMsg.content = tMsg.content.length == 0 ? @" " : tMsg.content;
                tMsg.state = DWDChatMsgStateSended;
                [msgs addObject:tMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){  // 图片
                DWDImageChatMsg *iMsg = [DWDImageChatMsg yy_modelWithJSON:unreadMsgs[i]];
                iMsg.state = DWDChatMsgStateSended;
                [msgs addObject:iMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){  // 语音
                DWDAudioChatMsg *aMsg = [DWDAudioChatMsg yy_modelWithJSON:unreadMsgs[i]];
                aMsg.state = DWDChatMsgStateSended;
                aMsg.read = NO;
                if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:aMsg.fileKey]) {  // 文件不存在 下载
                    [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:aMsg.fileKey compltionBlock:^{
                        DWDLog(@"load history 时是语音消息 下载成功");
                        
                    }];
                }
                [msgs addObject:aMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]) {  //视频
                DWDVideoChatMsg *iMsg = [DWDVideoChatMsg yy_modelWithJSON:unreadMsgs[i]];
                iMsg.state = DWDChatMsgStateSended;
                [msgs addObject:iMsg];
            }
        }
        
        [self sortArrayByCreateTimeWithMsgs:msgs];
        
        // 先把请求消息的未读标记 置为Null
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNullWithTid:tid chatType:chatType msgId:msgId success:^{
            // 插入 未读消息 到数据库
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                success(msgs);
            } failure:^(NSError *error) {
                
            }];
        }];
        // 通知服务器, 获取未读消息成功
        [[HttpClient sharedClient] postApi:@"ChatRestService/updateLatestReaded" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DWDLog(@"通知服务器获取未读消息成功");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    
    return self;
}

- (instancetype)initWithRevokeMsgWithMsg:(DWDBaseChatMsg *)msg touser:(NSNumber *)toUser chatType:(DWDChatType)chatType success:(void (^)(NSString *note))success failure:(void (^)(NSError *error))failure{
    
    NSArray *arr = @[msg.msgId];
    
    NSDictionary *params = @{@"msgIds" : arr,
                             @"tid" : toUser,
                             @"cid" : [DWDCustInfo shared].custId,
                             @"type" : @2,
                             @"chatType" : @(chatType)};
    
    [[HttpClient sharedClient] postApi:@"short/groupchat/deleteMsg" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([responseObject[@"result"] isEqualToString:@"1"]) {  // 撤销成功
            
            NSString *noteString = @"你撤回了一条消息";
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] revokeMsgWithNoteString:noteString revokedMsgId:msg.msgId friendId:toUser chatType:chatType success:^{
                success(noteString);
            } failure:^(NSError *error) {
                
            }];
            
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
    
    return self;
}



- (instancetype)initWithUnreadMessageForEnterAppWithMsg:(DWDBaseChatMsg *)base success:(void (^)(NSArray *handleDatas))successGET{
    
    __block NSMutableArray *allMsgs = [NSMutableArray array];
    
    NSString *requestMsgId = base.msgId;
    
    NSNumber *requestCount = base.unreadMsgCount;
    
    // 先获得服务器总共还剩下多少条未读
//    NSNumber *remainUnreadCount = base.unreadMsgCount; // 这次请求未读消息的条数
    
    // 希望从服务器获取的未读消息条数
//    NSNumber *expectedUnreadCount = @(6);
    
//    NSNumber *needContinueFetchFromDBCount; // 需要继续从本地数据库获取的消息条数
    
//    NSNumber *midLocationUnreadCount; // 请求了一次之后 服务器此时总共还剩多少条未读 , 需要赋值给请求完成后的最上面一条消息
    
//    if ([remainUnreadCount integerValue] >= [expectedUnreadCount integerValue]) { // 服务器剩下的未读条数 大于等于 我希望请求的条数
//        
//        midLocationUnreadCount = @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
//        midLocationUnreadCount = [midLocationUnreadCount isEqual:@0] ? nil : @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
//        
//        requestCount = expectedUnreadCount;
//    }else{ // 服务器剩下的条数不足我希望请求的条数
//        
//        requestCount = remainUnreadCount;
//        needContinueFetchFromDBCount = @([expectedUnreadCount integerValue] - [remainUnreadCount integerValue]); // 需要继续从本地数据库再取第三部分的消息条数
//        
//    }
    
    NSNumber *toUserId = base.chatType == DWDChatTypeFace ? base.fromUser : base.toUser;
    
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"friendCustId" : toUserId,
                             @"chatType" : [NSNumber numberWithInt:base.chatType],
                             @"msgId" : requestMsgId,
                             @"count" : requestCount};
    
    [[HttpClient sharedClient] getApi:@"ChatRestService/getLatestUnreceivedList2" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *unreadMsgs = responseObject[@"data"];
        
        DWDLog(@"下拉刷新时, 获取到的未读消息数据 : %@" , unreadMsgs);
        NSMutableArray *msgs = [NSMutableArray array];
        
        // 遍历 转模型
        
        for (int i = (int)(unreadMsgs.count - 1); i >=0; i--) {
            NSString *msgType = unreadMsgs[i][@"msgType"];
            if ([msgType isEqualToString:kDWDMsgTypeText]) {  // 文本
                DWDTextChatMsg *tMsg = [DWDTextChatMsg yy_modelWithJSON:unreadMsgs[i]];
                tMsg.content = tMsg.content.length == 0 ? @" " : tMsg.content;
                tMsg.state = DWDChatMsgStateSended;
                [msgs addObject:tMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){  // 图片
                DWDImageChatMsg *iMsg = [DWDImageChatMsg yy_modelWithJSON:unreadMsgs[i]];
                iMsg.state = DWDChatMsgStateSended;
                [msgs addObject:iMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){  // 语音
                DWDAudioChatMsg *aMsg = [DWDAudioChatMsg yy_modelWithJSON:unreadMsgs[i]];
                aMsg.state = DWDChatMsgStateSended;
                aMsg.read = NO;
                if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:aMsg.fileKey]) {  // 文件不存在 下载
                    [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:aMsg.fileKey compltionBlock:^{
                        DWDLog(@"load history 时是语音消息 下载成功");
                        
                    }];
                }
                [msgs addObject:aMsg];
                
            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]) {  //视频
                DWDVideoChatMsg *iMsg = [DWDVideoChatMsg yy_modelWithJSON:unreadMsgs[i]];
                iMsg.state = DWDChatMsgStateSended;
                [msgs addObject:iMsg];
                
            }
            
        }
        
        // 未读消息添加到数组完毕
        msgs = [self handleUnreadMsgTimeNoteAndContinueUnreadCountWithMsgs:msgs chatType:base.chatType];
        [self sortArrayByCreateTimeWithMsgs:msgs];
//        DWDBaseChatMsg *theNewFirstMsg;
//        if (msgs.count > 0) {
//            theNewFirstMsg  = msgs[0];
//            theNewFirstMsg.unreadMsgCount = midLocationUnreadCount;
//        }
        
        // 先把第一部分的第一条数据  未读标记 置为Null
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:base success:^{
            
            // 插入第二部分 未读消息 到数据库
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                
                [allMsgs addObjectsFromArray:msgs];
                
                // 插入数据 , 排序 并刷新界面
                //                            [self addRefreshMsgsAndReload:allMsgs];
                [allMsgs addObject:base];
                successGET(allMsgs);
                
            } failure:^(NSError *error) {
                
            }];
            
        } failure:^(NSError *error) {
            
        }];
        // 通知服务器, 获取未读消息成功
        [[HttpClient sharedClient] postApi:@"ChatRestService/updateLatestReaded" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DWDLog(@"通知服务器获取未读消息成功");
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    return self;
}

// 下拉刷新时调用
- (instancetype)initWithUnreadMessageTouser:(NSNumber *)toUser chatType:(DWDChatType)chatType tableView:(UITableView *)tableView chatDatas:(NSMutableArray *)chatData success:(void (^)(NSMutableArray *handleDatas))successGET{
    if (self = [super init]) {
        // 发请求 或者拿数据库 分页展示
        __block NSMutableArray *allMsgs = [NSMutableArray array];
        
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)tableView.tableHeaderView;
        
        DWDBaseChatMsg *requestIDMsg;
        
        DWDBaseChatMsg *onScreenFirstMsg = [chatData firstObject];
        
        // 界面中第一条消息被删除,并且界面中没有其他数据,而数据库中还有数据的情况
        if (onScreenFirstMsg == nil) {
            DWDBaseChatMsg *lastMsgOnDB = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchLastMsgWithToUser:toUser chatType:chatType];
            // 如果是提示类消息 , 继续向前取 , 中间有N条被撤回 , 也能获取
            if ([lastMsgOnDB isKindOfClass:[DWDNoteChatMsg class]] || [lastMsgOnDB isKindOfClass:[DWDTimeChatMsg class]]) {
                while (1) {
                    lastMsgOnDB = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchChatMsgWithMsg:lastMsgOnDB toUser:toUser chatType:chatType];
                    if (![lastMsgOnDB isKindOfClass:[DWDNoteChatMsg class]] && ![lastMsgOnDB isKindOfClass:[DWDTimeChatMsg class]]) {
                        onScreenFirstMsg = lastMsgOnDB;
                        [chatData addObject:lastMsgOnDB];
                        break;
                    }
                }
                
            }
        }
        
        for (int i = 0; i < chatData.count; i++) {
            if (![chatData[i] isKindOfClass:[DWDTimeChatMsg class]] && ![chatData[i] isKindOfClass:[DWDNoteChatMsg class]]) {
                requestIDMsg = chatData[i];
                break;
            }
        }
        
        __block NSString *requestMsgId;
        
        if ([onScreenFirstMsg.unreadMsgCount integerValue] > 0) { // 界面的第一条数据以上就有未读消息
            NSNumber *requestCount;
            
            requestMsgId = requestIDMsg.msgId;
            // 先获得服务器总共还剩下多少条未读
            NSNumber *remainUnreadCount = onScreenFirstMsg.unreadMsgCount; // 这次请求未读消息的条数
            
            // 希望从服务器获取的未读消息条数
            NSNumber *expectedUnreadCount = @(6);
            
            NSNumber *needContinueFetchFromDBCount; // 需要继续从本地数据库获取的消息条数
            
            NSNumber *midLocationUnreadCount; // 请求了一次之后 服务器此时总共还剩多少条未读 , 需要赋值给请求完成后的最上面一条消息
            
            if ([remainUnreadCount integerValue] >= [expectedUnreadCount integerValue]) { // 服务器剩下的未读条数 大于等于 我希望请求的条数
                
                midLocationUnreadCount = @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
                midLocationUnreadCount = [midLocationUnreadCount isEqual:@0] ? nil : @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
                
                requestCount = expectedUnreadCount;
            }else{ // 服务器剩下的条数不足我希望请求的条数
                
                requestCount = remainUnreadCount;
                needContinueFetchFromDBCount = @([expectedUnreadCount integerValue] - [remainUnreadCount integerValue]); // 需要继续从本地数据库再取第三部分的消息条数
                
            }
            
            NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                     @"friendCustId" : toUser,
                                     @"chatType" : [NSNumber numberWithInt:chatType],
                                     @"msgId" : requestMsgId,
                                     @"count" : requestCount};
            
            [[HttpClient sharedClient] getApi:@"ChatRestService/getLatestUnreceivedList2" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSArray *unreadMsgs = responseObject[@"data"];
                
                DWDLog(@"下拉刷新时, 获取到的未读消息数据 : %@" , unreadMsgs);
                NSMutableArray *msgs = [NSMutableArray array];
                
                // 遍历 转模型
                
                for (int i = (int)(unreadMsgs.count - 1); i >=0; i--) {
                    NSString *msgType = unreadMsgs[i][@"msgType"];
                    if ([msgType isEqualToString:kDWDMsgTypeText]) {  // 文本
                        DWDTextChatMsg *tMsg = [DWDTextChatMsg yy_modelWithJSON:unreadMsgs[i]];
                        tMsg.content = tMsg.content.length == 0 ? @" " : tMsg.content;
                        tMsg.state = DWDChatMsgStateSended;
                        [msgs addObject:tMsg];
                        
                    }else if ([msgType isEqualToString:kDWDMsgTypeImage]){  // 图片
                        DWDImageChatMsg *iMsg = [DWDImageChatMsg yy_modelWithJSON:unreadMsgs[i]];
                        iMsg.state = DWDChatMsgStateSended;
                        [msgs addObject:iMsg];
                        
                    }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){  // 语音
                        DWDAudioChatMsg *aMsg = [DWDAudioChatMsg yy_modelWithJSON:unreadMsgs[i]];
                        aMsg.state = DWDChatMsgStateSended;
                        aMsg.read = NO;
                        if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:aMsg.fileKey]) {  // 文件不存在 下载
                            [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:aMsg.fileKey compltionBlock:^{
                                DWDLog(@"load history 时是语音消息 下载成功");
                                
                            }];
                        }
                        [msgs addObject:aMsg];
                        
                    }else if ([msgType isEqualToString:kDWDMsgTypeVideo]) {  //视频
                        DWDVideoChatMsg *iMsg = [DWDVideoChatMsg yy_modelWithJSON:unreadMsgs[i]];
                        iMsg.state = DWDChatMsgStateSended;
                        [msgs addObject:iMsg];
                        
                    }
                    
                }
                
                // 未读消息添加到数组完毕
                msgs = [self handleUnreadMsgTimeNoteAndContinueUnreadCountWithMsgs:msgs chatType:chatType];
                [self sortArrayByCreateTimeWithMsgs:msgs];
                DWDBaseChatMsg *theNewFirstMsg;
                if (msgs.count > 0) {
                    theNewFirstMsg = msgs[0];
                    theNewFirstMsg.unreadMsgCount = midLocationUnreadCount;
                }
                
                if ([needContinueFetchFromDBCount integerValue] > 0) { // 需要继续从本地数据库获取第二部分数据满足25条
                    
                    // 更新ID前 先把第一部分的第一条数据  未读标记 置为Null
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:onScreenFirstMsg success:^{
                        
                        // 更新ID完毕 ,插入未读消息到数据库
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                            
                            allMsgs = msgs;
                            // 继续从本地取 第二部分数据
                            DWDBaseChatMsg *needContinueBeginningMsg;
                            if (msgs.count > 0) {
                                needContinueBeginningMsg = [msgs firstObject];
                            }
                            
                            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:needContinueBeginningMsg.createTime friendId:toUser chatType:chatType fetchCount:needContinueFetchFromDBCount success:^(NSArray *chatSessions) {
                                
                                if (chatSessions.count > 0) {  // 如果本地库还有数据可取 则作为第二部分数据加入数组中
                                    [allMsgs addObjectsFromArray:chatSessions];
                                }
                                
                                // 插入数据 , 排序 并刷新界面
                                successGET(allMsgs);
                                [header endRefreshing];
                                
                            } failure:^(NSError *error) {
                                
                            }];
                            
                        } failure:^(NSError *error) {
                            
                        }];
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }else{ // 已经满了25条 不需要继续再从本地取数据了
                    
                    // 先把第一部分的第一条数据  未读标记 置为Null
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:onScreenFirstMsg success:^{
                        
                        // 插入第二部分 未读消息 到数据库
                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                            
                            [allMsgs addObjectsFromArray:msgs];
                            
                            // 插入数据 , 排序 并刷新界面
                            successGET(allMsgs);
                            [header endRefreshing];
                            
                        } failure:^(NSError *error) {
                            
                        }];
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
                
                // 通知服务器, 获取未读消息成功
                [[HttpClient sharedClient] postApi:@"ChatRestService/updateLatestReaded" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                    DWDLog(@"通知服务器获取未读消息成功");
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
        }else{   // 界面中数据第一条以上没有未读
            
            // 先从本地向上取 , 取到未读标记大于0为止 , 目标是25条
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:onScreenFirstMsg.createTime friendId:toUser chatType:chatType fetchCount:@6 success:^(NSArray *chatSessions) {
                
                for (int i = 0; i < chatSessions.count; i++) {  // 发图片消息时 因为图片插入界面的顺序 和服务器返回回执的时间戳不对等问题 有可能取出重复的图片数据
                    DWDBaseChatMsg *dbMsg = chatSessions[i];
                    for (int j = 0; j < chatData.count; j++) {
                        DWDBaseChatMsg *screenMsg = chatData[j];
                        if ([dbMsg.msgId isEqualToString:screenMsg.msgId]) {
                            [header endRefreshing];
                            return ;
                        }
                    }
                }
                
                if (chatSessions.count == 0) { // 如果向上取的数据为 0  检查是否还有未读消息
                    [header endRefreshing];
                }else if (chatSessions.count == 1){
                    if([[chatSessions firstObject]isKindOfClass:[DWDTimeChatMsg class]] || [[chatSessions firstObject] isKindOfClass:[DWDNoteChatMsg class]]){
                        [header endRefreshing];
                    }
                    
                }else{  //  向上获取的第一部分数据
                    [allMsgs addObjectsFromArray:chatSessions];
                    
                    if (chatSessions.count < 6) { // 如果数据库取出的数据少于25条 , 则中间遇上未读标记
                        // 先获得服务器总共还剩下多少条未读
                        
                        [self sortArrayByCreateTimeWithMsgs:allMsgs];
                        
                        DWDBaseChatMsg *haveUnreadCountMsg = [allMsgs firstObject];
                        NSNumber *remainUnreadCount = haveUnreadCountMsg.unreadMsgCount;
                        
                        for (int i = 0; i < chatSessions.count; i++) {
                            if (![chatSessions[i] isKindOfClass:[DWDTimeChatMsg class]] && ![chatSessions[i] isKindOfClass:[DWDNoteChatMsg class]]) {
                                DWDBaseChatMsg *dbMsgFirst = chatSessions[i];
                                requestMsgId = dbMsgFirst.msgId;
                                break;
                            }
                        }
                        
                        // 希望从服务器获取的未读消息条数
                        NSNumber *expectedUnreadCount = @(6 - chatSessions.count);
                        
                        NSNumber *requestCount;  // 这次请求未读消息的条数
                        
                        NSNumber *needContinueFetchFromDBCount; // 需要继续从本地数据库获取的消息条数
                        
                        NSNumber *midLocationUnreadCount; // 请求了一次之后 服务器此时总共还剩多少条未读 , 需要赋值给请求完成后的最上面一条消息
                        
                        if ([remainUnreadCount integerValue] >= [expectedUnreadCount integerValue]) { // 服务器剩下的未读条数 大于等于 我希望请求的条数
                            
                            midLocationUnreadCount = @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
                            requestCount = expectedUnreadCount;
                        }else{ // 服务器剩下的条数不足我希望请求的条数
                            
                            requestCount = remainUnreadCount;
                            needContinueFetchFromDBCount = @([expectedUnreadCount integerValue] - [remainUnreadCount integerValue]); // 需要继续从本地数据库再取一部分的消息条数
                            
                        }
                        
                        if ([requestCount isEqual:@0] && [needContinueFetchFromDBCount integerValue] > 0) { // 如果请求个数为0 , 但总数据不足25 需要从本地继续获取的情况
                            
                            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:haveUnreadCountMsg.createTime friendId:toUser chatType:chatType fetchCount:needContinueFetchFromDBCount success:^(NSArray *chatSessions) {
                                
                                if (chatSessions.count > 0) {  // 本地库成功获取到了数据  ssss
                                    
                                    [allMsgs addObjectsFromArray:chatSessions];
                                    
                                    successGET(allMsgs);
                                    [header endRefreshing];
                                    
                                }else{  // 本地库没有了
                                    successGET(allMsgs);
                                    [header endRefreshing];
                                }
                                
                            } failure:^(NSError *error) {
                                
                            }];
                            
                        }else{  // 请求个数 大于0    ======
                            
                            
                            NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                                     @"friendCustId" : toUser,
                                                     @"chatType" : [NSNumber numberWithInt:chatType],
                                                     @"msgId" : requestMsgId,
                                                     @"count" : requestCount};
                            
                            [[HttpClient sharedClient] getApi:@"ChatRestService/getLatestUnreceivedList2" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                                
                                NSArray *unreadMsgs = responseObject[@"data"];
                                NSMutableArray *msgs = [NSMutableArray array];
                                
//                                DWDBaseChatMsg *firstMsg = [allMsgs firstObject];  // 取出从本地取出的第一部分中的第一个数据
                                
                                // 遍历 转模型
                                for (int i = (int)(unreadMsgs.count - 1); i >=0; i--) {
                                    NSString *msgType = unreadMsgs[i][@"msgType"];
                                    if ([msgType isEqualToString:kDWDMsgTypeText]) {  // 文本
                                        DWDTextChatMsg *tMsg = [DWDTextChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                        tMsg.content = tMsg.content.length == 0 ? @" " : tMsg.content;
                                        tMsg.state = DWDChatMsgStateSended;
                                        [msgs addObject:tMsg];
                                        
                                    }else if ([msgType isEqualToString:kDWDMsgTypeImage]){  // 图片
                                        DWDImageChatMsg *iMsg = [DWDImageChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                        iMsg.state = DWDChatMsgStateSended;
                                        [msgs addObject:iMsg];
                                        
                                    }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){  // 语音
                                        DWDAudioChatMsg *aMsg = [DWDAudioChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                        aMsg.state = DWDChatMsgStateSended;
                                        aMsg.read = NO;
                                        
                                        if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:aMsg.fileKey]) {  // 文件不存在 下载
                                            [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:aMsg.fileKey compltionBlock:^{
                                                DWDLog(@"load history 时是语音消息 下载成功");
                                                
                                            }];
                                        }
                                        
                                        [msgs addObject:aMsg];
                                        
                                    }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){  // 视频
                                        DWDVideoChatMsg *vMsg = [DWDVideoChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                        vMsg.state = DWDChatMsgStateSended;
                                        [msgs addObject:vMsg];
                                        
                                    }
                                    
                                }
                                if (unreadMsgs.count == 0) {
                                    successGET(allMsgs);
                                    [header endRefreshing];
                                }
                                // 未读消息添加到数组完毕
                                msgs = [self handleUnreadMsgTimeNoteAndContinueUnreadCountWithMsgs:msgs chatType:chatType];
                                [self sortArrayByCreateTimeWithMsgs:msgs];
                                
                                DWDBaseChatMsg *theNewFirstMsg;
                                if (msgs.count > 0) {
                                    theNewFirstMsg = msgs[0];
                                    theNewFirstMsg.unreadMsgCount = midLocationUnreadCount;
                                }
                                
                                if ([needContinueFetchFromDBCount integerValue] > 0) { // 需要继续从本地数据库获取第三部分数据满足25条
                                    
                                    // 先把第一部分的第一条数据  未读标记 置为Null
                                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:haveUnreadCountMsg success:^{
                                        
                                        // 插入未读消息到数据库指定位置
                                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                                            // 插入完毕 把第二部分数据加入到数组中
                                            [msgs addObjectsFromArray:allMsgs];  // msgs 本身反转过
                                            
                                            allMsgs = msgs;
                                            // 继续从本地取 第三部分数据
                                            DWDBaseChatMsg *needContinueFetchBeginMsg;
                                            if (msgs.count > 0) {
                                                needContinueFetchBeginMsg = [msgs firstObject];
                                            }
                                            
                                            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:needContinueFetchBeginMsg.createTime friendId:toUser chatType:chatType fetchCount:needContinueFetchFromDBCount success:^(NSArray *chatSessions) {
                                                
                                                if (chatSessions.count > 0) {  // 如果本地库还有数据可取 则作为第三部分数据加入数组中
                                                    
                                                    [allMsgs addObjectsFromArray:chatSessions];
                                                    
                                                }
                                                
                                                // 插入数据 , 排序 并刷新界面
                                                successGET(allMsgs);
                                                [header endRefreshing];
                                                
                                            } failure:^(NSError *error) {
                                                
                                            }];
                                            
                                        } failure:^(NSError *error) {
                                            
                                        }];
                                        
                                    } failure:^(NSError *error) {
                                        
                                    }];
                                }else{ // 已经满了25条 不需要继续再从本地取数据了
                                    
                                    // 先把第一部分的第一条数据  未读标记 置为Null
                                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:haveUnreadCountMsg success:^{
                                        
                                        // 插入第二部分 未读消息 到数据库 第一部分数据的上面
                                        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                                            
                                            [allMsgs addObjectsFromArray:msgs];
                                            // 插入数据 , 排序 并刷新界面
                                            successGET(allMsgs);
                                            [header endRefreshing];
                                            
                                        } failure:^(NSError *error) {
                                            
                                        }];
                                        
                                    } failure:^(NSError *error) {
                                        
                                    }];
                                }
                                
                                // 通知服务器, 获取未读消息成功
                                [[HttpClient sharedClient] postApi:@"ChatRestService/updateLatestReaded" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                                    DWDLog(@"通知服务器获取未读消息成功");
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    
                                }];
                                
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                
                                
                            }];
                        }
                        
                        
                    }else{
                        // 等于25条
                        // 插入数据 , 排序 并刷新界面
                        successGET(allMsgs);
                        [header endRefreshing];
                    }
                    
                    
                }
                
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
    return self;
}

- (instancetype)initWithtoUser:(NSNumber *)toUser chatType:(DWDChatType)chatType success:(void (^)(NSArray *handleDatas))successGET{
    if (self = [super init]) {
        
        __block NSMutableArray *allMsgs = [NSMutableArray array];
        
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] fetchMsgsUntilLastMsgOfUnreadMsgsWithFriendId:toUser chatType:chatType success:^(NSArray *chatSessions) {
            
            if (chatSessions.count == 0) return ;
            
            [allMsgs addObjectsFromArray:chatSessions];
            
            if (chatSessions.count < 6) { // 如果数据库取出的数据少于25条
                // 先获得服务器总共还剩下多少条未读
                DWDBaseChatMsg *base = [allMsgs firstObject];
                NSNumber *remainUnreadCount = base.unreadMsgCount;
                
                if ([remainUnreadCount isEqual:@0]) {
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:base success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                    [self sortArrayByCreateTimeWithMsgs:allMsgs];
                    successGET(allMsgs);
                    return;
                }
                
                // 希望从服务器获取的未读消息条数
                NSNumber *expectedUnreadCount = @(6 - chatSessions.count);
                
                NSNumber *requestCount;  // 这次请求未读消息的条数
                
                NSNumber *needContinueFetchFromDBCount; // 需要继续从本地数据库获取的消息条数
                
                NSNumber *midLocationUnreadCount; // 请求了一次之后 服务器此时总共还剩多少条未读 , 需要赋值给请求完成后的最上面一条消息
                
                if ([remainUnreadCount integerValue] >= [expectedUnreadCount integerValue]) { // 服务器剩下的未读条数 大于等于 我希望请求的条数
                    
                    midLocationUnreadCount = @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
                    midLocationUnreadCount = [midLocationUnreadCount isEqual:@0] ? nil : @([remainUnreadCount integerValue] - [expectedUnreadCount integerValue]);
                    
                    requestCount = expectedUnreadCount;
                }else{ // 服务器剩下的条数不足我希望请求的条数
                    
                    requestCount = remainUnreadCount;
                    needContinueFetchFromDBCount = @([expectedUnreadCount integerValue] - [remainUnreadCount integerValue]); // 需要继续从本地数据库再取一部分的消息条数
                    
                }
                
                if ([requestCount isEqual:@0] && [needContinueFetchFromDBCount integerValue] > 0) { // 如果请求个数为0 , 但需要从本地获取却大于0 的情况
                    
                    DWDBaseChatMsg *upBeginning = [allMsgs firstObject];
                    
                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:upBeginning.createTime friendId:toUser chatType:chatType fetchCount:needContinueFetchFromDBCount success:^(NSArray *chatSessions) {
                        
                        if (chatSessions.count > 0) {  // 本地库成功获取到了数据  (未反转)
                            
                            [allMsgs addObjectsFromArray:chatSessions];
                            
                            [self sortArrayByCreateTimeWithMsgs:allMsgs];
                            successGET(allMsgs);
                            
                        }else{  // 本地库没有了
                            [self sortArrayByCreateTimeWithMsgs:allMsgs];
                            successGET(allMsgs);
                            
                        }
                        
                    } failure:^(NSError *error) {
                        
                    }];
                    
                }else{
                    
                    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                             @"friendCustId" : toUser,
                                             @"chatType" : [NSNumber numberWithInt:chatType],
                                             @"msgId" : base.msgId,
                                             @"count" : requestCount};
                    
                    [[HttpClient sharedClient] getApi:@"ChatRestService/getLatestUnreceivedList2" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        NSArray *unreadMsgs = responseObject[@"data"];
                        
                        DWDLog(@"第一次进聊天界面 加载历史消息时  从服务器获取到的未读消息数据  : %@ " , unreadMsgs);
                        NSMutableArray *msgs = [NSMutableArray array];
                        
                        DWDBaseChatMsg *firstMsg = [allMsgs firstObject];
                        
                        // 遍历 转模型
                        for (int i = (int)(unreadMsgs.count - 1); i >=0; i--) {
                            NSString *msgType = unreadMsgs[i][@"msgType"];
                            if ([msgType isEqualToString:kDWDMsgTypeText]) {  // 文本
                                DWDTextChatMsg *tMsg = [DWDTextChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                tMsg.content = tMsg.content.length == 0 ? @" " : tMsg.content;
                                tMsg.state = DWDChatMsgStateSended;
                                [msgs addObject:tMsg];
                                
                            }else if ([msgType isEqualToString:kDWDMsgTypeImage]){  // 图片
                                DWDImageChatMsg *iMsg = [DWDImageChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                iMsg.state = DWDChatMsgStateSended;
                                [msgs addObject:iMsg];
                                
                            }else if ([msgType isEqualToString:kDWDMsgTypeAudio]){  // 语音
                                DWDAudioChatMsg *aMsg = [DWDAudioChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                aMsg.state = DWDChatMsgStateSended;
                                aMsg.read = NO;
                                
                                if (![[DWDAliyunManager sharedAliyunManager] is_file_exist:aMsg.fileKey]) {  // 文件不存在 下载
                                    [[DWDAliyunManager sharedAliyunManager] downloadMp3ObjectAsyncWithObjecName:aMsg.fileKey compltionBlock:^{
                                        DWDLog(@"load history 时是语音消息 下载成功");
                                        
                                    }];
                                }
                                
                                [msgs addObject:aMsg];
                                
                            }else if ([msgType isEqualToString:kDWDMsgTypeVideo]){  // 视频
                                DWDVideoChatMsg *vMsg = [DWDVideoChatMsg yy_modelWithJSON:unreadMsgs[i]];
                                vMsg.state = DWDChatMsgStateSended;
                                [msgs addObject:vMsg];
                                
                            }
                            
                        }
                        
                        // 未读消息添加到数组完毕
                        msgs = [self handleUnreadMsgTimeNoteAndContinueUnreadCountWithMsgs:msgs chatType:chatType];
                        [self sortArrayByCreateTimeWithMsgs:msgs];
                        DWDBaseChatMsg *theNewFirstMsg;
                        if (msgs.count > 0) {
                            theNewFirstMsg = msgs[0];
                            theNewFirstMsg.unreadMsgCount = midLocationUnreadCount;
                        }
                        
                        if ([needContinueFetchFromDBCount integerValue] > 0) { // 需要继续从本地数据库获取一部分数据满足25条
                            
                            // 先把这次请求的msg的 未读标记 置为Null
                            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:firstMsg success:^{
                                
                                // 插入未读消息到数据库指定位置
                                [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                                    // 插入完毕 加到数组中
                                    [msgs addObjectsFromArray:allMsgs];
                                    
                                    allMsgs = msgs;
                                    // 继续从本地取
                                    
                                    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFetchMsgsFromBeginningCreatTime:theNewFirstMsg.createTime friendId:toUser chatType:chatType fetchCount:needContinueFetchFromDBCount success:^(NSArray *chatSessions) {
                                        
                                        if (chatSessions.count > 0) {  // 如果本地库还有数据  才做这些操作
                                            
                                            [allMsgs addObjectsFromArray:chatSessions];
                                            
                                        }
                                        
                                        // 插入数据 , 排序 并刷新界面
                                        [self sortArrayByCreateTimeWithMsgs:allMsgs];
                                        successGET(allMsgs);
                                        
                                    } failure:^(NSError *error) {
                                        
                                    }];
                                    
                                } failure:^(NSError *error) {
                                    
                                }];
                                
                            } failure:^(NSError *error) {
                                
                            }];
                        }else{ // 已经满了25条 不需要继续再从本地取数据了
                            
                            // 先把这次请求的msg的 未读标记 置为Null
                            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] resetMsgUnreadCountToNull:firstMsg success:^{
                                
                                // 插入未读消息到数据库指定位置
                                [[DWDMessageDatabaseTool sharedMessageDatabaseTool] insertUnreadMsgToDBWithMsg:msgs success:^{
                                    
                                    [allMsgs addObjectsFromArray:msgs];
                                    
                                    // 插入数据 , 排序 并刷新界面
                                    [self sortArrayByCreateTimeWithMsgs:allMsgs];
                                    successGET(allMsgs);
                                    
                                } failure:^(NSError *error) {
                                    
                                }];
                                
                            } failure:^(NSError *error) {
                                
                            }];
                        }
                        
                        // 通知服务器, 获取未读消息成功
                        [[HttpClient sharedClient] postApi:@"ChatRestService/updateLatestReaded" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                            DWDLog(@"通知服务器获取未读消息成功");
                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            
                        }];
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                        
                    }];
                }
                
                
            }else{
                // 等于25条
                // 插入数据 , 排序 并刷新界面
                [self sortArrayByCreateTimeWithMsgs:allMsgs];
                successGET(allMsgs);
            }
            
        } failure:^(NSError *error) {
            
        }];
        
    }
    return self;
}

- (NSMutableArray *)handleUnreadMsgTimeNoteAndContinueUnreadCountWithMsgs:(NSMutableArray *)msgs chatType:(DWDChatType)chatType{
    NSMutableArray *arrB = [msgs mutableCopy]; // 拷贝一份未读消息数组
    
    DWDBaseChatMsg *firstMsg = [msgs firstObject];
    NSTimeInterval beyongdTime = firstMsg.chatType == DWDChatTypeFace ? 180 : 120;
    NSNumber *friendId = firstMsg.chatType == DWDChatTypeFace ? firstMsg.fromUser : firstMsg.toUser;
    NSNumber *theNewJudgeTimeStamp = nil;
    
    // 判断离线中的第一条是否需要插入时间提示 , 从数据库里找
    BOOL isNeedInsertTimeMsg = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFindTimeMsgBeyond5MinuteWithmsg:firstMsg isUnreadMsg:NO beyondTime:beyongdTime];
    if (isNeedInsertTimeMsg) {
        DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:friendId chatType:chatType aboveCreateTime:firstMsg.createTime];
        [arrB addObject:timeMsg];
        theNewJudgeTimeStamp = timeMsg.createTime;
    }
    
    BOOL needInsert = NO;
    
    for (int i = 0; i < msgs.count; i++) {
        DWDBaseChatMsg *base = msgs[i]; // 每次遍历都判断是否插入时间
        
        if (theNewJudgeTimeStamp) {
            needInsert = [self judgeTimeBeyongTimeStamp:theNewJudgeTimeStamp msg:base chatType:chatType];
            if (needInsert) {
                DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:friendId chatType:chatType aboveCreateTime:base.createTime];
                [arrB addObject:timeMsg];
                theNewJudgeTimeStamp = timeMsg.createTime;
            }
        }else{
            
            needInsert = [[DWDMessageDatabaseTool sharedMessageDatabaseTool] upFindOutTimeMsgDESCOrderByCreateTimeLessThanTimeStamp:base.createTime tableName:base];
            if (needInsert) {
                DWDTimeChatMsg *timeMsg = [self createTimeMsgWithFromId:[DWDCustInfo shared].custId toId:friendId chatType:chatType aboveCreateTime:base.createTime];
                [arrB addObject:timeMsg];
                theNewJudgeTimeStamp = timeMsg.createTime;
            }
            
        }
        
    }
    return arrB;
}

- (DWDTimeChatMsg *)createTimeMsgWithFromId:(NSNumber *)from toId:(NSNumber *)toId chatType:(DWDChatType)chatType aboveCreateTime:(NSNumber *)createTime{
    
    DWDTimeChatMsg *timeMsg = [[DWDTimeChatMsg alloc] init];
    timeMsg.fromUser = from;
    timeMsg.toUser = toId;
    timeMsg.msgType = kDWDMsgTypeTime;
    
    timeMsg.createTime = @([createTime longLongValue] - 1);
    timeMsg.chatType = chatType;
    return timeMsg;
}

#pragma mark - 上次的 和 下一条的未读msg
- (BOOL)judgeTimeBeyongTimeStamp:(NSNumber *)theNewjudgeTime msg:(DWDBaseChatMsg *)base chatType:(DWDChatType)chatType{
    
    int64_t delta = [base.createTime longLongValue] / 1000.0 - [theNewjudgeTime longLongValue] / 1000.0;
    if (chatType == DWDChatTypeFace) {
        if (delta > 180) {
            return YES;
        }else{
            return NO;
        }
    }else{
        if (delta > 60) {
            return YES;
        }else{
            return NO;
        }
    }
    
}

- (void)sortArrayByCreateTimeWithMsgs:(NSMutableArray *)msgs{
    
    [msgs sortUsingComparator:^NSComparisonResult(DWDBaseChatMsg *obj1, DWDBaseChatMsg *obj2) {
        
        if ([obj1.createTime compare:obj2.createTime] == NSOrderedAscending) {
            return NSOrderedAscending;
        }else if ([obj1.createTime compare:obj2.createTime] == NSOrderedSame){
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
}

@end
