//
//  DWDContactModel.m
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDContactModel.h"

@implementation DWDContactModel
+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"nickname" : @[@"nickname", @"name"]
             };
}
@end
