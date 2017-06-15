//
//  DWDInformationDataHandler.m
//  EduChat
//
//  Created by Gatlin on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInformationDataHandler.h"
#import "DWDInfoPlateModel.h"

#import "HttpClient.h"
#import "DWDCommendModel.h"
#import "DWDArticleModel.h"
#import "DWDArticleFrameModel.h"
#import "DWDInfoBannerModel.h"
#import "DWDInfomationCommentModel.h"
#import "DWDInfoExpertModel.h"
#import "DWDWebPageModel.h"

#import <YYModel.h>
@implementation DWDInformationDataHandler
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
                              failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    dcode ? [params setObject:dcode forKey:@"dcode"] : [params setObject:@"000000" forKey:@"dcode"];
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"plate/list" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [responseObject[@"data"] count]; i ++) {
            DWDInfoPlateModel *model = [DWDInfoPlateModel yy_modelWithDictionary:responseObject[@"data"][i]];
            [dataArray addObject:model];
        }
        if (success) success(dataArray);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) failure(error);
    }];
}

/**
 *  获取页面基本信息
 */
+ (void)requestWebPageWithCustId:(NSNumber *)custId
                     contentCode:(NSNumber *)contentCode
                       contentId:(NSNumber *)contentId
                         success:(void(^)(DWDWebPageModel *))success
                         failure:(void(^)(NSError *))failure
{
    if (!contentCode || !contentId) return;
    NSDictionary *dict = @{
                           @"custId":custId ? custId :[NSNull null],
                           @"contentCode": contentCode,
                           @"contentId": contentId};
    [[DWDWebManager sharedManager]
     getApi:@"webpage/get"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSDictionary *dict = responseObject[@"data"];
         DWDWebPageModel *model = [DWDWebPageModel yy_modelWithDictionary:dict];
         success(model);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error);
     }];
 
}

/**
 * 点赞
 */

+ (void)requestPraiseAddWithCustId:(NSNumber *)custId
                       contentCode:(NSNumber *)contentCode
                         contentId:(NSNumber *)contentId
                           success:(void(^)(NSNumber *))success
                           failure:(void(^)(NSError *))failure
{
    if (!custId || !contentCode || !contentId) return;
    NSDictionary *dict = @{
                           @"custId":custId,
                           @"contentCode": contentCode,
                           @"contentId": contentId};
    [[DWDWebManager sharedManager]
     postApi:@"praise/add"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSNumber *praiseCnt = responseObject[@"data"];
         success(praiseCnt);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) failure(error);
     }];
}
/**
 * 取消点赞
 */
+ (void)requestPraiseDelWithCustId:(NSNumber *)custId
                       contentCode:(NSNumber *)contentCode
                         contentId:(NSNumber *)contentId
                           success:(void(^)(NSNumber *))success
                           failure:(void(^)(NSError *))failure
{
     if (!custId || !contentCode || !contentId) return;
    NSDictionary *dict = @{
                           @"custId":custId,
                           @"contentCode": contentCode,
                           @"contentId": contentId};
    [[DWDWebManager sharedManager]
     postApi:@"praise/del"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSNumber *praiseCnt = responseObject[@"data"];
         success(praiseCnt);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) failure(error);
     }];
}

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
                            failure:(void(^)(NSError *error))failure
{
    if (custId == nil) return;
    NSDictionary *dict = @{@"custId" : custId,
                           @"contentCode" : contentCode,
                           @"contentId": contentId};
    [[DWDWebManager sharedManager]
    postApi:@"collect/add"
    params:dict
    success:^(NSURLSessionDataTask *task, id responseObject) {
        NSNumber *collectId = responseObject[@"data"][@"collectId"];
        success(collectId);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) failure(error);
    }];
}

/**
 *  取消收藏
 *
 *  @param custId    long     用户Id√
 *  @param collectId NSArray  收藏品Id√
 */
