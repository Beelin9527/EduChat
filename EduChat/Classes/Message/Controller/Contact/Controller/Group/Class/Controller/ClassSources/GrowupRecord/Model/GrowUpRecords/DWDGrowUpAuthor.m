//
//  DWDGrowUpAuthor.m
//  EduChat
//
//  Created by Superman on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGrowUpAuthor.h"

@implementation DWDGrowUpAuthor
//@property (nonatomic , copy) NSString *addtime;  // 创建时间
//@property (nonatomic , strong) NSNumber *authorId;  // cusID
//@property (nonatomic , copy) NSString *name;    //
//@property (nonatomic , copy) NSString *photokey;

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"photokey" : @"photoKey",
             @"addtime" : @"addTime"};
}

- (void)setAddtime:(NSString *)addtime {
    
    //设置date格式
    //最终格式:XXXX-XX-XX
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDate *date =[formatter dateFromString:addtime];
    formatter.dateFormat = @"YYYY/MM/dd";
    NSString *dateStr = [formatter stringFromDate:date];
    _addtime = dateStr;
}

@end
