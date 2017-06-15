//
//  DWDAreaEntity.m
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAreaEntity.h"

@implementation DWDAreaEntity
- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = [self convertNull:[dict objectForKey:@"name"]];
        self.regionCode = [self convertNull:[dict objectForKey:@"regionCode"]];
        self.shortName = [self convertNull:[dict objectForKey:@"shortName"]];
        self.districtList = [self convertNull:[dict objectForKey:@"districtList"]];
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
            [result addObject:[[DWDAreaEntity alloc] initWithDict:value] ];
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

@end
