//
//  DWDFriendVerifyClient.h
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"

@interface DWDFriendVerifyClient : NSObject

DWDSingletonH(FriendVerifyClient)

- (void)postAddressBookAndGetFriendList:(NSNumber *)custId addressBook:(NSMutableDictionary *)dict
                                success:(void(^)(NSArray *invites))success
                                failure:(void(^)(NSError *error))failure;

/** 获取好友申请数据 */
- (void)getFriendInviteList:(NSNumber *)custId
                    success:(void(^)(NSMutableArray *invites))success
                    failure:(void(^)(NSError *error))failure;

/**
 * @param source 申请来源
 0:未知来源|
 1:通过多维度号添加|
 2:通过手机号添加|
 3:通过名片添加|
 4:通过二维码添加|
 5:通过附近人添加|
 6:通过摇一摇添加|
 7:通过群加为好友|
 8:通过班级加为好友|
 9:通过手机通讯录加为好友|
 10:通过雷达加为好友
 */
- (void)sendFriendVerify:(NSNumber *)custId
                friendId:(NSNumber *)friendId
              verifyInfo:(NSString *)verifyInfo
                  source:(NSNumber *)source
                 success:(void(^)(NSArray *invites))success
                 failure:(void(^)(NSError *error))failure;

- (void)updateFirendVerifyState:(NSNumber *)custId
                       friendId:(NSNumber *)friendId
                          state:(NSNumber *)state
                        success:(void(^)(NSArray *info))success
                        failure:(void(^)(NSError *error))failure;
//获取验证信息
-(void)requestGetVerifyInfos:(NSNumber *)custId friendId:(NSNumber*)friendId success:(void (^)(NSArray *info))success failure:(void (^)(NSError *error))failure;
//回复验证信息
-(void)requestAddVerifyInfos:(NSNumber *)custId friendId:(NSNumber*)friendId success:(void (^)(NSArray *info))success failure:(void (^)(NSError *error))failure;
@end
