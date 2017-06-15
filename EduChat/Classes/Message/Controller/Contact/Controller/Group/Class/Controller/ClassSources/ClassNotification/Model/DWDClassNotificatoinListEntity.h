//
//  DWDClassNotificatoinListEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//  班级通知列表 entity

#import <Foundation/Foundation.h>

@interface DWDClassNotificatoinListEntity : NSObject

@property (copy, nonatomic) NSString *creatTime;
@property (strong, nonatomic) NSNumber *noticeId;
@property (strong, nonatomic) NSNumber *readed;
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *type;
@property (nonatomic, copy) NSString *firstPhoto;

- (id)initWithDict:(NSDictionary *)dict;

+ (NSMutableArray *)initWithArray:(NSArray *)array;
@end


/*
 private java.lang.String	creatTime
 发布时间
 private long	noticeId
 通知id
 private int	readed
 是否已查看
 1-已阅
 2-未阅
 private java.lang.String	title
 通知标题
 private int	type
 通知类型
 1-知道了
 2-YES/NO
*/