//
//  DWDContactInviteModel.m
//  EduChat
//
//  Created by KKK on 16/11/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDContactInviteModel.h"

@implementation DWDContactInviteModel

//白名单
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"name",
             @"mobile",
             @"identifier",
             ];
}

//- (id)copyWithZone:(NSZone *)zone {
//    DWDContactInviteModel *model = [[DWDContactInviteModel allocWithZone:zone] init];
//    model.name = self.name;
//    model.mobile = self.mobile;
//    model.identifier = self.identifier;
//    model.invited = self.invited;
//    model.image = self.image;
//    return model;
//}

@end
