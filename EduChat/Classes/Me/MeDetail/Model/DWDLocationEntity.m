//
//  DWDLocationEntity.m
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLocationEntity.h"

@implementation DWDLocationEntity

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.name = [self convertNull:[dict objectForKey:@"name"]];
        self.address = [self convertNull:[dict objectForKey:@"address"]];
        self.districtCode = [self convertNull:[dict objectForKey:@"districtCode"]];
        self.postCode = [self convertNull:[dict objectForKey:@"postCode"]];
        
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
            [result addObject:[[DWDLocationEntity alloc] initWithDict:value] ];
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
