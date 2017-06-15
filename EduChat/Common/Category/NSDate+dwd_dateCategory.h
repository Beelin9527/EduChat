//
//  NSDate+dwd_dateCategory.h
//  EduChat
//
//  Created by KKK on 16/5/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (dwd_dateCategory)

- (NSInteger)day;

- (NSInteger)year;
- (BOOL)isToday;

- (BOOL)isYesterday;

- (NSDate *)dateByAddingDays:(NSInteger)days;

- (NSString *)stringWithFormat:(NSString *)format;

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

/**
 *  日期字符串
 *
 *  @param date 完整日期时间
 *
 *  @return YYYY-MM-dd格式字符串
 */
+ (NSString *)dateString:(NSDate *)date;
@end
