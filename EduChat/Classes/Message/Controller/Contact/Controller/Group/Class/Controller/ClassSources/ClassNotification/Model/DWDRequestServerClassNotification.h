//
//  DWDRequestServerClassNotification.h
//  EduChat
//
//  Created by Gatlin on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//  班级通知 requestServer

#import <Foundation/Foundation.h>

#import "DWDSingleton.h"
@interface DWDRequestServerClassNotification : NSObject

DWDSingletonH(DWDRequestServerClassNotification);
// get list
- (void)requestServerClassGetListCustId:(NSNumber *)custId
                                classId:(NSNumber *)classId
                                   type:(NSNumber *)type
                              pageIndex:(NSNumber *)pageIndex
                              pageCount:(NSNumber *)pageCount
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSError *error))failure;


// get Entity
- (void)requestServerClassGetEntityCustId:(NSNumber *)custId
                                classId:(NSNumber *)classId
                               noticeId:(NSNumber *)noticeId
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSError *error))failure;


//delete Entity
- (void)requestServerClassDeleteEntityCustId:(NSNumber *)custId
                                  classId:(NSNumber *)classId
                                 noticeId:(NSArray *)noticeId
                                  success:(void (^)(id responseObject))success
                                  failure:(void (^)(NSError *error))failure;

//add Entity
- (void)requestServerClassAddEntityDictParams:(NSMutableDictionary *)dictParams
                                      success:(void (^)(id responseObject))success
                                      failure:(void (^)(NSError *error))failure;

// replyNotice
- (void)requestServerClassReplyNoticeCustId:(NSNumber *)custId
                                  classId:(NSNumber *)classId
                                 noticeId:(NSNumber *)noticeId
                                     item:(NSNumber *)item
                                  success:(void (^)(id responseObject))success
                                  failure:(void (^)(NSError *error))failure;
@end
