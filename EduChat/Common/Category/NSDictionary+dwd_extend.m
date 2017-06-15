//
//  NSDictionary+dwd_extend.m
//  EduChat
//
//  Created by KKK on 16/3/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "NSDictionary+dwd_extend.h"

#import <UIKit/UIKit.h>

@implementation NSDictionary (dwd_extend)

static NSDictionary *emotionDictionary;
+ (NSDictionary *)dwd_emotionMapperDictionary {
    //解析表情
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *mapper = [NSMutableDictionary new];
        NSString *facePlistPath = [[NSBundle mainBundle] pathForResource:@"face" ofType:@"plist"];
        NSArray *face = [NSArray arrayWithContentsOfFile:facePlistPath];
        NSMutableArray *faceName = [NSMutableArray new];
        for (NSDictionary *faceDic in face) {
            [faceName addObject:faceDic[@"faceName"]];
        }
        for (int i = 0; i < face.count; i ++) {
            UIImage *image = [UIImage imageNamed:faceName[i]];
            mapper[faceName[i]] = image;
        }
        emotionDictionary = mapper;
    });
    
    return emotionDictionary;
}


- (BOOL)containsKey: (NSString *)key {
    BOOL retVal = 0;
    NSArray *allKeys = [self allKeys];
    retVal = [allKeys containsObject:key];
    return retVal;
}

@end
