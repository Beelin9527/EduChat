//
//  DWDImageChatMsg.m
//  EduChat
//
//  Created by apple on 1/12/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDImageChatMsg.h"

@implementation DWDImageChatMsg

- (NSString *)description {
    [super description];
    
    return [NSString stringWithFormat:@"%@, width:%f, height:%f",[super description], self.photo.width, self.photo.height];
}

+ (NSArray *)modelPropertyWhitelist {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super modelPropertyWhitelist]];
    [result addObject:@"photo"];
    
    return result;
}

@end
