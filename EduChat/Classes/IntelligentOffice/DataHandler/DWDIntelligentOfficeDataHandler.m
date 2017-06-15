//
//  DWDIntelligentOfficeDataHandler.m
//  EduChat
//
//  Created by Beelin on 16/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntelligentOfficeDataHandler.h"

#import "DWDIntNoticeListModel.h"
#import "DWDIntNoticeDetailModel.h"
#import "DWDIntMessageModel.h"

#import <YYModel.h>
@interface DWDIntelligentOfficeDataHandler()
@property (nonatomic, weak) UIViewController *targetController;
@end
@implementation DWDIntelligentOfficeDataHandler

/**
 *  菜单功能介绍
 */
+ (void)requestGetAlertWithCid:(NSNumber *)cid
                           sid:(NSNumber *)sid
                          mncd:(NSString *)code
                           sta:(NSNumber *)sta
              targetController:(UIViewController *)targetController
                       success:(void(^)())success
                       failure:(void(^)(NSError *error))failure{
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:targetController.view];
    
    DWDIntelligentOfficeDataHandler *handler =  [[DWDIntelligentOfficeDataHandler alloc] init];
    handler.targetController = targetController;
    
    NSDictionary *params = @{@"cid": cid,
                             @"sid": sid,
                             @"mncd": code,
                             @"sta": sta ? sta : [NSNull null]};
    
    [[DWDWebManager sharedManager] getApi:@"plte/getAlert" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hideHud];
        
        //staval状态
        NSString *staval = responseObject[@"data"][@"staval"];
        if([staval isEqualToString:@"1"] || [staval isEqualToString:@"2"]){
            
            //assignment
            DWDIntAlertViewModel *model = [[DWDIntAlertViewModel alloc] init];
            model.icon = responseObject[@"data"][@"icon"];
            model.content = responseObject[@"data"][@"contents"];
            model.title = responseObject[@"data"][@"title"];
            model.btntext = responseObject[@"data"][@"btntext"];
            
            [[UIApplication sharedApplication].keyWindow addSubview:({
                DWDIntAlertView *alertViwe = [[DWDIntAlertView alloc] init];
                alertViwe.model = model;
                alertViwe;
            })];
            //若staval为1（开通状态）标记此菜单事件
            if ([staval isEqualToString:@"1"]) {
                NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, code];
                [[NSUserDefaults standardUserDefaults] setObject:code forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }else if ([staval isEqualToString:@"6"]){
            [handler createAlertControllerWithMessage:@"您还未加入任何班级，快去添加班级吧！"];
        }
        
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
         [hud hideHud];
        [handler createAlertControllerWithMessage:@"哎呦，网络开小差了~"];
        failure(error);
    }];
}


/**
 alertControlller
 */
- (void)createAlertControllerWithMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sureAction];
    [self.targetController presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 通知公告 API
/** 通知公告列表 */
+ (void)requestGetNoticeListWithCid:(NSNumber *)cid
                                sid:(NSNumber *)sid
                              pgIdx:(NSNumber *)pgIdx
                              pgCnt:(NSNumber *)pgCnt
                            success:(void(^)(NSArray *, BOOL))success
                            failure:(void(^)(NSError *error))failure{
    NSDictionary *params = @{@"cid": cid,
                             @"sid": sid,
                             @"pgIdx": pgIdx,
                             @"pgCnt": pgCnt};
    [[DWDWebManager sharedManager] getApi:@"notice/getList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *data = responseObject[@"data"];
        NSMutableArray *resultData = [NSMutableArray arrayWithCapacity:data.count];
        for (NSDictionary *dict in data) {
            DWDIntNoticeListModel *model = [DWDIntNoticeListModel yy_modelWithDictionary:dict];
            [resultData addObject:model];
        }
        //判断是否还有数据
        if ([pgCnt integerValue] > resultData.count) {
            success(resultData.copy, NO);
        }else{
            success(resultData.copy, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

/**
 *  删除通知公告
 */
+ (void)requestDeleteNoticeWithCid:(NSNumber *)cid
                               sid:(NSNumber *)sid
                          noticeId:(NSNumber *)noticeId
                           success:(void(^)())success
                           failure:(void(^)(NSError *error))failure{
    NSDictionary *params = @{@"cid": cid,
                             @"sid": sid,
                             @"noticeId": noticeId};
    [[DWDWebManager sharedManager] postApi:@"notice/delete" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

/**
 *  通知公告详情
 */
+ (void)requestGetNoticeDetailWithCid:(NSNumber *)cid
                                  sid:(NSNumber *)sid
                             noticeId:(NSNumber *)noticeId
                              success:(void(^)(DWDIntNoticeDetailModel *))success
                              failure:(void(^)(NSError *error))failure{
    NSDictionary *params = @{@"cid": cid,
                             @"sid": sid,
                             @"noticeId": noticeId};
    [[DWDWebManager sharedManager] getApi:@"notice/getEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *data = responseObject[@"data"];
        DWDIntNoticeDetailModel *model = [DWDIntNoticeDetailModel yy_modelWithDictionary:data];
        success(model);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

/**
 *  接收通知应答信息
 */
+ (void)requestReplyNoticeWithCid:(NSNumber *)cid
                              sid:(NSNumber *)sid
                         noticeId:(NSNumber *)noticeId
                             item:(NSNumber *)item
                          success:(void(^)())success
                          failure:(void(^)(NSError *error))failure{
    NSDictionary *params = @{@"cid": cid,
                             @"sid": sid,
                             @"noticeId": noticeId,
                             @"item": item};
    [[DWDWebManager sharedManager] postApi:@"notice/replyNotice" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}


#pragma mark - 消息中心 API
/**
 *  获取智能通讯录消息中心列表
 */
+ (void)requestSmartaddrmsgCenterGetListWithCid:(NSNumber *)cid
                                          pgIdx:(NSNumber *)pgIdx
                                          pgCnt:(NSNumber *)pgCnt
                                        success:(void(^)(NSArray *, BOOL))success
                                        failure:(void(^)(NSError *error))failure{
    NSDictionary *params = @{@"cid": cid,
                             @"pgIdx": pgIdx,
                             @"pgCnt": pgCnt};
    [[DWDWebManager sharedManager] getApi:@"smartaddrmsgcenter/getList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *data = responseObject[@"data"];
        NSMutableArray *resultData = [NSMutableArray arrayWithCapacity:data.count];
        for (NSDictionary *dict in data) {
             DWDIntMessageModel *model = [DWDIntMessageModel yy_modelWithDictionary:dict];
            [resultData addObject:model];
        }
        //判断是否还有数据
        if ([pgCnt integerValue] > resultData.count) {
            success(resultData.copy, NO);
        }else{
            success(resultData.copy, YES);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}
@end
