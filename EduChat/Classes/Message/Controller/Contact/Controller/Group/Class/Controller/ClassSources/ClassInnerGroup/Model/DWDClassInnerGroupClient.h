//
//  DWDClassInnerGroupClient.h
//  EduChat
//
//  Created by apple on 12/31/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDClassInnerGroupClient : NSObject

- (void)postClassInnerGroupBy:(NSNumber *)custId
                      classId:(NSNumber *)classId
                    groupName:(NSString *)groupName
                     contacts:(NSArray *)contacts
                      success:(void(^)())success
                      failure:(void(^)(NSError *error))failur;

- (void)fetchClassInnerGroupBy:(NSNumber *)custId
                       classId:(NSNumber *)classId
                       success:(void(^)(NSArray *innerGroups))success
                       failure:(void(^)(NSError *error))failure;

- (void)deleteClassInnerGroupBy:(NSNumber *)custId
                        classId:(NSNumber *)classId
                        groupId:(NSNumber *)groupId
                        success:(void(^)())success
                        failure:(void(^)(NSError *error))failure;

- (void)fetchClassInnerGroupMembersBy:(NSNumber *)custId
                              classId:(NSNumber *)classId
                              groupId:(NSNumber *)groupId
                              success:(void(^)(NSArray *members))success
                              failure:(void(^)(NSError *error))failure;

- (void)addMembersToClassInnerGroup:(NSNumber *)group
                            classId:(NSNumber *)classId
                             byUser:(NSNumber *)custId
                        addContacts:(NSArray *)contacts
                            success:(void(^)())success
                            failure:(void(^)(NSError *error))failure;

- (void)deleteMembersToClassInnerGroup:(NSNumber *)group
                               classId:(NSNumber *)classId
                                byUser:(NSNumber *)custId
                           addContacts:(NSArray *)contacts
                               success:(void(^)())success
                               failure:(void(^)(NSError *error))failure;
@end
