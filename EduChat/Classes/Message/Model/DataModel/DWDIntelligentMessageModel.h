//
//  DWDIntelligentMessageModel.h
//  EduChat
//
//  Created by Beelin on 17/1/16.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWDIntelligentMessageEntityModel;
@interface DWDIntelligentMessageModel : NSObject
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) DWDIntelligentMessageEntityModel *entity;
@end

@interface DWDIntelligentMessageEntityModel : NSObject
@property (nonatomic, copy) NSString *remark;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *mncd;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, strong) NSNumber *cgid;
@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, copy) NSString *action;
@end

/*
 "code":"sysMobileofficeMsgCenter",
 "entity":{
 "remark":"xxx",
 "type":0,//模块类型:0:原生、1:H5、2:混合
 "mncd":"A020101020104",//所属模块的编码
 "value":"1",//如果是H5，该值为URL，如果是原生该值为对应信息的ID
 "cgid":000000L,
 "sid":xxxxxxxxxx,
 "memberId":xxxxxxxxx
 "action":"announcement"
 },
 "uuid":"0"
 */
