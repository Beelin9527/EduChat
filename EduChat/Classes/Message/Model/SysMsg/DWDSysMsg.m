//
//  DWDSysMsg.m
//  EduChat
//
//  Created by Superman on 16/2/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSysMsg.h"
@implementation DWDSysMsg
- (NSString *)description
{
    NSString *string = [NSString stringWithFormat:@"code:%@\n verifyId:%@\n operatorId:%@\n  status:%@\n",self.code,self.verifyId,self.operatorId,self.status];
    return string;
}
@end
