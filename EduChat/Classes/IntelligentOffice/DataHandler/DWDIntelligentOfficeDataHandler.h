//
//  DWDIntelligentOfficeDataHandler.h
//  EduChat
//
//  Created by Beelin on 16/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDWebManager.h"

#import "DWDIntAlertView.h"

@class DWDIntNoticeDetailModel;
@interface DWDIntelligentOfficeDataHandler : NSObject
/**
 *  菜单功能介绍
 *
 *  @param cid    操作人ID
 *  @param sid  学校ID
 *  @param mncd 模块菜单编号
 *  @param sta 模块菜单当前状态
 *  @param code 菜单编号
 *  @param targetController 弱引用控制器
 *
 *  @return DWDIntAlertViewModell
 */
+ (void)requestGetAlertWithCid:(NSNumber *)cid
                           sid:(NSNumber *)sid
                          mncd:(NSString *)code
                           sta:(NSNumber *)sta
          targetController:(UIViewController *)targetController
                       success:(void(^)())success
                       failure:(void(^)(NSError *error))failure;

#pragma mark - 通知公告 API
/**
 *  通知公告列表
 *
 *  @param cid   操作人ID
 *  @param sid   学校ID
 *  @param pgIdx 当前页数
 *  @param pgCnt 每页条数
 *  @param
 *  @param
 *
 *  @return
 */
+ (void)requestGetNoticeListWithCid:(NSNumber *)cid
                                sid:(NSNumber *)sid
                              pgIdx:(NSNumber *)pgIdx
                              pgCnt:(NSNumber *)pgCnt
                            success:(void(^)(NSArray *, BOOL))success
                            failure:(void(^)(NSError *error))failure;

/**
 *  删除通知公告
 *
 *  @param cid   操作人ID
 *  @param sid   学校ID
 *  @param noticeId 消息Id
 *  @param
 *  @param
 *
 *  @return
 */
+ (void)requestDeleteNoticeWithCid:(NSNumber *)cid
                               sid:(NSNumber *)sid
                          noticeId:(NSNumber *)noticeId
                           success:(void(^)())success
                           failure:(void(^)(NSError *error))failure;

/**
 *  通知公告详情
 *
 *  @param cid   操作人ID
 *  @param sid   学校ID
 *  @param noticeId 消息Id
 *
 *  @return
 */
+ (void)requestGetNoticeDetailWithCid:(NSNumber *)cid
                                  sid:(NSNumber *)sid
                             noticeId:(NSNumber *)noticeId
                              success:(void(^)(DWDIntNoticeDetailModel *))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  接收通知应答信息
 *
 *  @param cid   操作人ID
 *  @param sid   学校ID
 *  @param noticeId 消息Id
 *  @param item 0-未点击，1-知道了，2-YES，3-NO
 *
 *  @return
 */
+ (void)requestReplyNoticeWithCid:(NSNumber *)cid
                                  sid:(NSNumber *)sid
                             noticeId:(NSNumber *)noticeId
                                 item:(NSNumber *)item
                              success:(void(^)())success
                              failure:(void(^)(NSError *error))failure;

#pragma mark - 消息中心 API
/**
 *  获取智能通讯录消息中心列表
 *
 *  @param cid   操作人ID
 *  @param sid   学校ID
 *  @param pgIdx 当前页数
 *  @param pgCnt 每页条数
 *
 *  @return
 */
+ (void)requestSmartaddrmsgCenterGetListWithCid:(NSNumber *)cid
                                          pgIdx:(NSNumber *)pgIdx
                                          pgCnt:(NSNumber *)pgCnt
                                        success:(void(^)(NSArray *, BOOL))success
                                        failure:(void(^)(NSError *error))failure;
@end
