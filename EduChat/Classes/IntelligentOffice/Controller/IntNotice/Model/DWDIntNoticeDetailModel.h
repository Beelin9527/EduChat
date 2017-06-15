//
//  DWDIntNoticeDetailModel.h
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWDPhotoMetaModel, DWDIntPhotoInfoModel, DWDIntAuthorInfoModel, DWDContactModel;
@interface DWDIntNoticeDetailModel : NSObject
@property (nonatomic, strong) NSNumber *noticeId;
@property (nonatomic, copy) NSString *orgNm;
@property (nonatomic, copy) NSString *cNm;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *item;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray <DWDIntPhotoInfoModel *> *photos;
@property (nonatomic, strong) NSArray <DWDIntAuthorInfoModel *>*author;
@property (nonatomic, strong) NSArray <DWDContactModel *>*dataList;
@property (nonatomic, strong) NSArray <DWDContactModel *>*unDataList;

@property (nonatomic, assign) CGFloat cellContentHeight;
@property (nonatomic, assign) CGFloat cellHeaderHeight;
@end

/*
参数	类型	含义	说明
noticeId	Long	通知id
orgNm	String	发布人所在部门
cNm	String	发布人
createTime	String	发布时间	格式：YYYY-MM-DD hh:mm:ss
title	String	通知标题
type	Integer	通知类型	1 知道了；2 YES/NO
item	Integer	回复结果	0-未点击，1-知道了，2-YES，3-NO
content	String	通知内容
photos	PhotoInfoResult	相关附件集合
author	AuthorInfoResult	发布者对象信息
dataList	BasePhotoNameResult	已读/点击yes的用户头像集合
unDataList	BasePhotoNameResult	未读/点击no的用户头像集合
*/


/** photo model */
@interface DWDIntPhotoInfoModel : NSObject
@property (nonatomic, strong) NSNumber *photoId;
@property (nonatomic, copy) NSString *photoKey;
@property (nonatomic, strong) DWDPhotoMetaModel *photo;
@end

/** 发布者对象信息Model */
@interface DWDIntAuthorInfoModel : NSObject
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, copy) NSString *photoKey;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *addTime;
@property (nonatomic, strong) DWDPhotoMetaModel *photohead;
@end



