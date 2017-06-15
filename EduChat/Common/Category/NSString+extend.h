//
//  NSString+extend.h
//  PodTest
//
//  Created by linzhipei on 15/8/13.
//  Copyright (c) 2015年 linzhipei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (extend)
/**
 *  拼接请求参数 参数1&参数2&参数3
 **/
+ (NSString *)URLParamWithDict:(NSDictionary *)param;

/**
 *  是否是手机号码
 **/
+ (BOOL)isValidatePhone:(NSString *)phone;

/**
 *  是否是邮箱
 **/
+ (BOOL)isValidateEmail:(NSString *)email;


/** 返回string中的url范围 */
+ (NSRange)urlRangeWithString:(NSString *)string;
/** 返回string中的电话号码范围 */
+ (NSRange)phoneNumberRangeWithString:(NSString *)string;

/** 是否是6-16位数字与英文组合 可以纯数字或英文 **/
+ (BOOL)isValidateSixToSixteen:(NSString *)validate;
/** 是否纯数字 */
+ (BOOL)isValidateNumber:(NSString *)validate;

- (NSString *)trim;// 去掉前后空格
- (BOOL)isEmptyStringTrim;
- (BOOL)isEmptyString;
/**
 * 判断是否是空格
 */
- (BOOL )isBlank;

// http://
- (NSString *)httpUrl;

// 包含字串
// options yes 忽略大小写
- (BOOL)hasSubString:(NSString *)aString options:(BOOL)bIgnore;

- (BOOL)containChinese;

- (NSString*)md5;

// 检查是否为中英文混合
- (BOOL)isChineseEnglish;


// 检查是否为ip地址
- (BOOL)isIPAddress;


//MD5 32位加密 小写
- (NSString*)md532BitLower;
//MD5 32位加密 大写
- (NSString*)md532BitUpper;

/** DES 64解密 */
+ (NSString *) decryptUseDES:(NSString*)cipherText key:(NSString*)key;



//计算文本单行字体高度
- (CGSize)boundingRectWithfont:(UIFont *)font;
//计算文本多行字体高度
- (CGSize)boundingRectWithfont:(UIFont *)font sizeMakeWidth:(CGFloat)width;


/** 针对FMDB  将字符串中的“'”转化为“''”  单引号转为双引号 */
+ (NSString *)stringSingleQuotesWithString:(NSString *)string;

/** 转义符 */
- (NSString *)stringByAddingPercentEscapes;

/**
 *  date转string
 *
 *  @param date YYYY-MM-dd HH:mm:ss格式
 *
 *  @return string格式
 */

/** 时间戳转 YYYYMMddHHmmss */
+ (NSString *)stringFromTimeStampWithYYYYMMddHHmmss:(NSNumber *)timeStamp;

+ (NSString *)stringFromDateWithYYYYMMddHHmmss:(NSDate *)date;

/**
 *  YYYYMMddHHmmssDate String转YYYYMMdd String
 *
 *  @param dateStr YYYYMMddHHmmssDate String
 *
 *  @return YYYYMMdd String
 */
+ (NSString *)stringFormatYYYYMMddHHmmssDateToYYYYMMddString:(NSString *)dateStr;

+ (NSString *)stringFormatYYYYMMddHHmmssDateToYYYYMMddString:(NSString *)dateStr withFormatSymbol:(NSString *)symbol;

/** 传入时间string 和当前时间比较 返回年月日或者月日或者今天的时间 给聊天界面使用*/
+ (NSString *)judgeTimeStringWithStringForChatTimeNote:(NSNumber *)timeStamp;

/** 传入时间string 和当前时间比较 返回年月日或者月日或者今天的时间 */
+ (NSString *)judgeTimeStringWithString:(NSNumber *)timeStamp;

/**
 *  比较二者时间差值
 *
 *  @param date1        时间1
 *  @param date2        时间2
 *
 *  @return 返回从dateStr2到dateStr1的差值
 */
+ (NSTimeInterval)compareDateString:(NSString *)dateStr1 toDateString:(NSString *)dateStr2;

/**
 *  返回今天的日期
 */
+ (NSString *)getTodayDateStr;

/**
 *  返回给定字符串的真实宽高(不限最大宽度)
 *
 *  @param text 字符串
 *  @param size 字体大小
 *
 *  @return 文字的真实宽高
 */
- (CGSize)realSizeWithfont:(UIFont *)font;





/********** 接送中心 *********/
/**
 *  拼接班级id表名(教师端)
 */
- (NSString *)tableNameStringWithClassId;

/**
 *  拼接孩子id表名(家长端)
 */
- (NSString *)tableNameStringWithChildId;

- (NSString *)tableCalendarNameString;

/**
 *  格式化时间,向前加至 X5分或者X0分钟
 *
 *  @param timeStr 待格式化的时间
 *
 *  @return 格式化好的时间
 */
- (NSString *)formatTimeStringWithString;

/**
 *  传入标准格式时间字符串 返回小时:分钟
 *
 *  @return 小时:分钟 字符串
 */
- (NSString *)hourMinuteString;

/**
 *  根据家长关系数字返回家长称谓
 *
 *  @param relation 数字
 *  @param name     默认家长名(姓名)
 */
+ (NSString *)parentRelationStringWithRelation:(NSNumber *)relation;

///**
// *  根据家长关系和当前状态返回文案
// *
// *  @param relation   家长关系
// *  @param name       默认姓名
// */
//- (NSString *)pickUpCenterLastContentStringWithClassName:(NSString *)className relation:(NSNumber *)relation defaultName:(NSString *)name;

/**
 *  阿里云图片服务器的key
 *
 */
- (NSString *)imgKey;

/**
 *  格式化友好时间
 *
 *  @param date 时间
 *
 *  @return 友好时间
 */
+ (NSString *)stringWithTimelineDate:(NSDate *)date;

/** url encode */
- (NSString *)urlencode;

+ (NSString*)getNULLString:(NSObject*)obj;


/**
 *  读取图片中的二维码讯息
 *  @param image 图片
 *  
 *  @return 如果存在二维码并且能扫描到,那么返回二维码讯息
 *          如果不行,返回nil
 */
+ (NSString *)messageWithImage:(UIImage *)image;

@end
