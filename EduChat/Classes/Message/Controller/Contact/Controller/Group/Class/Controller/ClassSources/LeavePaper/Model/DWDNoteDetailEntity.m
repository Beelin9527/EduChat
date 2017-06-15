//
//  DWDNoteDetailEntity.m
//  EduChat
//
//  Created by Gatlin on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNoteDetailEntity.h"

@implementation DWDNoteDetailEntity
- (id)initWithDict:(NSDictionary *)dict
{
    if ((self = [super init]))
    {
        self.startTime = [self convertNull:[dict objectForKey:@"startTime"]];
        self.endTime = [self convertNull:[dict objectForKey:@"endTime"]];
        self.excuse = [self convertNull:[dict objectForKey:@"excuse"]];
        self.opinion = [self convertNull:[dict objectForKey:@"opinion"]];
        self.aprdName = [self convertNull:[dict objectForKey:@"aprdName"]];
        self.aprdTime = [self convertNull:[dict objectForKey:@"aprdTime"]];
        self.state = [self convertNull:[dict objectForKey:@"state"]];
        
    }
    return self;
}



- (id)convertNull:(id)value
{
    if (value != [NSNull null]) return value;
    
     return nil;
}
@end
