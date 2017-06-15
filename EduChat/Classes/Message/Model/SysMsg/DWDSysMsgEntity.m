//
//  DWDSysMsgEntity.m
//  EduChat
//
//  Created by Superman on 16/2/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSysMsgEntity.h"

@implementation DWDSysMsgEntity

- (NSString *)description
{
    NSString *string = [NSString stringWithFormat:@"friendCustId:%@\n custId:%@\n classId:%@\n  groupId:%@\n nickname:%@\n members:%@\n createTime:%@\n gradeName:%@\n schoolName:%@\n groupName:%@\n photoKey:%@\n ",self.memberId,self.custId,self.classId,self.groupId,self.nickname, self.members, self.createTime,self.gradeName,self.schoolName,self.groupName,self.photoKey];
    return string;
}
@end
