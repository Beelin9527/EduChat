//
//  DWDSchoolGroupModel.m
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSchoolGroupModel.h"


#import <YYModel.h>

#pragma mark - 群组成员的model
@implementation DWDSchoolGroupMemberModel

+ (NSDictionary *)modelCustomPropertyMapper {

    return @{
             @"custId" : @"uid",
             @"memberName" : @"uNm",
             @"telPhone" : @"tel",
             @"characterName" : @"rNms",
             };
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"checked"];
}

- (instancetype)init {
    self = [super init];
    self.checked = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

@end

#pragma mark - 群组的model
@implementation DWDSchoolGroupModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"schoolID" : @"sid",
             @"schoolName" : @"schNm",
             @"groupID" : @"gpid",
             @"groupName" : @"gpNm",
             @"serialNumber" : @"sn",
             @"groupMembers" : @"users",
             };
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"checked", @"expanded"];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"groupMembers" : [DWDSchoolGroupMemberModel class]
             };
}

- (instancetype)init {
    self = [super init];
    self.checked = NO;
    self.expanded = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}


@end

