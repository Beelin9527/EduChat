//
//  DWDSystemMessageDetailModel.m
//  EduChat
//
//  Created by apple on 2/28/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDSystemMessageDetailModel.h"

@implementation DWDSystemMessageDetailModel

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"verifyState" : @"status",
             @"nickName" : @"nickname"};
}

@end
