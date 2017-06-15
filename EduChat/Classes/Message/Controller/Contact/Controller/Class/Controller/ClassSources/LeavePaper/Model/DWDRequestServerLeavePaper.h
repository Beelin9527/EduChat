//
//  DWDRequestServerLeavePaper.h
//  EduChat
//
//  Created by Bharal on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"
@interface DWDRequestServerLeavePaper : NSObject

DWDSingletonH(DWDRequestServerLeavePaper);

// getList
- (void)requestGetListCustId:(NSNumber *)custId
                                classId:(NSNumber *)classId
                                   type:(NSNumber *)type
                              pageIndex:(NSNumber *)pageIndex
                              pageCount:(NSNumber *)pageCount
                                success:(void (^)(id responseObject))success
                                failure:(void (^)(NSError *error))failure;

// getEntity
- (void)requestGetEntityCustId:(NSNumber *)custId
                       classId:(NSNumber *)classId
                        noteId:(NSNumber *)noteId
                       success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;

// approveNote
- (void)requestApproveNoteCustId:(NSNumber *)custId
                         classId:(NSNumber *)classId
                          noteId:(NSNumber *)noteId
                           state:(NSNumber *)state
                         opinion:(NSString *)opinion
                       success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure;
@end
