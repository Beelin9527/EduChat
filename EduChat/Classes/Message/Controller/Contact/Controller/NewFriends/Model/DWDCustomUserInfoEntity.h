//
//  DWDCustomUserInfoEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/15.
//  Copyright © 2015年 dwd. All rights reserved.
//  获取好友设置权限 实体类

#import <Foundation/Foundation.h>

@interface DWDCustomUserInfoEntity : NSObject
@property (copy, nonatomic) NSNumber *friendCustId;
@property (copy, nonatomic) NSString *friendRemarkName;
@property (strong, nonatomic) NSNumber *lookPhoto;
@property (strong, nonatomic) NSNumber *blackList;


@end