+ (void)requestCollectDelWithCustId:(NSNumber *)custId
                          collectId:(NSArray *)collectId
                            success:(void(^)(NSNumber *collectCnt))success
                            failure:(void(^)(NSError *error))failure
{
    if (custId == nil) return;
    NSDictionary *dict = @{@"custId" : custId,
                           @"collectId": collectId};
    [[DWDWebManager sharedManager]
     postApi:@"collect/del"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         if (success) success(responseObject);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         if (failure) failure(error);
     }];
}

/**
 * 获取评论列表
 */
+ (void)requestCommentListithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                                idx:(NSNumber *)idx
                                cnt:(NSNumber *)cnt
                            success:(void(^)(NSArray *,BOOL))success
                            failure:(void(^)(NSError *))failure
{
   if (!cnt) cnt = @10;
    
    NSDictionary *dict = @{
                           @"custId":custId ? custId : [NSNull null],
                           @"contentCode": contentCode,
                           @"contentId": contentId,
                           @"idx": idx ? idx : @1,
                           @"cnt": cnt};
    [[DWDWebManager sharedManager]
     getApi:@"comment/list"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *data = responseObject[@"data"];
         NSMutableArray *commentsDataSource = [NSMutableArray arrayWithCapacity:data.count];
         for (NSDictionary *dict in data) {
             DWDInfomationCommentModel *model = [DWDInfomationCommentModel yy_modelWithDictionary:dict];
             [commentsDataSource addObject:model];
         }
         //判断是否还有数据
         if ([cnt integerValue] > commentsDataSource.count) {
             success(commentsDataSource.copy, NO);
         }else{
             success(commentsDataSource.copy, YES);
         }

     } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) failure(error);
     }];
}

/**
 * 评论
 */
+ (void)requestCommentAddWithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                         commentTxt:(NSString *)commentTxt
                        forCustId:(NSNumber *)forCustId
                       forCommentId:(NSNumber *)forCommentId
                            success:(void(^)(NSNumber *commentCnt))success
                            failure:(void(^)(NSError *error))failure
{
     if (!custId || !contentCode || !contentId) return;
    NSDictionary *dict = @{
                           @"custId":custId,
                           @"contentCode": contentCode,
                           @"contentId": contentId,
                           @"commentTxt":commentTxt,
                           @"forCustId": forCustId ? forCustId : [NSNull null],
                           @"forCommentId": forCommentId ? forCommentId : [NSNull null]};
    [[DWDWebManager sharedManager]
     postApi:@"comment/add"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSNumber *commentCnt = responseObject[@"data"][@"commentCnt"];
         success(commentCnt);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error);
     }];

}

/**
 * 删除评论
 */
