//
//  DWDInformationDataHandler.h
//  EduChat
//
//  Created by Gatlin on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//  资讯业务层

#import <Foundation/Foundation.h>
@class DWDInfoListModel,DWDWebPageModel;
@class DWDInfoExpertModel;
@interface DWDInformationDataHandler : NSObject

#pragma mark - Common
/**
 *  获取板块列表
 *
 *  @param custId  long 用户Id
 *  @param dcode   string 板块编码
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)requestGetPlateListWithCustId:(NSNumber *)custId
                                dcode:(NSString *)dcode
                              success:(void(^)(NSArray *array))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  获取页面基本信息
 *
 * @param custId long 用户Id
 * @param contentCode int 内容编码 √
 * @param contentId long 点赞内容id √
 */
+ (void)requestWebPageWithCustId:(NSNumber *)custId
                     contentCode:(NSNumber *)contentCode
                       contentId:(NSNumber *)contentId
                         success:(void(^)(DWDWebPageModel *model))success
                         failure:(void(^)(NSError *error))failure;
/**
 * 点赞
 * @param custId long 用户Id  √
 * @param contentCode int 内容编码 √
 * @param contentId long 点赞内容id √
 */
+ (void)requestPraiseAddWithCustId:(NSNumber *)custId
                       contentCode:(NSNumber *)contentCode
                         contentId:(NSNumber *)contentId
                           success:(void(^)(NSNumber *praiseCnt))success
                           failure:(void(^)(NSError *error))failure;
/**
 * 取消点赞
 * @param custId long 用户Id  √
 * @param contentCode int 内容编码 √
 * @param contentId long 点赞内容id √
 */
+ (void)requestPraiseDelWithCustId:(NSNumber *)custId
                       contentCode:(NSNumber *)contentCode
                         contentId:(NSNumber *)contentId
                           success:(void(^)(NSNumber *praiseCnt))success
                           failure:(void(^)(NSError *error))failure;
/**
 * 添加收藏
 * @param custId      long  用户Id  √
 * @param contentCode int   内容编码 √
 * @param contentId   long  内容id √
 */
+ (void)requestCollectAddWithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                            success:(void(^)(NSNumber *collectId))success
                            failure:(void(^)(NSError *error))failure;

/**
 *  取消收藏
 *
 *  @param custId    long     用户Id√
 *  @param collectId NSArray  收藏品Id√
 */
+ (void)requestCollectDelWithCustId:(NSNumber *)custId
                          collectId:(NSArray *)collectId
                            success:(void(^)(NSNumber *collectCnt))success
                            failure:(void(^)(NSError *error))failure;

/**
 * 获取评论列表
 * @param custId long 用户Id  √
 * @param contentCode int 内容编码 √
 * @param contentId long 评论对象id √
 * @param idx int 页码
 * @param cnt int 每页条数
 *
 * @return lot of ,i don't write out,youself look ba.
 */
+ (void)requestCommentListithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                                idx:(NSNumber *)idx
                                cnt:(NSNumber *)cnt
                            success:(void(^)(NSArray *dataSource, BOOL isHaveData))success
                            failure:(void(^)(NSError *error))failure;


/**
 * 评论
 * @param custId long 用户Id  √
 * @param contentCode int 内容编码 √
 * @param contentId long 评论对象id √
 * @param commentTxt String 评论内容 √
 * @param forCustId long 被评论客户id
 * @param forCommentId long 被评论的评论id
 *
 * @return commentCnt int 评论数
 * @return commentId long 评论id
 */
+ (void)requestCommentAddWithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                         commentTxt:(NSString *)commentTxt
                        forCustId:(NSNumber *)forCustId
                       forCommentId:(NSNumber *)forCommentId
                            success:(void(^)(NSNumber *commentCnt))success
                            failure:(void(^)(NSError *error))failure;
