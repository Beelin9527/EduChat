//
//  DWDHomeWorkClient.h
//  EduChat
//
//  Created by apple on 12/28/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDHomeWorkClient : NSObject

- (void)fetchHomeWorksBy:(NSNumber *)custId
                classId:(NSNumber *)classId
                   type:(NSNumber *)type
                   page:(NSNumber *)page
              pageCount:(NSNumber *)count
                success:(void(^)(NSArray *homeWorks, BOOL hasNextPage))success
                failure:(void(^)(NSError *error))failure;

- (void)postHomeWorkBy:(NSNumber *)custId
               calssId:(NSNumber *)classId
                 title:(NSString *)title
               content:(NSString *)content
               subject:(NSNumber *)subject
              deadline:(NSString *)deadline
        attachmentType:(NSNumber *)type
       attachmentPaths:(NSArray *)paths
                  from:(NSNumber *)from
               success:(void(^)())success
               failure:(void(^)(NSError *error))failure;

- (void)deleteHomeWorkBy:(NSNumber *)custId
                 classId:(NSNumber *)classId
             homeWorkIds:(NSArray *)deleteIds
                 success:(void(^)())success
                 failure:(void(^)(NSError *error))failure;

- (void)fetchHomeWorkBy:(NSNumber *)custId
                classId:(NSNumber *)classId
             homeWorkId:(NSNumber *)homeWorkId
                success:(void(^)(NSDictionary *homeWork))success
                failure:(void(^)(NSError *error))failure;

- (void)finishHomeworkBy:(NSNumber *)custId
                 classId:(NSNumber *)classId
              homeworkId:(NSArray *)homeworkId
                 success:(void(^)())success
                 failure:(void(^)(NSError *error))failure;
@end