+ (void)requestCommentDelWithCustId:(NSNumber *)custId
                        contentCode:(NSNumber *)contentCode
                          contentId:(NSNumber *)contentId
                          commentId:(NSNumber *)commentId
                            success:(void(^)(NSNumber *commentCnt))success
                            failure:(void(^)(NSError *error))failure
{
     if (!custId || !contentCode || !contentId) return;
    NSDictionary *dict = @{
                           @"custId":custId,
                           @"contentCode": contentCode,
                           @"contentId": contentId,
                           @"commentId": commentId };
    [[DWDWebManager sharedManager]
     postApi:@"comment/del"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSNumber *commentCnt = responseObject[@"data"][@"commentCnt"];
         success(commentCnt);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure(error); 
     }];
}
/**
 * 分享
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
                             failure:(void(^)(void))failure
{
    NSDictionary *dict = @{
                           @"custId": custId ? custId : [NSNull null],
                           @"contentCode": contentCode,
                           @"shareId": shareId,
                           @"shareType": shareType,
                           @"objCode":objCode ? objCode : [NSNull null],
                           @"platform":  platform ? platform : [NSNull null],
                           @"deviceId":  deviceId ? deviceId : [NSNull null],
                           @"phoneNum": phoneNum ? phoneNum : [NSNull null] };
    [[DWDWebManager sharedManager]
     postApi:@"share/add"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         success();
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         failure();
     }];
 
}
#pragma mark - Other
- (id)isNullWithObj:(id)obj
{
    return obj ? obj : [NSNull null];
}

#pragma mark - Reco
+ (void)requestGetRecoHomePageInfoWithCustId:(NSNumber *)custId
                           plateCode:(NSNumber *)plateCode
                                 cnt:(NSNumber *)cnt
                             success:(void (^)(NSArray *, NSArray *, NSArray *))success
                             failure:(void (^)(NSError *))failure
{
    NSDictionary *dict = @{
                           @"custId":custId ? custId : [NSNull null],
                           @"plateCode": plateCode,
                           @"cnt": cnt};
    [[DWDWebManager sharedManager]
     getApi:@"commend/getHomepage"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *banners = responseObject[@"data"][@"banners"];
         NSMutableArray *bannersData = [NSMutableArray arrayWithCapacity:banners.count];
         for (NSDictionary *dict in banners) {
             DWDInfoBannerModel *model = [DWDInfoBannerModel yy_modelWithJSON:dict];
             [bannersData addObject:model];
         }
         
         NSArray *commends = responseObject[@"data"][@"commends"];
         NSMutableArray *commendsData = [NSMutableArray arrayWithCapacity:commends.count];
         NSMutableArray *cellFrameModels = [NSMutableArray arrayWithCapacity:commends.count];
         for (NSDictionary *dict in commends) {
             
              DWDCommendModel *model = [DWDCommendModel yy_modelWithJSON:dict];
             [commendsData addObject:model];
            
             //计算高度
             if ([model.contentCode isEqualToNumber:@4]) {
                 DWDArticleFrameModel *fmodel = [[DWDArticleFrameModel alloc] init];
                 fmodel.articleModel = model.New;
                 [cellFrameModels addObject:fmodel];
             }else if ([model.contentCode isEqualToNumber:@8]){
                 DWDArticleFrameModel *fmodel = [[DWDArticleFrameModel alloc] init];
                 fmodel.articleModel = model.article;
                 [cellFrameModels addObject:fmodel];
             }else if ([model.contentCode isEqualToNumber:@7]){
                 [cellFrameModels addObject:[NSNull null]];
             }

         }
         success(bannersData.copy, commendsData.copy, cellFrameModels.copy);
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
       if (failure) failure(error);
     }];
    
}

+ (void)requestGetRecoListWithCustId:(NSNumber *)custId
                           plateCode:(NSNumber *)plateCode
                                 idx:(NSNumber *)idx
                                 cnt:(NSNumber *)cnt
                             success:(void(^)(NSArray *commendsData,  NSArray *cellFrameModels, BOOL isHaveData))success
                             failure:(void(^)(NSError *error))failure
{
    NSDictionary *dict = @{
                           @"custId":custId ? custId : [NSNull null],
                           @"plateCode": plateCode,
                           @"idx":idx,
                           @"cnt": cnt};
    [[DWDWebManager sharedManager]
     getApi:@"commend/list"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *commends = responseObject[@"data"][@"commends"];
         NSMutableArray *commendsData = [NSMutableArray arrayWithCapacity:commends.count];
         NSMutableArray *cellFrameModels = [NSMutableArray arrayWithCapacity:commends.count];
         for (NSDictionary *dict in commends) {
             DWDCommendModel *model = [DWDCommendModel yy_modelWithJSON:dict];
             [commendsData addObject:model];
             
             //计算高度
             if ([model.contentCode isEqualToNumber:@4]) {
                 DWDArticleFrameModel *fmodel = [[DWDArticleFrameModel alloc] init];
                 fmodel.articleModel = model.New;
                 [cellFrameModels addObject:fmodel];
             }else if ([model.contentCode isEqualToNumber:@8]){
                 DWDArticleFrameModel *fmodel = [[DWDArticleFrameModel alloc] init];
                 fmodel.articleModel = model.article;
                 [cellFrameModels addObject:fmodel];
             }else if ([model.contentCode isEqualToNumber:@7]){
                 [cellFrameModels addObject:[NSNull null]];
             }
         }
         
         //判断是否还有数据
         if ([cnt integerValue] > commendsData.count) {
             success(commendsData.copy, cellFrameModels.copy, NO);
         }else{
              success(commendsData.copy,  cellFrameModels.copy, YES);
         }
        
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) failure(error);
     }];
}


#pragma mark - News
/**
 * 获取新闻列表
 */
