//
//  DWDFriendVerifyEntity.h
//  EduChat
//
//  Created by Gatlin on 16/3/25.
//  Copyright © 2016年 dwd. All rights reserved.
//  好友申请验证 Entity

#import <Foundation/Foundation.h>

@interface DWDFriendApplyEntity : NSObject
@property (copy, nonatomic) NSNumber *addTime;
@property (strong, nonatomic) NSNumber *friendCustId;
@property (copy, nonatomic) NSString *friendNickname;
@property (copy, nonatomic) NSString *photoKey;
@property (strong, nonatomic) NSNumber *status;
@property (copy, nonatomic) NSString *verifyInfo;
@property (copy, nonatomic) NSString *verifyTime;

@end
