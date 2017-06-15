//
//  NSDictionary+dwd_extend.h
//  EduChat
//
//  Created by KKK on 16/3/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (dwd_extend)

/**
 *  表情映射键盘 对应face.plist
 *
 *  @return mapper字典
 */
+ (NSDictionary *)dwd_emotionMapperDictionary;

/**
 *  查看字典中是否包含key
 */
- (BOOL)containsKey: (NSString *)key;

//- (NSArray *)arrayByDictionary;

@end
