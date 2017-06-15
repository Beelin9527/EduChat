//
//  DWDRequestServerLocation.h
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//  请求 地址 API

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"

@interface DWDRequestLocation : NSObject

DWDSingletonH(DWDRequestServerLocation)

//get location list
- (void)requestServerLocationgetListCustId:(NSNumber *)custId success:(void (^)(NSArray *result))success failure:(void (^)(NSError *error))failure;

@end
