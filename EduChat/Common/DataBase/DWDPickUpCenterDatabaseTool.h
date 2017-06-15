//
//  DWDPickUpCenterClient.h
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDSingleton.h"

@class DWDPickUpCenterDataBaseModel;
@class DWDPickUpCenterStudentsCountModel;
@interface DWDPickUpCenterDatabaseTool : NSObject

DWDSingletonH(Manager)



#pragma mark - /****** 教师端 ******/
/****** 教师端Select ******/

- (NSArray *)selectWhichDate:(NSString *)dateStr
                        type:(NSNumber *)type
                       index:(NSNumber *)index
  teacherDataBaseWithClassId:(NSNumber *)classId;

/**
 取得按时间排序当天最后一条消息
 */
- (DWDPickUpCenterDataBaseModel *)selectLastDataWithClassId:(NSNumber *)classId;

//查询时间轴详情 无未确认状态不显示

- (NSArray *)selectTimelineWhichDate:(NSString *)dateStr
                                type:(NSNumber *)type
          teacherDataBaseWithClassId:(NSNumber *)classId;

- (NSArray *)selectTeacherList;

/****** 教师端Update ******/

- (void)subTeacherListBadgeNumberWithClassId:(NSNumber *)classId
                                     subNumber:(NSNumber *)subNumber;

/**
 *  插入数据缓存到日历的请求缓存表中
 */
- (void)insertCalendarRequest:(NSArray *)data
                         date:(NSString *)date
                  withClassId:(NSNumber *)classId;

/**
 *  选择日历请求数据缓存
 */
- (NSArray *)selectCalendarWithDate:(NSString *)date
                        withClassId:(NSNumber *)classId;


#pragma mark - /****** 家长端 ******/
/****** 家长端Select ******/

- (NSArray *)selectWhichDate:(NSString *)dateStr
    ChildDataBaseWithClassId:(NSNumber *)classId;

- (NSArray *)selectChildList;

/****** 家长端Update ******/

- (void)plusOneChildListlBadgeNumber:(NSNumber *)classId;

- (void)subChildListBadgeNumberWithClassId:(NSNumber *)classId
                                   subNumber:(NSNumber *)subNumber;


/*
 
 红点计数
 
 */
- (void)badgeNumberNeedSub;
- (void)badgeNumberDontNeedSub;

- (int)getBadgeNumberWithClassId:(NSNumber *)classId listTableName:(NSString *)tableName;


@end
