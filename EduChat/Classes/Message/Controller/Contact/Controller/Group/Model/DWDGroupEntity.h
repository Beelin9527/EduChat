//
//  DWDGroupEntity.h
//  EduChat
//
//  Created by Superman on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDGroupEntity : NSObject
@property (nonatomic , copy) NSString *photoKey;
@property (strong, nonatomic) NSNumber *groupId;
@property (copy, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSNumber *memberCount;
@property (copy, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSNumber *isMian;
@property (strong, nonatomic) NSNumber *isShowNick;
@property (strong, nonatomic) NSNumber *isSave;
@end
