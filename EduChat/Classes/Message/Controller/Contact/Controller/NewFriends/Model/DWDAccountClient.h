//
//  DWDAccountClient.h
//  EduChat
//
//  Created by apple on 12/10/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"

@interface DWDAccountClient : NSObject

DWDSingletonH(AccountClient)

- (void)getCustomUserInfo:(NSNumber *)custId
   friendId:(NSNumber *)friendId
   success:(void(^)(NSDictionary *info))success
   failure:(void(^)(NSError *error))failure;

/** 手机或多维度 搜索 返回个人信息 **/
- (void)getUserInfo:(NSNumber *)custId
          accountNo:(NSString *)accountNo
            success:(void(^)(NSDictionary *info))success
            failure:(void(^)(NSError *error))failure;

/** 获取好友与自己的个人详细信息 **/
- (void)getUserInfoEx:(NSNumber *)custId
             friendId:(NSNumber *)friendId
           extensions:(NSString *)extensions
              success:(void(^)(NSDictionary *info))success
              failure:(void(^)(NSError *error))failure;

/** 获取多维度号 **/
- (void)requestGetEduChatAccount:(NSString *)accountNo
                         success:(void(^)(NSDictionary *info))success
                         failure:(void(^)(NSError *error))failure;


/** 对好友私人设置 */
- (void)updateCustomUserInfo:(NSNumber *)custId
                    friendId:(NSNumber *)friendId
            friendRemarkName:(NSString *)friendRemarkName
                   lookPhoto:(NSNumber *)lookPhoto
                   blackList:(NSNumber *)blackList
                     success:(void(^)(NSDictionary *info))success
                     failure:(void(^)(NSError *error))failure;

- (void)updateUserInfo:(NSNumber *)custId
              nickname:(NSString *)nickname
             education:(NSNumber *)education
              property:(NSNumber *)property
          enterpriseId:(NSNumber *)enterpriseId
              photokey:(NSString *)photokey
             signature:(NSString *)signature
               success:(void(^)(NSDictionary *info))success
               failure:(void(^)(NSError *error))failure ;
@end
