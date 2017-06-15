//
//  DWDInfoExpertModel.h
//  EduChat
//
//  Created by Catskiy on 16/8/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>
#import "DWDArticleModel.h"
//#import "DWDCommendModel.h"

/**
 *  专家标签
 */
@interface DWDInfoExpTagModel : NSObject

@property (nonatomic, strong) NSNumber *tagId;
@property (nonatomic, strong) NSString *name;

@end


/**
 *  最新文章
 */
@interface DWDInfoExpLastArtModel : NSObject

@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;

@end


/**
 *  专家
 */
@interface DWDInfoExpertModel : NSObject

/**  专家Id*/
@property (nonatomic, strong) NSNumber *custId;

/**  姓名*/
@property (nonatomic, strong) NSString *name;

/**  头像*/
@property (nonatomic, strong) NSString *photoKey;

/**  标签*/
@property (nonatomic, copy) NSArray<DWDInfoExpTagModel *> *tags;

/**  订阅数*/
@property (nonatomic, strong) NSNumber *subCnt;

/**  是否订阅*/
@property (nonatomic, assign) BOOL isSub;

/**  订阅ID*/
@property (nonatomic, strong) NSNumber *subId;

/**  是否收藏*/
@property (nonatomic, assign) BOOL isCollect;

/**  收藏ID*/
@property (nonatomic, strong) NSNumber *collectId;

/**  最近文章*/
@property (nonatomic, strong) DWDInfoExpLastArtModel *lastArticle;

/**  未读数*/
@property (nonatomic, strong) NSNumber *unreads;

/**  未读数*/
@property (nonatomic, strong) NSNumber *unreadCnt;

/**  简介*/
@property (nonatomic, strong) NSString *introduce;

/**  签名*/
@property (nonatomic, strong) NSString *sign;

/**  文章列表*/
@property (nonatomic, strong) NSMutableArray<DWDArticleModel *> *articles;

@end
