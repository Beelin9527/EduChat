//
//  HttpClient.h
//  iPenYou
//
//  Created by fanly on 14-7-21.
//  Copyright (c) 2015 dwd. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface HttpClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

/*
- (NSURLSessionDataTask *)api:(NSString *)api
                       params:(NSDictionary *)params
                      keyPath:(NSString *)keyPath
                forModelClass:(Class)modelClass
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)api:(NSString *)api
                      version:(NSString *)version
                       params:(NSDictionary *)params
                      keyPath:(NSString *)keyPath
                forModelClass:(Class)modelClass
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
*/

- (NSURLSessionDataTask *)getApi:(NSString *)api
                       params:(NSDictionary *) params
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)postApi:(NSString *)api
                           params:(NSDictionary *)params
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;



/*
- (NSURLSessionDataTask *)api:(NSString *)api
                      version:(NSString *)version
                       params:(NSDictionary *) params
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

*/

#pragma mark - 成长记录
/**
 *  上传成长记录
 *  AlbumRestService/addEntity
 */
- (NSURLSessionDataTask *)postGrowUpRecordWithParams:(NSDictionary *)params
                                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  成长记录上传评论
 */
- (NSURLSessionDataTask *)postGrowUpCommentWithParams:(NSDictionary *)params
                                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  成长记录请求数据
 *  AlbumRestService/getClassAlbumRecords
 */
- (NSURLSessionDataTask *)getGrowUpRequestWithClassId:(NSNumber *)classId
                                               custId:(NSNumber *)custId
                                            pageIndex:(NSInteger)pageIndex
                                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  成长记录添加赞
 */
- (NSURLSessionDataTask *)postGrowUpPraiseWithAlbumId:(NSNumber *)albumId
                                               custId:(NSNumber *)custId
                                             recordId:(NSNumber *)recordId
                                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  获取班级验证个人讯息 (short api)
 *
 *  @param custId  人
 *  @param success 成功
 *  @param failure 失败
 *
 *  @return 
 */
- (NSURLSessionDataTask *)getRequstClassVerifyInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


/**
 删除系统消息列表中的某条消息
short/msgctr/delete 
 short api
 */
- (NSURLSessionDataTask *)deleteClassVerifyInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


/**
 *  获取好友个人讯息
 *
 *  @param custId  好友custId
 *  @param success 成功block
 *  @param failure 失败block
 *
 *  @return xx
 */
- (NSURLSessionDataTask *)getUserInfo:(NSNumber *)custId success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  更新班级验证状态(就是更改状态,是拒绝还是允许)
 *
 *  @param params
 *  @param success
 *  @param failure
 *
 *  @return
 */
- (NSURLSessionDataTask *)postUpdateClassVerifyState:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 通知
/**
 *  获取通知详情
 */
- (NSURLSessionDataTask *)getClassNotificationDetail:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  更新班级通知的回复状态
 *
 *  @param params  参数列表
 *  @param success 成功block
 *  @param failure 失败block
 *
 *  @return ...
 */
- (NSURLSessionDataTask *)postUpdateClassNotificationReplyState:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  删除通知
 *  NoticeRestService/deleteEntity
 */
- (NSURLSessionDataTask *)postDeleteClassNotification:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  获取班级群组列表
 *
 *  @param params  参数
 *  @param success 成功
 *  @param failure 失败
 *
 *  @return ...
 */
- (NSURLSessionDataTask *)getClassGroupListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 接送中心
/**
 *  获取接送中心当前学生的状态
 */
- (NSURLSessionDataTask *)getPickUpCenterStudentsStatusWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  获取接送中心历史状态以及数据
 */
- (NSURLSessionDataTask *)getPickUpCenterTimeLineStudentsStatusWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  接送中心
 *  确认按钮点击,发送请求至服务器
 */
- (NSURLSessionDataTask *)postPickUpCenterStatusUpdateWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  班级验证 回复验证消息
 */

