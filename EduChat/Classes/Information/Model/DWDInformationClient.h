//
//  DWDInformationClient.h
//  EduChat
//
//  Created by apple on 12/21/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDInformationClient : NSObject

- (void)fetchInformationByDistrictCode:(NSString *)code
                                  page:(NSNumber *)page
                             pageCount:(NSNumber *)count
                               success:(void(^)(NSArray *headers, NSArray *infos, BOOL hasNextPage))success
                               failure:(void(^)(NSError *error))failure;

- (void)fetchInformationCommentsByInfoId:(NSNumber *)infoId
                                    page:(NSNumber *)page
                               pageCount:(NSNumber *)count
                                 success:(void(^)(NSArray *comments, BOOL hasNextPage))success
                                 failure:(void(^)(NSError *error))failure;

- (void)postCommentForInfo:(NSNumber *)infoId
                        by:(NSNumber *)custId
                       for:(NSNumber *)forCustId
                   comment:(NSString *)comment
                   success:(void(^)())success
                   failure:(void(^)(NSError *error))failure;

- (void)postPraiseForInfo:(NSNumber *)infoId
                       by:(NSNumber *)custId
                  success:(void(^)())success
                  failure:(void(^)(NSError *error))failure;
@end
