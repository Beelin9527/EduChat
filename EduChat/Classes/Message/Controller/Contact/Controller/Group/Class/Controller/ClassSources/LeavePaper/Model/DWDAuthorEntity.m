//
//  DWDAuthorEntity.m
//  EduChat
//
//  Created by Gatlin on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAuthorEntity.h"

@implementation DWDAuthorEntity
- (id)initWithDict:(NSDictionary *)dict
{
    if ((self = [super init]))
    {
        self.addTime = [self convertNull:[dict objectForKey:@"addTime"]];
        self.authorId = [self convertNull:[dict objectForKey:@"authorId"]];
        self.name = [self convertNull:[dict objectForKey:@"name"]];
        self.photoKey = [self convertNull:[dict objectForKey:@"photoKey"]];
       
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
            [result addObject:[[DWDAuthorEntity alloc] initWithDict:value] ];
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
