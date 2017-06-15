//
//  NSString+extend.m
//  PodTest
//
//  Created by linzhipei on 15/8/13.
//  Copyright (c) 2015年 linzhipei. All rights reserved.
//

#import "NSString+extend.h"
#import "NSDate+dwd_dateCategory.h"

#import "ZBarSDK.h"
#import <SDVersion.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <commoncrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (extend)
+ (NSString *)URLParamWithDict:(NSDictionary *)param
{
    NSMutableString *result = [NSMutableString string];
    
    for (NSString *key in param)
    {
        [result appendFormat:@"%@=%@&", key, [param objectForKey:key]];
    }
    if ([result length] > 0)
    {
        [result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];
    }
    
    return result;
}

+ (BOOL)isValidatePhone:(NSString *)phone
{
    NSString *phoneRegex = @"^1[0-9]{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

+ (BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidateSixToSixteen:(NSString *)validate
{
    NSString *emailRegex = @"^[0-9a-zA-Z_]{6,16}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:validate];

}

+ (BOOL)isValidateNumber:(NSString *)validate
{
    NSString *emailRegex = @"^[0-9]{6,16}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:validate];
}

+ (NSRange)urlRangeWithString:(NSString *)string{
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:0 error:&error];
    
    NSRange resultRange;
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
        
        if (firstMatch) {
            resultRange = [firstMatch rangeAtIndex:0];
        }
    }
    return resultRange;
}

+ (NSRange)phoneNumberRangeWithString:(NSString *)string{
    
    NSError *error;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:((13[0-9]{1})|(15[0-9]{1})|(18[0,5-9]{1}))+\\d{8})" options:0 error:&error];
    
    NSRange resultRange;
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
        
        if (firstMatch) {
            resultRange = [firstMatch rangeAtIndex:0];
        }
    }
    return resultRange;
    
}

- (BOOL)isEmptyString
{
    return (nil == self) || (self.length == 0);
}

- (BOOL)isEmptyStringTrim
{
    return [[self trim] isEmptyString];
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL )isBlank
{
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)
    {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - http://

- (NSString *)httpUrl
{
    
    if ([self isEmptyStringTrim])
    {
        return nil;
    }
    
    if ([self hasPrefix:@"http://"])
    {
        return self;
    }
    else
    {
        return [NSString stringWithFormat:@"http://%@", [self trim]];
    }
}

#pragma mark -
#pragma mark -- has substring
// options yes 忽略大小写
- (BOOL)hasSubString:(NSString *)aString options:(BOOL)bIgnore
{
    if ([aString isEmptyString])
    {
        return NO;
    }
    
    NSRange range;
    if (bIgnore)
    {
        range = [self rangeOfString:aString options:NSCaseInsensitiveSearch
                 | NSNumericSearch];
    }
    else
    {
        range = [self rangeOfString:aString];
    }
    
    if (range.length == 0)
    {
        return NO;
    }
    
    return YES;
}

// 检查中文
- (BOOL)containChinese
{
    NSString *Chinese = @"^[\\u4e00-\\u9fa5]+$";
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Chinese];
    
    if ([regextestct evaluateWithObject:self] == YES)
    {
        return YES;
    }
    
    return NO;
}

