//
//  DWDRequestClassSetting.h
//  EduChat
//
//  Created by Bharal on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDSingleton.h"

@interface DWDRequestClassSetting : NSObject

DWDSingletonH(DWDRequestClassSetting);

// get class info
- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure;

// update class info name
- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                     className:(NSString *)className
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure;

// update class info introduce
- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                    introduce:(NSString *)introduce
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure;

// update class info button
- (void)requestClassSettingGetClassInfoCustId:(NSNumber *)custId
                                      classId:(NSNumber *)classId
                                        isTop:(NSNumber *)isTop
                                      isClose:(NSNumber *)isClose
                                   isShowNick:(NSNumber *)isShowNick
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure;
@end
