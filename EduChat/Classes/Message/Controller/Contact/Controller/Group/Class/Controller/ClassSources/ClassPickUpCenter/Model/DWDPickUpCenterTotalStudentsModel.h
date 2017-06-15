//
//  DWDPickUpCenterTotalStudentsModel.h
//  EduChat
//
//  Created by KKK on 16/6/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

/**
 *  模型用于缓存网络请求
 *
 */

#import <Foundation/Foundation.h>

#import "DWDTeacherGoSchoolStudentDetailModel.h"

@interface DWDPickUpCenterTotalStudentsModel : NSObject <NSCoding>

//第 index 次 上/放学
@property (nonatomic, strong) NSNumber *index;
//上学 1 还是放学 2
@property (nonatomic, strong) NSNumber *type;
//全学生数组
@property (nonatomic, strong) NSArray<DWDTeacherGoSchoolStudentDetailModel *> *students;
//本次请求的失效日期
@property (nonatomic, strong) NSDate *deadline;
//存储时 记录日期 自行写入
//存储时 记录时间 自行写入 时间用来判断 最后一条消息的时间和最后一次存储请求的时间之间的关系
@property (nonatomic, strong) NSDate *dateTime;


@end
