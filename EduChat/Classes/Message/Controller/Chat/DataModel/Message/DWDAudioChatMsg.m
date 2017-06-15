//
//  DWDAudioChatMsg.m
//  EduChat
//
//  Created by apple on 1/12/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDAudioChatMsg.h"

@implementation DWDAudioChatMsg

- (NSString *)description {
    [super description];
    
    return [NSString stringWithFormat:@"%@, duration:%@, fileSize:%@",[super description], self.duration, self.fileSize];
}

+ (NSArray *)modelPropertyWhitelist {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super modelPropertyWhitelist]];
    [result addObject:@"duration"];
    [result addObject:@"fileSize"];
    
    return result;
}

@end
