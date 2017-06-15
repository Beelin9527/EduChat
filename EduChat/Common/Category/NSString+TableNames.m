//
//  NSString+TableNames.m
//  EduChat
//
//  Created by Superman on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "NSString+TableNames.h"

@implementation NSString (TableNames)

+ (NSString *)c2cTableNameStringWithCusid:(NSNumber *)cusid{
    return [NSString stringWithFormat:@"tb_c2c_%@",cusid];
}

+ (NSString *)c2mTableNameStringWithCusid:(NSNumber *)cusid{
    return [NSString stringWithFormat:@"tb_c2m_%@",cusid];
}
@end
