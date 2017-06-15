//
//  DWDIntMessageModel.m
//  EduChat
//
//  Created by Beelin on 17/1/9.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntMessageModel.h"

@implementation DWDIntMessageModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"msgcontextList" : [DWDIntMessageContextModel class]};
}
@end

@implementation DWDIntMessageContextModel

@end
