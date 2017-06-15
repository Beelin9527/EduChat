//
//  DWDNoteEntity.m
//  EduChat
//
//  Created by Bharal on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//  假条 entity

#import "DWDNoteEntity.h"

@implementation DWDNoteEntity
- (id)initWithDict:(NSDictionary *)dict
{
    if ((self = [super init]))
    {
        self.creatTime = [self convertNull:[dict objectForKey:@"creatTime"]];
        self.noteId = [self convertNull:[dict objectForKey:@"noteId"]];
        self.state = [self convertNull:[dict objectForKey:@"state"]];
        self.type = [self convertNull:[dict objectForKey:@"type"]];
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
            [result addObject:[[DWDNoteEntity alloc] initWithDict:value] ];
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
