//
//  DWDGroupCustEntity.m
//  EduChat
//
//  Created by Gatlin on 15/12/22.
//  Copyright © 2015年 dwd. All rights reserved.
//  群成员信息 Entity

#import "DWDGroupCustEntity.h"

@implementation DWDGroupCustEntity
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if ((self = [super init]))
    {
        self.custId = [self convertNull:[dict objectForKey:@"custId"]];
        self.nickname = [self convertNull:[dict objectForKey:@"nickname"]];
        self.photoKey = [self convertNull:[dict objectForKey:@"photoKey"]];
        self.remark = [self convertNull:[dict objectForKey:@"remarkName"]];

    }
    return self;
}

- (id)convertNull:(id)value
{
    if (value != [NSNull null])
        return value;
    return nil;
}

+ (NSMutableArray *)initWithArray:(NSArray *)array
{
    NSMutableArray *result = [NSMutableArray array];
    for (id value in array)
    {
        if ([value isKindOfClass:[NSDictionary class]])
        {
            [result addObject:[[DWDGroupCustEntity alloc] initWithDict:value] ];
        }
    }
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@,%@", self.custId, self.nickname
            ];
}

@end
