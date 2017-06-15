//
//  DWDVideoChatMsg.m
//  EduChat
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDVideoChatMsg.h"


@implementation DWDVideoChatMsg

- (void)setFromUser:(NSNumber *)fromUser
{
    [super setFromUser:fromUser];
    if ([[DWDCustInfo shared].custId isEqual:fromUser]) {
        self.fromType = DWDChatMsgFromTypeSelf;
        self.backgroundViewFrame = CGRectMake(60, 10, DWDScreenW - 120, DWDChatVideoHeight);
    }else {
        self.fromType = DWDChatMsgFromTypeOther;
        self.backgroundViewFrame = CGRectMake(60, 10, DWDScreenW - 120, DWDChatVideoHeight);
    }
}

- (NSString *)description {
    [super description];
    
    return [NSString stringWithFormat:@"%@, thumbFileKey:%@",[super description], self.thumbFileKey];
}

+ (NSArray *)modelPropertyWhitelist {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super modelPropertyWhitelist]];
    [result addObject:@"thumbFileKey"];
    
    return result;
}

@end
