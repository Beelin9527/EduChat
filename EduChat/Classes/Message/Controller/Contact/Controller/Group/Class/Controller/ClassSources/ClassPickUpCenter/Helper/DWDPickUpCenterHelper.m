//
//  DWDPickUpCenterHelper.m
//  EduChat
//
//  Created by KKK on 16/6/27.
//  Copyright © 2016年 dwd. All rights reserved.
//


#import "DWDPickUpCenterHelper.h"
#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDPickUpCenterTotalStudentsModel.h"
#import "DWDPickUpCenterDataBaseModel.h"

#import "NSString+extend.h"
#import "NSDate+dwd_dateCategory.h"

@implementation DWDPickUpCenterHelper

/**
 当天数据的缓存逻辑
 首先在进入的时候取得数据库中最后一条按时间排序的消息数据
 - 数据存在 不是当天 发请求
 - 数据不存在 发请求
 
 数据存在   需要能不能取到nsuserdefaults里面的缓存
 - 取不到 发请求
 - 能取到 判断是不是当天
 - — 不是当天 发请求
 - — 是当天 判断是不是当次
 - — — 不是当次 发请求
 - — — 是当次 (依据):跟最后一条消息数据匹配 全能配得上 直接返回数据
 */
+ (BOOL)isNecessaryToNewRequestWithClassId:(NSNumber *)classId {
    /*************
     
     deadline 后端也没办法 暂时废弃
     deadline 后端也没办法 暂时废弃
     deadline 后端也没办法 暂时废弃
     deadline 后端也没办法 暂时废弃
     deadline 后端也没办法 暂时废弃
     deadline 后端也没办法 暂时废弃
     
     *************/
    return YES;
    /***
     逻辑间隔
     先取请求缓存,如果没有请求缓存说明是第一次进入,直接发请求,如果不是当天的 直接发请求
     取出deadLine deadline做预处理 如果当前的时间已经超过了deadline的时间 那么直接发请求
     <deadline预处理>如果是-1 则把他变成23:59
     ***/
    NSString *key = [DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey stringByAppendingString:[NSString stringWithFormat:@"_%@_%@", classId, [DWDCustInfo shared].custId]];
    
     NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    DWDPickUpCenterTotalStudentsModel *totalModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //取不到 发请求
    if (totalModel == nil) {
        return YES;
    }
    //能取到 判断是不是当天 不是当天 发请求
    if (![totalModel.dateTime isToday]) {
        return YES;
    }
//#error 判断deadline
//    if ([totalModel.deadline isEqualToString:@"-1"]) {
//        totalModel.deadline = @"23:59:59";
//    }
    if ([totalModel.deadline compare:[NSDate date]] == NSOrderedAscending)
        return YES;
    
    
    /***
     逻辑间隔
     请求获得的是当天的已经确定,当前时间也在deadline线以内 那他妈还要搞什么???
     还有一种情况 当时间未到deadline但是下一次的消息已经过来的时候 也要发请求
        这种情况的条件是
        1.时间未到deadline
        2.请求的缓存是当天
        3.最后消息的type和请求的type不相同
            有一种情况是这样:你没有收到消息,但是你已经获得了真正当前时间的请求,如何进行这种判断? 
                就是收到消息的时间比获取请求的时间要低<终于想对了 很关键>
                    最后总结就是:1.时间未到deadline 2.type不一样 3.请求的时间<收到消息的时间
     
     行为:
     取得当天的最后一条数据(按时间排序)
     ***/
    DWDPickUpCenterDataBaseModel *dbModel = [[DWDPickUpCenterDatabaseTool sharedManager] selectLastDataWithClassId:classId];
//    如果是nil
//    代表今天一次消息都没有 但是从上面没有return
//    说明请求的缓存是对的 但是今天没有消息过来 直接返回no 不需要发请求
    if (dbModel == nil)
        return NO;
    //不是当天 不用管啊 也是NO
    //是当天 判断是不是当次  (依据):跟最后一条消息数据匹配 全能配得上 也是NO
    if (![totalModel.type isEqualToNumber:dbModel.type] || ![totalModel.index isEqualToNumber:dbModel.index]) {
        return YES;
    }
    //不是当次
    //如果是请求中的数据的次数<消息中的数据 发请求
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    });
    
//    NSString *currentDateString = [formatter stringFromDate:[NSDate date]];
//#error dateTime是完整时间
    NSDate *tsDate = totalModel.deadline;
    NSDate *currentDate = [NSDate date];
    NSDate *dbDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", dbModel.date, dbModel.time]];
    if (![dbModel.type isEqualToNumber:totalModel.type] && [tsDate compare:currentDate] == NSOrderedAscending && [tsDate compare:dbDate] == NSOrderedAscending)
        return YES;
    
    return NO;
}


@end
