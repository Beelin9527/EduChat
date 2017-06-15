//
//  DWDIntNoticeDetailModel.m
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntNoticeDetailModel.h"

#import "DWDContactModel.h"
#import <YYModel.h>
@implementation DWDIntNoticeDetailModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"photos" : [DWDIntPhotoInfoModel class],
             @"dataList" : [DWDContactModel class],
             @"unDataList" : [DWDContactModel class],
              };
}


@end


@implementation DWDIntPhotoInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"photoId" : @"id",
             };
}


@end


@implementation DWDIntAuthorInfoModel

@end



