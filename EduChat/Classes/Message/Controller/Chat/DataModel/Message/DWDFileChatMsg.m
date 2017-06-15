//
//  DWDFileChatMsg.m
//  EduChat
//
//  Created by apple on 1/12/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDFileChatMsg.h"

@implementation DWDFileChatMsg

- (NSString *)description {
    [super description];
    
    return [NSString stringWithFormat:@"%@, fileKey:%@, fileName:%@, fileSuffix:%@",[super description], self.fileKey, self.fileName, self.fileSuffix];
}

+ (NSArray *)modelPropertyWhitelist {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super modelPropertyWhitelist]];
    [result addObject:@"fileKey"];
    [result addObject:@"fileName"];
    [result addObject:@"fileSuffix"];
    
    return result;
}

@end