- (NSString*)md5
{
    if(nil == self)
        return nil;
    
    const char*cStr =[self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

// 检查是否为中英文混合
- (BOOL)isChineseEnglish
{
   
    
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *regex = @"([\u4e00-\u9fa5]+[a-zA-z]+)|([a-zA-z]+[\u4e00-\u9fa5]+)|([\u4e00-\u9fa5]+)|([a-zA-z]+)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",regex];
    if ([predicate evaluateWithObject:trimmedString] == YES)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isIPAddress
{
    NSArray *			components = [self componentsSeparatedByString:@"."];
    NSCharacterSet *	invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    
    if ( [components count] == 4 )
    {
        NSString *part1 = [components objectAtIndex:0];
        NSString *part2 = [components objectAtIndex:1];
        NSString *part3 = [components objectAtIndex:2];
        NSString *part4 = [components objectAtIndex:3];
        
        if ( 0 == [part1 length] ||
            0 == [part2 length] ||
            0 == [part3 length] ||
            0 == [part4 length] )
        {
            return NO;
        }
        
        if ( [part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound )
        {
            if ( [part1 intValue] <= 255 &&
                [part2 intValue] <= 255 &&
                [part3 intValue] <= 255 &&
                [part4 intValue] <= 255 )
            {
                return YES;
            }
        }
    }
    
    return NO;
}


- (NSString*)md532BitLower

{
    
    const char *cStr = [self UTF8String];
    
    unsigned char result[16];
    
    
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    
    CC_MD5( cStr,[num intValue], result );
    
    
    
    return [[NSString stringWithFormat:
             
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             
             result[0], result[1], result[2], result[3],
             
             result[4], result[5], result[6], result[7],
             
             result[8], result[9], result[10], result[11],
             
             result[12], result[13], result[14], result[15]
             
             ] lowercaseString];
    
}

- (NSString*)md532BitUpper

{
    
    const char *cStr = [self UTF8String];
    
    unsigned char result[16];
    
    
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    
    CC_MD5( cStr,[num intValue], result );
    
    
    
    return [[NSString stringWithFormat:
             
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             
             result[0], result[1], result[2], result[3],
             
             result[4], result[5], result[6], result[7],
             
             result[8], result[9], result[10], result[11],
             
             result[12], result[13], result[14], result[15]
             
             ] uppercaseString];
    
}


/**
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 */
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}


- (CGSize)boundingRectWithfont:(UIFont *)font{
    NSDictionary *dict = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:CGSizeMake(DWDScreenW, MAXFLOAT) options:NSStringDrawingUsesFontLeading attributes:dict context:nil].size;
}
- (CGSize)boundingRectWithfont:(UIFont *)font sizeMakeWidth:(CGFloat)width{
    NSDictionary *dict = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
}



+ (NSString *)stringSingleQuotesWithString:(NSString *)string
{
    for (int i = 0; i<[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:@"\'"]) {
            NSRange range = NSMakeRange(i, 1);
            //将字符串中的“'”转化为“''”  单引号转为双引号
            string = [string stringByReplacingCharactersInRange:range withString:@"\'\'"];
            i++;
        }
    }

    return string;
}

/** url encode */
- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


