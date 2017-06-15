//
//  DWDSysMsg.h
//  EduChat
//
//  Created by Superman on 16/2/23.
//  Copyright © 2016年 dwd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DWDSysMsgEntity.h"
@interface DWDSysMsg : NSObject

@property (nonatomic , copy) NSString *code;
@property (nonatomic , strong) NSNumber *verifyId;
@property (nonatomic , strong) NSNumber *operatorId;
@property (nonatomic , strong) DWDSysMsgEntity *entity;
@property (nonatomic , strong) NSNumber *status;

@property (nonatomic , copy) NSString *uuid;

@end
