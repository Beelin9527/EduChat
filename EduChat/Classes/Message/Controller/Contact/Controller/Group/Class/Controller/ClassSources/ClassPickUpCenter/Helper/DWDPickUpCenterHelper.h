//
//  DWDPickUpCenterHelper.h
//  EduChat
//
//  Created by KKK on 16/6/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDPickUpCenterHelper : NSObject


/**
 查询是否需要新请求
 `warning` : 直接返回YES

 @param classId 班级id
 @return 是否需要新请求
 */
+ (BOOL)isNecessaryToNewRequestWithClassId:(NSNumber *)classId;

@end
