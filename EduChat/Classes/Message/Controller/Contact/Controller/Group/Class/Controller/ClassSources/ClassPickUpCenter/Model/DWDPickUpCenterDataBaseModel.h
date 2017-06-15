//
//  DWDPickUpCenterDataBaseModel.h
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//
#import "DWDPickUpCenterParentDataBaseModel.h"
#import "DWDPickUpCenterTeacherDataBaseModel.h"

#import <Foundation/Foundation.h>

@interface DWDPickUpCenterDataBaseModel : NSObject <NSCopying>

//{
//    "code":"sysmsgContextual",
//    "entity":{
//        "custId":,			//孩子id
//        "name":"",			//孩子姓名
//        "photokey":"",		//孩子头像
//        "schoolId":""		//学校id
//        "schoolName":"",	//学校名字
//        "classId":,			//班级id
//        "className":"",		//班级名字
//        "relation":0,		//孩子家长关系
//        "contextual":"Reachschool",	//当前接送状态
//        "photo":			//实时照片
//        "date":"2016-3-15"	//接送日期
//        "time":"09:42:30"	//接送时间
//        "parent":					//接送家长信息，可以为空
@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photokey;
@property (nonatomic, strong) NSNumber *schoolId;
@property (nonatomic, copy) NSString *schoolName;
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSNumber *relation;
@property (nonatomic, copy) NSString *contextual;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) DWDPickUpCenterParentDataBaseModel *parent;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *formatTime;
@property (nonatomic, strong) DWDPickUpCenterTeacherDataBaseModel *teacher;
@property (nonatomic, strong) NSNumber *index;


//}




@end
