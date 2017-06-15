//
//  DWDClassNotificatoinListEntity.m
//  EduChat
//
//  Created by Gatlin on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassNotificatoinListEntity.h"

#import "NSString+extend.h"

@implementation DWDClassNotificatoinListEntity
- (id)initWithDict:(NSDictionary *)dict
{
    if ((self = [super init]))
    {
        self.creatTime = [self convertNull:[dict objectForKey:@"creatTime"]];
        self.noticeId = [self convertNull:[dict objectForKey:@"noticeId"]];
        self.readed = [self convertNull:[dict objectForKey:@"readed"]];
        self.title = [self convertNull:[dict objectForKey:@"title"]];
        self.type = [self convertNull:[dict objectForKey:@"type"]];
        self.firstPhoto = [self convertNull:[dict objectForKey:@"firstPhoto"]];
    }
    return self;
}

+ (NSMutableArray *)initWithArray:(NSArray *)array
{
    NSMutableArray *result = [NSMutableArray array];
    for (id value in array)
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            [result addObject:[[DWDClassNotificatoinListEntity alloc] initWithDict:value] ];
        }
    }
    return result;
}

- (id)convertNull:(id)value
{
    if (value != [NSNull null])
        return value;
    return nil;
}

- (void)setCreatTime:(NSString *)creatTime {
    NSString *YMdTime = [NSString stringFormatYYYYMMddHHmmssDateToYYYYMMddString:creatTime withFormatSymbol:@"-"];
    _creatTime = YMdTime;
}
@end