/**
 * 删除评论
 * @param custId long 用户Id  √
 * @param contentCode int 内容编码 √
 * @param contentId long 评论对象id √
 * @param commentId long 评论id √
 *
 * @return commentCnt int 评论数
 * @return commentId long 评论id
 */
+ (void)requestCommentDelWithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                          commentId:(NSNumber *)commentId
                            success:(void(^)(NSNumber *commentCnt))success
                            failure:(void(^)(NSError *error))failure;


/**
 * 分享
 * @param custId long 用户Id
 * @param contentCode int 内容编码 √
 * @param shareId long 分享品id √
 * @param shareType int 分享类型 √
 * @param objCode String 目标编码 √
 * @param platform String 设备类型
 * @param deviceId String 设备ID
 * @param phoneNum String 电话号码
 *
 */
+ (void)requestSharkSuccessWithCustId:(NSNumber *)custId
                         contentCode:(NSNumber *)contentCode
                             shareId:(NSNumber *)shareId
                           shareType:(NSNumber *)shareType
                             objCode:(NSString *)objCode
                            platform:(NSString *)platform
                            deviceId:(NSString *)deviceId
                            phoneNum:(NSString *)phoneNum
                             success:(void(^)(void))success
                             failure:(void(^)(void))failure;

#pragma mark - Other
#pragma mark - Reco
/**
 * 获取推荐首页信息
 * @param custId long 用户Id
 * @param plateCode int 板块类型
 * @param cnt int 每页条数
 */
+ (void)requestGetRecoHomePageInfoWithCustId:(NSNumber *)custId
                           plateCode:(NSNumber *)plateCode
                                 cnt:(NSNumber *)cnt
                             success:(void(^)(NSArray *bannersData, NSArray *commendsData, NSArray *cellFrameModels))success
                             failure:(void(^)(NSError *error))failure;

/**
 * 获取推荐列表
 * @param custId long 用户Id
 * @param plateCode int 板块类型
 * @param idx int 页码
 * @param cnt int 每页条数
 */
+ (void)requestGetRecoListWithCustId:(NSNumber *)custId
                           plateCode:(NSNumber *)plateCode
                                 idx:(NSNumber *)idx
                                 cnt:(NSNumber *)cnt
                             success:(void(^)(NSArray *commendsData, NSArray *cellFrameModels, BOOL isHaveData))success
                             failure:(void(^)(NSError *error))failure;


#pragma mark - News
/**
 * 获取新闻列表
 * @param custId long 用户Id
 * @param plateCode int 板块类型
 * @param idx int 页码
 * @param cnt int 每页条数
 */
+ (void)requestGetNewListWithCustId:(NSNumber *)custId
                           plateCode:(NSNumber *)plateCode
                                 idx:(NSNumber *)idx
                                 cnt:(NSNumber *)cnt
                             success:(void(^)(NSArray *newDataSource,BOOL isHaveData))success
                             failure:(void(^)(NSError *error))failure;
#pragma mark - Expert
/**
 *  获取专家首页
 *
 *  @param custId    用户Id
 *  @param plateCode 板块类型
 *  @param cnt       每页条数
 */
+ (void)requestGetExpertHomePageWithCustId:(NSNumber *)custId
                                 plateCode:(NSNumber *)plateCode
                                       cnt:(NSNumber *)cnt
                                   success:(void(^)(NSArray *banners, NSArray *experts, NSArray *hotArts))success
                                   failure:(void(^)(NSError *error))failure;

/**
 *  获取专家列表
 *
 *  @param custId    用户
 *  @param plateCode 板块类型
 *  @param idx       页码
 *  @param cnt       每页条数
 */
+ (void)requestGetExpertListWithCustId:(NSNumber *)custId
                             plateCode:(NSNumber *)plateCode
                                   idx:(NSNumber *)idx
                                   cnt:(NSNumber *)cnt
                               success:(void(^)(NSArray *array))success
                               failure:(void(^)(NSError *error))failure;

