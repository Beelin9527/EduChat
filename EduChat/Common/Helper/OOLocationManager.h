//
//  OOLocationManager.h
//  EduChat
//
//  Created by Gatlin on 16/6/21.
//  Copyright © 2016年 dwd. All rights reserved.
//  定位封装 call me Gatlin

#import <Foundation/Foundation.h>

/**
 * @param areaName 省市区
 */
typedef void(^callBolck)(NSString *areaName,NSString *province,NSString *city,NSString *district);

@interface OOLocationManager : NSObject

/**
 * start location
 */

- (void)startLocationSuccess:(callBolck)success;
@end