- (NSString *)stringByAddingPercentEscapes
{
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"'“!*’();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString *)stringFromDateWithYYYYMMddHHmmss:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

+ (NSString *)stringFromTimeStampWithYYYYMMddHHmmss:(NSNumber *)timeStamp{
    
    NSTimeInterval judgeTimeStamp;
    if ([timeStamp doubleValue] - [timeStamp longLongValue] == 0) {
        judgeTimeStamp = ([timeStamp longLongValue] / 1000.0) + 0.000001;
    }else{
        judgeTimeStamp = [timeStamp doubleValue];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:judgeTimeStamp];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    return dateStr;
}

+ (NSString *)stringFormatYYYYMMddHHmmssDateToYYYYMMddString:(NSString *)dateStr {
    return [NSString stringFormatYYYYMMddHHmmssDateToYYYYMMddString:dateStr withFormatSymbol:@"/"];
}

+ (NSString *)stringFormatYYYYMMddHHmmssDateToYYYYMMddString:(NSString *)dateStr withFormatSymbol:(NSString *)symbol {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    formatter.locale = [NSLocale currentLocale];
    NSDate *date =[formatter dateFromString:dateStr];
    if (date == nil) {
       NSString *originStr = [dateStr substringToIndex:19];
        date = [formatter dateFromString:originStr];
    }
    NSString *newDateStr = [NSString stringWithFormat:@"YYYY%@MM%@dd", symbol, symbol];
    formatter.dateFormat = newDateStr;
    NSString *dateFormatStr = [formatter stringFromDate:date];
    return dateFormatStr;
}


/** 传入时间string 和当前时间比较 返回年月日或者月日或者今天的时间 给聊天界面使用*/
+ (NSString *)judgeTimeStringWithStringForChatTimeNote:(NSNumber *)timeStamp{
    
    NSTimeInterval judgeTimeStamp;
    if ([timeStamp doubleValue] - [timeStamp longLongValue] == 0) {
        judgeTimeStamp = ([timeStamp longLongValue] / 1000.0) + 0.000001;
    }else{
        judgeTimeStamp = [timeStamp doubleValue];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:judgeTimeStamp];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    // 入参
    NSArray *bigArray = [dateStr componentsSeparatedByString:@" "];
    
    NSString *yyyyMMdd = bigArray[0];
    NSString *hhmmss = bigArray[1];
    
    NSArray *componentsOfyyyyMMdd = [yyyyMMdd componentsSeparatedByString:@"-"]; // 年月日 入参
    NSArray *componentsOfhhmmss = [hhmmss componentsSeparatedByString:@":"]; // 时分秒 入参
    
    // 当前
    NSString *DateStringCurrent = [NSString stringFromDateWithYYYYMMddHHmmss:[NSDate date]];
    
    NSArray *bigArrayCurrent = [DateStringCurrent componentsSeparatedByString:@" "];
    
    NSString *yyyyMMddCurrent = bigArrayCurrent[0];
    //    NSString *hhmmssCurrent = bigArrayCurrent[1];
    
    NSArray *componentsOfyyyyMMddCurrent = [yyyyMMddCurrent componentsSeparatedByString:@"-"];  // 年月日 当前
    //    NSArray *componentsOfhhmmssCurrent = [hhmmssCurrent componentsSeparatedByString:@":"];  // 时分秒 当前
    // 判断年份
    if ([componentsOfyyyyMMdd[0] isEqualToString:componentsOfyyyyMMddCurrent[0]]) { // 年份相同 , 判断月
        if ([componentsOfyyyyMMdd[1] isEqualToString:componentsOfyyyyMMddCurrent[1]]) { // 年份 月份相同 , 判断日
            if ([componentsOfyyyyMMdd[2] isEqualToString:componentsOfyyyyMMddCurrent[2]]) { // 年 月 日 都相同 ,返回时分
                return [[componentsOfhhmmss[0] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
            }else{ // 年同 月同 日子不同
                return [[[[[self judgeDeltaFromDateStr:componentsOfyyyyMMddCurrent[2] toDateStr:componentsOfyyyyMMdd[2] yearStr:componentsOfyyyyMMdd[0] monthStr:componentsOfyyyyMMdd[1]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
            }
        }else{  // 年同 月份不同 , 返回 月 日
            if ([componentsOfyyyyMMdd[2] isEqualToString:componentsOfyyyyMMddCurrent[2]]) {  //日同 , 返回月 日
                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
            }else{  // 日不同
                if ([componentsOfyyyyMMddCurrent[2] isEqualToString:@"01"]) { // 今天是 1号
                    if ([componentsOfyyyyMMdd[1] isEqualToString:@"02"]) { // 上个月是2月
                        
                        NSString *yearstring = componentsOfyyyyMMdd[0];
                        int year = [yearstring intValue];
                        
                        if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) { // 是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"29"]) { // 这一天是29号
                                return [[[[@"昨天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"28"]){
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                        }else{  // 不是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"28"]) { // 这一天是28号
                                return [[[[@"昨天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"27"]){ // 27
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{  // 返回 月 日
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                        }
                    }else{ // 上个月不是2月
                        if ([componentsOfyyyyMMdd[1] isEqualToString:@"01"] || [componentsOfyyyyMMdd[1] isEqualToString:@"03"] || [componentsOfyyyyMMdd[1] isEqualToString:@"05"] || [componentsOfyyyyMMdd[1] isEqualToString:@"07"] || [componentsOfyyyyMMdd[1] isEqualToString:@"08"] || [componentsOfyyyyMMdd[1] isEqualToString:@"10"] || [componentsOfyyyyMMdd[1] isEqualToString:@"12"]) { // 这个月有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"31"]) { // 这一天是31号
                                return [[[[@"昨天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"30"]){
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                            
                        }else{  // 这个月没有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"30"]) { // 这一天是30号
                                return [[[[@"昨天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"29"]){
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                        }
                        
                    }
                }else if ([componentsOfyyyyMMddCurrent[2] isEqualToString:@"02"]){ // 今天是 2号  ========
                    
                    if ([componentsOfyyyyMMdd[1] isEqualToString:@"02"]) { // 上个月是2月
                        
                        NSString *yearstring = componentsOfyyyyMMdd[0];
                        int year = [yearstring intValue];
                        
                        if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) { // 是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"29"]) { // 这一天是29号
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                        }else{  // 不是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"28"]) { // 这一天是28号
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{  // 返回 月 日
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                        }
                    }else{ // 上个月不是2月
                        if ([componentsOfyyyyMMdd[1] isEqualToString:@"01"] || [componentsOfyyyyMMdd[1] isEqualToString:@"03"] || [componentsOfyyyyMMdd[1] isEqualToString:@"05"] || [componentsOfyyyyMMdd[1] isEqualToString:@"07"] || [componentsOfyyyyMMdd[1] isEqualToString:@"08"] || [componentsOfyyyyMMdd[1] isEqualToString:@"10"] || [componentsOfyyyyMMdd[1] isEqualToString:@"12"]) { // 这个月有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"31"]) { // 这一天是31号
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                            
                        }else{  // 这个月没有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"30"]) { // 这一天是30号
                                return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }else{
                                return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                            }
                        }
                        
                    }
                    
                }else{ // 返回 月 日
                    return [[[[[[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                }
            }
        }
    }else{ // 年份不同 , 返回年 月 日
        if ([componentsOfyyyyMMdd[1] isEqualToString:@"12"] && [componentsOfyyyyMMdd[2] isEqualToString:@"31"]) {
            if ([componentsOfyyyyMMddCurrent[0] intValue] - [componentsOfyyyyMMdd[0] intValue] == 1) { // 只相差一年
                if ([componentsOfyyyyMMddCurrent[1] isEqualToString:@"01"] && [componentsOfyyyyMMddCurrent[2] isEqualToString:@"01"]) { // 今天是1月1号
                    return [[[[@"昨天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                }else if ([componentsOfyyyyMMddCurrent[1] isEqualToString:@"01"] && [componentsOfyyyyMMddCurrent[2] isEqualToString:@"02"]){ // 今天1月2号
                    return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                }else{
                    return [[[[[[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                }
            }else{
                return [[[[[[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
            }
        }else if ([componentsOfyyyyMMdd[1] isEqualToString:@"12"] && [componentsOfyyyyMMdd[2] isEqualToString:@"30"]){
            if ([componentsOfyyyyMMddCurrent[0] intValue] - [componentsOfyyyyMMdd[0] intValue] == 1) { // 只相差一年
                if ([componentsOfyyyyMMddCurrent[1] isEqualToString:@"01"] && [componentsOfyyyyMMddCurrent[2] isEqualToString:@"01"]) { // 今天是1月1号
                    return [[[[@"前天" stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                }else{
                    return [[[[[[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
                }
            }else{
                return [[[[[[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
            }
        }else{
            return [[[[[[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]] stringByAppendingString:@" "] stringByAppendingString:componentsOfhhmmss[0]] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
        }
        
    }
}

/** 传入时间戳 和当前时间比较 返回年月日或者月日或者今天的时间 */
+ (NSString *)judgeTimeStringWithString:(NSNumber *)timeStamp{
    NSTimeInterval judgeTimeStamp;
    if ([timeStamp doubleValue] - [timeStamp longLongValue] == 0) {
        judgeTimeStamp = ([timeStamp longLongValue] / 1000.0) + 0.000001;
    }else{
        judgeTimeStamp = [timeStamp doubleValue];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:judgeTimeStamp];
//    date = [NSDate dateWithTimeIntervalSinceNow:[timeStamp doubleValue]];
//    date = [NSDate dateWithTimeInterval:[timeStamp doubleValue] sinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    // 入参
    NSArray *bigArray = [dateStr componentsSeparatedByString:@" "];
    
    NSString *yyyyMMdd = bigArray[0];
    NSString *hhmmss = bigArray[1];
    
    NSArray *componentsOfyyyyMMdd = [yyyyMMdd componentsSeparatedByString:@"-"]; // 年月日 入参
    NSArray *componentsOfhhmmss = [hhmmss componentsSeparatedByString:@":"]; // 时分秒 入参
    
    // 当前
    NSString *DateStringCurrent = [NSString stringFromDateWithYYYYMMddHHmmss:[NSDate date]];
    
    NSArray *bigArrayCurrent = [DateStringCurrent componentsSeparatedByString:@" "];
    
    NSString *yyyyMMddCurrent = bigArrayCurrent[0];
//    NSString *hhmmssCurrent = bigArrayCurrent[1];
    
    NSArray *componentsOfyyyyMMddCurrent = [yyyyMMddCurrent componentsSeparatedByString:@"-"];  // 年月日 当前
//    NSArray *componentsOfhhmmssCurrent = [hhmmssCurrent componentsSeparatedByString:@":"];  // 时分秒 当前
    // 判断年份
    if ([componentsOfyyyyMMdd[0] isEqualToString:componentsOfyyyyMMddCurrent[0]]) { // 年份相同 , 判断月
        if ([componentsOfyyyyMMdd[1] isEqualToString:componentsOfyyyyMMddCurrent[1]]) { // 年份 月份相同 , 判断日
            if ([componentsOfyyyyMMdd[2] isEqualToString:componentsOfyyyyMMddCurrent[2]]) { // 年 月 日 都相同 ,返回时分
                return [[componentsOfhhmmss[0] stringByAppendingString:@":"] stringByAppendingString:componentsOfhhmmss[1]];
            }else{ // 年同 月同 日子不同
                return [self judgeDeltaFromDateStr:componentsOfyyyyMMddCurrent[2] toDateStr:componentsOfyyyyMMdd[2] yearStr:componentsOfyyyyMMdd[0] monthStr:componentsOfyyyyMMdd[1]];
            }
        }else{  // 年同 月份不同 , 返回 月 日
            if ([componentsOfyyyyMMdd[2] isEqualToString:componentsOfyyyyMMddCurrent[2]]) {  //日同 , 返回月 日
                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
            }else{  // 日不同
                if ([componentsOfyyyyMMddCurrent[2] isEqualToString:@"01"]) { // 今天是 1号
                    if ([componentsOfyyyyMMdd[1] isEqualToString:@"02"]) { // 上个月是2月
                        
                        NSString *yearstring = componentsOfyyyyMMdd[0];
                        int year = [yearstring intValue];
                        
                        if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) { // 是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"29"]) { // 这一天是29号
                                return @"昨天";
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"28"]){
                                return @"前天";
                            }else{
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                        }else{  // 不是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"28"]) { // 这一天是28号
                                return @"昨天";
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"27"]){ // 27
                                return @"前天";
                            }else{  // 返回 月 日
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                        }
                    }else{ // 上个月不是2月
                        if ([componentsOfyyyyMMdd[1] isEqualToString:@"01"] || [componentsOfyyyyMMdd[1] isEqualToString:@"03"] || [componentsOfyyyyMMdd[1] isEqualToString:@"05"] || [componentsOfyyyyMMdd[1] isEqualToString:@"07"] || [componentsOfyyyyMMdd[1] isEqualToString:@"08"] || [componentsOfyyyyMMdd[1] isEqualToString:@"10"] || [componentsOfyyyyMMdd[1] isEqualToString:@"12"]) { // 这个月有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"31"]) { // 这一天是31号
                                return @"昨天";
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"30"]){
                                return @"前天";
                            }else{
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                            
                        }else{  // 这个月没有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"30"]) { // 这一天是30号
                                return @"昨天";
                            }else if ([componentsOfyyyyMMdd[2] isEqualToString:@"29"]){
                                return @"前天";
                            }else{
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                        }
                        
                    }
                }else if ([componentsOfyyyyMMddCurrent[2] isEqualToString:@"02"]){ // 今天是 2号  ========
                    
                    if ([componentsOfyyyyMMdd[1] isEqualToString:@"02"]) { // 上个月是2月
                        
                        NSString *yearstring = componentsOfyyyyMMdd[0];
                        int year = [yearstring intValue];
                        
                        if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)) { // 是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"29"]) { // 这一天是29号
                                return @"前天";
                            }else{
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                        }else{  // 不是闰年
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"28"]) { // 这一天是28号
                                return @"前天";
                            }else{  // 返回 月 日
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                        }
                    }else{ // 上个月不是2月
                        if ([componentsOfyyyyMMdd[1] isEqualToString:@"01"] || [componentsOfyyyyMMdd[1] isEqualToString:@"03"] || [componentsOfyyyyMMdd[1] isEqualToString:@"05"] || [componentsOfyyyyMMdd[1] isEqualToString:@"07"] || [componentsOfyyyyMMdd[1] isEqualToString:@"08"] || [componentsOfyyyyMMdd[1] isEqualToString:@"10"] || [componentsOfyyyyMMdd[1] isEqualToString:@"12"]) { // 这个月有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"31"]) { // 这一天是31号
                                return @"前天";
                            }else{
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                            
                        }else{  // 这个月没有31号
                            if ([componentsOfyyyyMMdd[2] isEqualToString:@"30"]) { // 这一天是30号
                                return @"前天";
                            }else{
                                return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                            }
                        }
                        
                    }
                    
                }else{ // 返回 月 日
                    return [[componentsOfyyyyMMdd[1] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                }
            }
        }
    }else{ // 年份不同 , 返回年 月 日
        if ([componentsOfyyyyMMdd[1] isEqualToString:@"12"] && [componentsOfyyyyMMdd[2] isEqualToString:@"31"]) {
            if ([componentsOfyyyyMMddCurrent[0] intValue] - [componentsOfyyyyMMdd[0] intValue] == 1) { // 只相差一年
                if ([componentsOfyyyyMMddCurrent[1] isEqualToString:@"01"] && [componentsOfyyyyMMddCurrent[2] isEqualToString:@"01"]) { // 今天是1月1号
                    return @"昨天";
                }else if ([componentsOfyyyyMMddCurrent[1] isEqualToString:@"01"] && [componentsOfyyyyMMddCurrent[2] isEqualToString:@"02"]){ // 今天1月2号
                    return @"前天";
                }else{
                    return [[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                }
            }else{
               return [[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
            }
        }else if ([componentsOfyyyyMMdd[1] isEqualToString:@"12"] && [componentsOfyyyyMMdd[2] isEqualToString:@"30"]){
            if ([componentsOfyyyyMMddCurrent[0] intValue] - [componentsOfyyyyMMdd[0] intValue] == 1) { // 只相差一年
                if ([componentsOfyyyyMMddCurrent[1] isEqualToString:@"01"] && [componentsOfyyyyMMddCurrent[2] isEqualToString:@"01"]) { // 今天是1月1号
                    return @"前天";
                }else{
                    return [[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
                }
            }else{
                return [[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
            }
        }else{
            return [[[[componentsOfyyyyMMdd[0] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[1]] stringByAppendingString:@"-"] stringByAppendingString:componentsOfyyyyMMdd[2]];
        }
        
    }
}

/** 传今天的 dd string  和 指定日期的 dd string 比较*/
+ (NSString *)judgeDeltaFromDateStr:(NSString *)toDaystr1 toDateStr:(NSString *)timeStr2 yearStr:(NSString *)yearStr monthStr:(NSString *)monthStr{
    if ([toDaystr1 intValue] - [timeStr2 intValue] == 1) {
        return @"昨天";
    }else if ([toDaystr1 intValue] - [timeStr2 intValue] == 2){
        return @"前天";
    }else{ // 返回月 日
        return [[monthStr stringByAppendingString:@"-"] stringByAppendingString:timeStr2];
    }
}


+ (NSTimeInterval)compareDateString:(NSString *)dateStr1 toDateString:(NSString *)dateStr2 {
    
    if (dateStr1 == nil || dateStr2 == nil) {
        return 0.0;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDate *date1 =[formatter dateFromString:dateStr1];
    NSDate *date2 = [formatter dateFromString:dateStr2];
    
    NSTimeInterval interval = [date1 timeIntervalSinceDate:date2];
    
    return interval;
}

+ (NSString *)getTodayDateStr {
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSString *dateStr = [NSString stringFormatYYYYMMddHHmmssDateToYYYYMMddString:[formatter stringFromDate:date] withFormatSymbol:@"-"];
    
    return dateStr;
//    return [formatter stringFromDate:date];
}

- (CGSize)realSizeWithfont:(UIFont *)font{
    NSDictionary *dict = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:dict context:nil].size;
}


/********** 接送中心 *********/

- (NSString *)tableNameStringWithClassId {
    NSString *tableName = @"pucT_";
    tableName = [tableName stringByAppendingString:self];
    
    return tableName;
}

- (NSString *)tableNameStringWithChildId {
    NSString *tableName = @"pucC_";
    tableName = [tableName stringByAppendingString:self];
    return tableName;
}

- (NSString *)tableCalendarNameString {
    NSString *tableName = @"pucT_Calendar_";
    tableName = [tableName stringByAppendingString:self];
    return tableName;
}

- (NSString *)formatTimeStringWithString {
    NSString *formatStr;
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    formatter.dateFormat = @"HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDate *currentDate = [formatter dateFromString:self];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:currentDate];
    NSInteger currentHour = [components hour];
    NSInteger currentMinute = [components minute];
    NSInteger formatHour;
    NSInteger formatMinute;
    CGFloat minute = currentMinute * 0.1 + 0.5;
    formatHour = currentHour;
    minute = ((int)minute) * 10;
    if (minute == ((int)(currentMinute * 0.1) * 10)) {
        formatMinute = minute + 5;
    } else {
        formatMinute = minute;
        if (formatMinute == 60) {
            formatHour += 1;
            formatMinute = 0;
        }
    }
    formatStr = [NSString stringWithFormat:@"%zd:%zd", formatHour, formatMinute];
    formatter.dateFormat = @"HH:mm";
    currentDate = [formatter dateFromString:formatStr];
    formatStr = [formatter stringFromDate:currentDate];
    
    return formatStr;
}

- (NSString *)hourMinuteString {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [NSLocale currentLocale];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSDate *date = [formatter dateFromString:self];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:date];
}

+ (NSString *)parentRelationStringWithRelation:(NSNumber *)relation {
    NSInteger relationInt = [relation integerValue];
    switch (relationInt) {
        case 21:
            return @"父亲";
            break;
        case 22:
            return @"母亲";
            break;
        case 23:
            return @"爷爷";
            break;
        case 24:
            return @"奶奶";
            break;
        case 25:
            return @"外公";
            break;
        case 26:
            return @"外婆";
            break;
        default:
            return @"家长";
            break;
    }
}

- (NSString *)imgKey {
    return [self stringByReplacingOccurrencesOfString:@"oss-cn" withString:@"img-cn"];
}

+ (NSString *)stringWithTimelineDate:(NSDate *)date {
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M-d"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy-M-dd"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (date.isToday) {
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (date.isYesterday) {
        return [formatterYesterday stringFromDate:date];
    } else if (date.year == now.year) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}

+ (NSString*)getNULLString:(NSObject*)obj
{
    if (obj == nil||obj==NULL) {
        return @"";
    }
    if([obj isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return (NSString*)obj;
    }
    else if([obj isKindOfClass:[NSNumber class]])
    {
        NSNumber* number = (NSNumber*)obj;
        return  [number stringValue];
    }
    return nil;
}



+ (NSString *)messageWithImage:(UIImage *)image {
    NSString *str;

//    switch ([SDVersion deviceVersion]) {
//        case iPhone4S:
//        case iPhone5C:
//        case iPhone5: {
//            ZBarImageScanner *scan = [ZBarImageScanner new];
//            ZBarImage *zbarImg = [[ZBarImage alloc] initWithCGImage:image.CGImage];
//            NSInteger count = [scan scanImage:zbarImg];
//            if (count > 0) {
//                ZBarSymbolSet *set = scan.results;
//                for (ZBarSymbol *symbol in set) {
//                    if (symbol.type == ZBAR_QRCODE) {
//                        str = symbol.data;
//                        break;
//                    }
//                }
//            } else {
//                str = nil;
//            }
//        }
//            break;
//        default: {
//            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
//                                                      context:nil
//                                                      options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
//            CIImage *qrCodeImage = [[CIImage alloc] initWithImage:image];
//            CIQRCodeFeature *feature = (CIQRCodeFeature *)[detector featuresInImage:qrCodeImage].firstObject;
//            str = feature.messageString;
//            break;
//        }
//    }
    
    
#warning Unknown bug with CIFeature (possible with Apple API
    /**
     Apple的api好像有问题,CIFeature未变更的代码在xcode7到xcode8以后经常不可用
     */
    ZBarImageScanner *scan = [ZBarImageScanner new];
    ZBarImage *zbarImg = [[ZBarImage alloc] initWithCGImage:image.CGImage];
    NSInteger count = [scan scanImage:zbarImg];
    if (count > 0) {
        ZBarSymbolSet *set = scan.results;
        for (ZBarSymbol *symbol in set) {
            if (symbol.type == ZBAR_QRCODE) {
                str = symbol.data;
                break;
            }
        }
    } else {
        str = nil;
    }

    
    return str;
}

@end