- (NSURLSessionDataTask *)postClassVerifyReplyVerifyInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  添加假条
 *  NoteRestService/addEntity
 */
- (NSURLSessionDataTask *)postAddClassLeavePaperWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  查找孩子
 * AcctRestService/getMyChildrenList
 */
- (NSURLSessionDataTask *)getChildListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 假条
/**
 *  获取假条详情
 * NoteRestService/getEntity
 */
- (NSURLSessionDataTask *)getLeavePaperDetailWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  修改假条状态
 * NoteRestService/approveNote
 */
- (NSURLSessionDataTask *)postApproveNoteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  第一次获取的按钮状态
 * EduInformationRestService/getVisitStat
 */
- (NSURLSessionDataTask *)getInfomationInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 咨询
/**
 *  获取咨询评论
 * 	EduInformationRestService/getCommentList
 */
- (NSURLSessionDataTask *)getInfomationCommentsWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  咨询点赞添加
 * 	EduInformationRestService/addPraise
 */
- (NSURLSessionDataTask *)postInfomationPraiseWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  咨询点赞添加
 * 	EduInformationRestService/deletePraise
 */
- (NSURLSessionDataTask *)postInfomationPraiseDeleteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
/**
 *  咨询收藏添加
 * 	CollectRestService/addEntity
 */
- (NSURLSessionDataTask *)postInfomationCollectWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  咨询收藏删除
 * 	CollectRestService/deleteEntity
 */
- (NSURLSessionDataTask *)postInfomationCollectDeleteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  咨询评论添加
 * 	EduInformationRestService/addComment
 */
- (NSURLSessionDataTask *)postInfomationCommentWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 *  咨询评论删除
 * EduInformationRestService/deleteCommend
 */
- (NSURLSessionDataTask *)postInfomationCommentDeleteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


/**
 *  添加阅读量
 *  EduInformationRestService/addRead
 */
- (NSURLSessionDataTask *)postInviteFriendsListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 邀请朋友(by SMS)
/**
 获取所有非平台好友 (short Api)

 acct/unRegList.action
 */
- (NSURLSessionDataTask *)postInviteContactsListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 发送好友邀请(SMS) (short Api)
 
 sms/inv.action
 */
- (NSURLSessionDataTask *)postContactInviteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 智能通讯录
/**
 获取某个学校所有分组的成员列表情况 (short Api)
 
 smartAddr/getUsersByGpId
 */
- (NSURLSessionDataTask *)getSchoolGroupMembersWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 获取某个学校所有分组的成员列表情况 (short Api)
 
 ClassMemberRestService/getStudents
 */
- (NSURLSessionDataTask *)getClassStudentsWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 班级菜单功能的Html获取
 
 plte/getH5
 */
- (NSURLSessionDataTask *)getClassMenuH5WithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 获取某个学校所有分组列表 (short Api)
 
 smartAddr/get
 */
- (NSURLSessionDataTask *)getSchoolGroupListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 学生名单删除学生 (short Api)

 clsstu/delete
 */
- (NSURLSessionDataTask *)postDeleteStudentsWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 临时聊天 / 群组
/**
 临时聊天群组聊天创建群组
 GroupRestService/addGroup
 */
- (NSURLSessionDataTask *)postAddGroupChatWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 临时单人聊天请求
 FriendVerifyRestService/temporaryFriend
 */
- (NSURLSessionDataTask *)postAddTempFriendChatWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 网络请求类本身相关
/**
 *  根据api字符串取消请求task
 *
 *  @param api api的字符串 无base url 格式:xxx/xxx
 */
- (void)cancelTaskWithApi:(NSString *)api;



#pragma mark - ************************* 新地址 short之后 *************************
#pragma mark - 检查更新
/**
 *  检查更新
 */
- (NSURLSessionDataTask *)getIfNeedsUpdateVersion:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end

