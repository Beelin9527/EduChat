//
//  DWDTextChatMsg.m
//  EduChat
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDTextChatMsg.h"

@implementation DWDTextChatMsg

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, content:%@",[super description], self.content];
}


+ (NSArray *)modelPropertyWhitelist {
    
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super modelPropertyWhitelist]];
    [result addObject:@"content"];
    
    return result;
}

@end
