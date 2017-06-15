//
//  DWDIntelligenceMenuModel.m
//  EduChat
//
//  Created by Beelin on 16/12/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntelligenceMenuModel.h"
#import <YYModel.h>
@implementation DWDIntelligenceMenuModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"schoolId" :      @"sid",
             @"parentCode" :    @"pcd",
             @"parentName" :    @"pNm",
             
             @"modeType" :      @"modtype",
             @"serialNumber" :  @"sn",
             @"menuType" :      @"mntype",
             @"menuCode" :      @"mncd",
             @"menuName" :      @"mnNm",
             @"menuIcon" :      @"mnioc",
             @"funcDesc" :      @"funcdesc",
             
             @"isOpen" :      @"isopen",
             @"isShow" :      @"isshow",
             };
}

@end
