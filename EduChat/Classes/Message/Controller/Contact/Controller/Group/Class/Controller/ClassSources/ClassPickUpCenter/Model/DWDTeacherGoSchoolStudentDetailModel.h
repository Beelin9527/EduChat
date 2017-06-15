//
//  DWDTeacherGoSchoolStudentDetailModel.h
//  EduChat
//
//  Created by KKK on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDPhotoMetaModel.h"

@interface DWDTeacherGoSchoolStudentDetailModel : NSObject <NSCopying, NSCoding>
//{
//    “type”：1，
//    “students”：[{
//        "custId":,   学生id
//        "educhatAccount":,  多维度号
//        "name":,
//        "nickname":,
//        "photohead"：{    头像
//            "photoKey"：,
//            "width"：,
//            "height"：,
//            "size"
//        },
//        "leave"：,    是否请假
//        "index"：,    当天第几次上学放学
//        "isToschool"：,   上学还是放学
//        "contextual"：，
//        ,"punchPhoto"：{    打卡照片
//            "photoKey"：,
//            "width"：,
//            "height"：,
//            "size"
//        }
//    }]
//}

@property (nonatomic, copy) NSNumber *custId;
@property (nonatomic, copy) NSString *educhatAccount;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *photokey;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) DWDPhotoMetaModel *photohead;
@property (nonatomic, strong) DWDPhotoMetaModel *punchPhoto;
//0-未请假 1 事假；2 病假；3 其他
@property (nonatomic, assign) int leave;
@property (nonatomic, copy) NSString *contextual;

@end