/**
 *  获取优能专家个人主页
 *
 *  @param custId   long 用户Id
 *  @param expertId long 专家Id
 *  @param cnt      int  页条数
 *  @param success       回调
 *  @param failure       回调
 */
+ (void)requestGetExpertPerHomepageWithCustId:(NSNumber *)custId
                                     expertId:(NSNumber *)expertId
                                          cnt:(NSNumber *)cnt
                                      success:(void(^)(DWDInfoExpertModel *expert))success
                                      failure:(void(^)(NSError *error))failure;

/**
 *  获取优能专家文章列表
 *
 *  @param custId   long 用户Id
 *  @param expertId long 专家Id
 *  @param idx      int  页码
 *  @param cnt      int  页条数
 *  @param success       回调
 *  @param failure       回调
 */
+ (void)requestGetExpertArticleListWithCustId:(NSNumber *)custId
                                     expertId:(NSNumber *)expertId
                                          idx:(NSNumber *)idx
                                          cnt:(NSNumber *)cnt
                                      success:(void(^)(NSArray *array))success
                                      failure:(void(^)(NSError *error))failure;

#pragma mark - Subscribe
/**
 *  获取订阅首页
 *
 *  @param custId    long 用户Id
 *  @param plateCode int  板块类型
 *  @param cnt       int  页条数
 *  @param success        回调
 *  @param failure        回调
 */
+ (void)requestGetSubscribeHomepageWithCustId:(NSNumber *)custId
                                    plateCode:(NSNumber *)plateCode
                                          cnt:(NSNumber *)cnt
                                      success:(void(^)(NSArray *subsArray, NSArray *lastArray, NSArray *comArray, NSNumber *subExpCnt))success
                                      failure:(void(^)(NSError *error))failure;

/**
 *  获取已订阅专家列表
 *
 *  @param custId    long 用户Id
 *  @param plateCode int  板块类型
 *  @param idx       int  页码
 *  @param cnt       int  页条数
 *  @param success        回调
 *  @param failure        回调
 */
+ (void)requestGetSubscribeExpertWithCustId:(NSNumber *)custId
                                  plateCode:(NSNumber *)plateCode
                                        idx:(NSNumber *)idx
                                        cnt:(NSNumber *)cnt
                                    success:(void(^)(NSArray *array))success
                                    failure:(void(^)(NSError *error))failure;

/**
 *  订阅
 *
 *  @param custId      long 用户Id
 *  @param contentCode int  内容编码
 *  @param contentId   long 订阅品id
 *  @param success          回调
 *  @param failure          回调
 */
+ (void)requestSubscribeAddWithCustId:(NSNumber *)custId
                          contentCode:(NSNumber *)contentCode
                            contentId:(NSNumber *)contentId
                              success:(void(^)(NSDictionary *dict))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  取消订阅
 *
 *  @param custId  long 用户Id
 *  @param subId   long 订阅id
 *  @param success      回调
 *  @param failure      回调
 */
+ (void)requestSubscribeDelWithCustId:(NSNumber *)custId
                                subId:(NSNumber *)subId
                              success:(void(^)(NSDictionary *dict))success
                              failure:(void(^)(NSError *error))failure;

/**
 *  获取订阅更新提示
 *
 *  @param custId  long 用户Id
 *  @param success      回调
 *  @param failure      回调
 */
+ (void)requestGetSubTipsWithCustId:(NSNumber *)custId
                           success:(void(^)(NSNumber *cnt))success
                           failure:(void(^)(NSError *error))failure;

/**
 *  清除订阅更新提示
 *
 *  @param custId  long 用户Id
 *  @param success      回调
 *  @param failure      回调
 */
+ (void)requestUpdateSubTipsWithCustId:(NSNumber *)custId
                           success:(void(^)(NSInteger status))success
                           failure:(void(^)(NSError *error))failure;

@end
