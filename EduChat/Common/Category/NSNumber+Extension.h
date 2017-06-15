//
//  NSNumber+Extension.h
//  EduChat
//
//  Created by Gatlin on 16/8/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Extension)
/**
 * 文章阅读量显示，超过五位数以万为单位
 */
- (NSString *)calculateReadCount;

/**
 * 音频文件时长
 */
- (NSString *)calculateduartion;
@end
