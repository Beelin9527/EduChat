//
//  DWDIntMessageModel.h
//  EduChat
//
//  Created by Beelin on 17/1/9.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWDIntMessageContextModel;
@interface DWDIntMessageModel : NSObject
@property (nonatomic, strong) NSNumber *ctTime;
@property (nonatomic, copy) NSString *mntitle;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, strong) NSNumber *msgid;
@property (nonatomic, copy) NSString *msgcontextStr;
@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, strong) NSNumber *cgid;
@property (nonatomic, copy) NSString *mncd;

@property (nonatomic, copy) NSString *msgtitle;
@property (nonatomic, strong) NSNumber *modtype;
@property (nonatomic, strong) NSNumber *statype;
@property (nonatomic, copy) NSString *value;

@property (nonatomic, strong) NSArray <DWDIntMessageContextModel *>*msgcontextList;

@property (nonatomic, assign) CGFloat cellHeight;
@end

@interface DWDIntMessageContextModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@end

/*
{
    "ctTime": 20170109164905,
    "mntitle": "审批",
    "icon": "",
    "msgid": 150,
    "msgcontextStr": "",
    "sid": 2010000063157,
    "cgid": 0,
    "mncd": "A020101020107",
    "msgcontextList": [
                       {
                           "name": "合计金额",
                           "value": "21978.00元"
                       },
                       {
                           "name": "采购事由",
                           "value": "丰富的"
                       },
                       {
                           "name": "审批状态",
                           "value": "待审批"
                       }
                       ],
    "msgtitle": "妮妮老师的采购申请等待您审批",
    "modtype": 1,
    "statype": 1,
    "value": "https://tservice.dwd-sj.com:8086/short//html/mobileoffice/apply/purchase/detail_examine.html?returnToApp=1&aid=105"
}
*/
