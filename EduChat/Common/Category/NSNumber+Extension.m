//
//  NSNumber+Extension.m
//  EduChat
//
//  Created by Gatlin on 16/8/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "NSNumber+Extension.h"

@implementation NSNumber (Extension)
- (NSString *)calculateReadCount
{
   NSInteger count = [self integerValue];
    if (count >= 0 && count < 10000) {
        return [NSString stringWithFormat:@"%zd",count];
    }else if (count >= 10000){
        CGFloat  countF = count / 10000.0;
        NSString *strCount = [NSString stringWithFormat:@"%.1f万",countF];
        if ([strCount containsString:@".0"]) {
            strCount = [strCount stringByReplacingOccurrencesOfString:@".0" withString:@""];
            return strCount;
        }
        return [NSString stringWithFormat:@"%.1f万",countF];
    }
    return @"0";
}


- (NSString *)calculateduartion
{
    NSString *strMin = nil;
    NSString *strSec = nil;
    NSInteger duartion = [self integerValue];
    NSInteger min = duartion / 60;
    NSInteger sec = duartion % 60;
    
    if (sec < 10) {
        strMin = [NSString stringWithFormat:@"0%zd",min];
    }else{
        strMin = [NSString stringWithFormat:@"%zd",min];
    }

    
    if (sec < 10) {
        strSec = [NSString stringWithFormat:@"0%zd",sec];
    }else{
        strSec = [NSString stringWithFormat:@"%zd",sec];
    }
    
    return [NSString stringWithFormat:@"%@:%@",strMin,strSec];
}
@end
