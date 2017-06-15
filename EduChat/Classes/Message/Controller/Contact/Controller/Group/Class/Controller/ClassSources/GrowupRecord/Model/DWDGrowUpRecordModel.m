//
//  DWDGrowUpRecordModel.m
//  EduChat
//
//  Created by Superman on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#define margin 10
#import "DWDGrowUpRecordModel.h"
@implementation DWDGrowUpRecordModel

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"photos" : [DWDPhotoInfoModel class],
             @"comments" : [DWDGrowUpComments class]};
}


@end
