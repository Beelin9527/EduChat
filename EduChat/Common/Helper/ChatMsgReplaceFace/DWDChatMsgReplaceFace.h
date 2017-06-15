//
//  DWDChatMsgReplaceFace.h
//  EduChat
//
//  Created by Gatlin on 16/1/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDChatMsgReplaceFace : NSObject
+ (NSAttributedString *) chatMsgformatMessageString:(NSString *)text;

/** 是否有Emoji表情 */
+ (BOOL)stringContainsEmoji:(NSString *)string;
/** emoji 表情转成 “0xffff” */
+ (NSString *)stringChangeUnicode:(NSString *)text;
@end