+ (void)requestGetNewListWithCustId:(NSNumber *)custId
                          plateCode:(NSNumber *)plateCode
                                idx:(NSNumber *)idx
                                cnt:(NSNumber *)cnt
                            success:(void(^)(NSArray *newDataSource, BOOL isHaveData))success
                            failure:(void(^)(NSError *error))failure
{
    NSDictionary *dict = @{
                           @"custId":custId ? custId : [NSNull null],
                           @"plateCode": plateCode,
                           @"idx":idx,
                           @"cnt": cnt};
    [[DWDWebManager sharedManager]
     getApi:@"news/list"
     params:dict
     success:^(NSURLSessionDataTask *task, id responseObject) {
         NSArray *data = responseObject[@"data"];
         NSMutableArray *newData = [NSMutableArray arrayWithCapacity:data.count];
         for (NSDictionary *dict in data) {
             DWDArticleModel *newModel = [DWDArticleModel yy_modelWithJSON:dict];
             
             DWDArticleFrameModel *af = [[DWDArticleFrameModel alloc] init];
             af.articleModel = newModel;
             
             [newData addObject:af];
         }
         
         //判断是否还有数据
         if ([cnt integerValue] > newData.count) {
             success(newData.copy, NO);
         }else{
             success(newData.copy, YES);
         }
        
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         if (failure) failure(error);
     }];
 
}

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

