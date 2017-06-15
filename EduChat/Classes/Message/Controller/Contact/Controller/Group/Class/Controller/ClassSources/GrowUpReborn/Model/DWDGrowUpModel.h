//
//  DWDGrowUpModel.h
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 DWD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDGrowUpModelAuthor : NSObject //作者
@property (nonatomic, strong) NSNumber *authorId; //作者ID
@property (nonatomic, copy) NSString *name; //作者名字
@property (nonatomic, copy) NSString *photoKey; //作者头像photoKey
@property (nonatomic, copy) NSString *addTime;  //发布时间
@end

@interface DWDGrowUpModelRecord : NSObject //内容
@property (nonatomic, copy) NSString *address;  //记录发生地址
@property (nonatomic, strong) NSNumber *albumId; //相册id
@property (nonatomic, strong) NSNumber *albumsType; //相册类型
@property (nonatomic, copy) NSString *content;  //内容
@property (nonatomic, strong) NSNumber *logId;  //相册记录id
@end

@interface DWDGrowUpModelPhoto : NSObject //图片
@property (nonatomic, strong) NSNumber *photoId; //图片id
@property (nonatomic, copy) NSString *photokey; //图片地址
@property (nonatomic, strong) DWDPhotoMetaModel *photo; //图片元数据
@property (nonatomic, copy) NSString *photoname; //图片名字
@end


@interface DWDGrowUpModelPraise<NSCopying> : NSObject //点赞
@property (nonatomic, strong) NSNumber *custId; //点赞人id
@property (nonatomic, copy) NSString *nickname; //点赞人名字
@end

@interface DWDGrowUpModelComment : NSObject //评论
@property (nonatomic, strong) NSNumber *commentId; //评论id

@property (nonatomic, strong) NSNumber *custId; //评论人id
@property (nonatomic, copy) NSString *nickname; //评论人名字
@property (nonatomic, strong) NSNumber *forCustId; //被回复id
@property (nonatomic, copy) NSString *forNickname; //被回复名字

@property (nonatomic, copy) NSString *photokey; //回复人photokey
@property (nonatomic, copy) NSString *commentTxt; //回复内容
@property (nonatomic, copy) NSString *addtime; //回复时间
@end


@interface DWDGrowUpModel : NSObject

@property (nonatomic, strong) DWDGrowUpModelAuthor *author; //作者信息
@property (nonatomic, strong) DWDGrowUpModelRecord *record; //内容信息
@property (nonatomic, strong) NSArray<DWDGrowUpModelPhoto *> *photos; //图片信息
@property (nonatomic, strong) NSArray<DWDGrowUpModelPraise *> *praises; //点赞信息
@property (nonatomic, strong) NSArray<DWDGrowUpModelComment *> *comments; //评论信息

@end