{
    NSMutableDictionary *params = @{@"plateCode":plateCode,
                                    @"cnt":cnt}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"uenonExpert/getHomepage" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *experts = responseObject[@"data"][@"ranks"];
        NSArray *hotArtic = responseObject[@"data"][@"articles"];
        NSArray *banners = responseObject[@"data"][@"banners"];

        NSMutableArray *headerDataArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *expDataArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *hotDataArray = [NSMutableArray arrayWithCapacity:0];
        
        for (NSDictionary *dict in banners) {
            DWDInfoBannerModel *model = [DWDInfoBannerModel yy_modelWithJSON:dict];
            [headerDataArray addObject:model];
        }
        for (NSDictionary *expDic in experts) {
            [expDataArray addObject:[DWDInfoExpertModel yy_modelWithJSON:expDic]];
        }
        for (NSDictionary *hotDic in hotArtic) {
            DWDArticleFrameModel *fmodel = [[DWDArticleFrameModel alloc] init];
            fmodel.articleModel = [DWDArticleModel yy_modelWithJSON:hotDic];
            [hotDataArray addObject:fmodel];
        }
        success(headerDataArray, expDataArray, hotDataArray);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

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

{
    NSMutableDictionary *params = @{@"plateCode":plateCode,
                                    @"idx":idx,
                                    @"cnt":cnt}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"uenonExpert/list" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *experts = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *expDic in responseObject[@"data"]) {
            DWDInfoExpertModel *expert = [DWDInfoExpertModel yy_modelWithJSON:expDic];
            [experts addObject:expert];
        }
        success(experts);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];

}

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
                                      failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = @{@"expertId":expertId ? expertId : [NSNull null],
                                    @"cnt":cnt}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"uenonExpert/getPerHomepage" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        DWDInfoExpertModel *expert = [DWDInfoExpertModel yy_modelWithJSON:responseObject[@"data"]];
        
        NSMutableArray *articles = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *articleDic in responseObject[@"data"][@"articles"]) {
            DWDArticleModel *article = [DWDArticleModel yy_modelWithJSON:articleDic];
//            DWDCommendModel *listModel = [[DWDCommendModel alloc] init];
//            listModel.contentCode = @8;
//            listModel.commendId = article.infoId;
//            listModel.article = article;
            [articles addObject:article];
        }
        expert.articles = articles;
        success(expert);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

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
                                      failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = @{@"expertId":expertId ? expertId : [NSNull null],
                                    @"idx":idx,
                                    @"cnt":cnt}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"uenonExpertArticle/list" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *articles = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *articleDic in responseObject[@"data"]) {
            DWDArticleModel *article = [DWDArticleModel yy_modelWithJSON:articleDic];
            [articles addObject:article];
        }
        success(articles);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

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
                                      failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = @{@"plateCode":plateCode,
                                    @"cnt":cnt}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"sub/getHomepage" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *subExps = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *lasts = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *comExps = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dict in responseObject[@"data"][@"subs"]) {
            DWDInfoExpertModel *expert = [DWDInfoExpertModel yy_modelWithJSON:dict];
            [subExps addObject:expert];
        }
        for (NSDictionary *dict in responseObject[@"data"][@"lastUpdates"]) {
            DWDArticleModel *article = [DWDArticleModel yy_modelWithJSON:dict[@"lastArticle"]];
            article.unreadCnt = dict[@"unreadCnt"];
            [lasts addObject:article];
        }
        for (NSDictionary *dict in responseObject[@"data"][@"commends"]) {
            DWDInfoExpertModel *expert = [DWDInfoExpertModel yy_modelWithJSON:dict];
            [comExps addObject:expert];
        }
        success(subExps, lasts, comExps, responseObject[@"data"][@"subExpertCnt"]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

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
                                    failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = @{@"plateCode":plateCode,
                                    @"idx":idx,
                                    @"cnt":cnt}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] getApi:@"subExpert/list" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *experts = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *expDict in responseObject[@"data"]) {
            DWDInfoExpertModel *expert = [DWDInfoExpertModel yy_modelWithJSON:expDict];
            [experts addObject:expert];
        }
        success(experts);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

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
                              failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = @{@"contentCode":contentCode,
                                    @"contentId":contentId}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] postApi:@"sub/add" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

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
                               failure:(void(^)(NSError *error))failure
{
    NSMutableDictionary *params = @{@"subId":subId}.mutableCopy;
    custId ? [params setObject:custId forKey:@"custId"] : nil;
    
    [[DWDWebManager sharedManager] postApi:@"sub/del" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

/**
 *  获取订阅更新提示
 *
 *  @param custId  long 用户Id
 *  @param success      回调
 *  @param failure      回调
 */
+ (void)requestGetSubTipsWithCustId:(NSNumber *)custId
                            success:(void(^)(NSNumber *cnt))success
                            failure:(void(^)(NSError *error))failure
{
    NSDictionary *params = @{@"cid":custId ? custId : [NSNull null],
                             @"pcode":@4};
    [[DWDWebManager sharedManager] getApi:@"sub/getSubTips" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject[@"data"][@"cnt"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

/**
 *  清除订阅更新提示
 *
 *  @param custId  long 用户Id
 *  @param success      回调
 *  @param failure      回调
 */
+ (void)requestUpdateSubTipsWithCustId:(NSNumber *)custId
                               success:(void(^)(NSInteger status))success
                               failure:(void(^)(NSError *error))failure
{
    NSDictionary *params = @{@"cid":custId ? custId : [NSNull null],
                             @"pcode":@4};
    [[DWDWebManager sharedManager] postApi:@"sub/updSubTips" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success((NSInteger)responseObject[@"data"][@"sts"]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

@end
