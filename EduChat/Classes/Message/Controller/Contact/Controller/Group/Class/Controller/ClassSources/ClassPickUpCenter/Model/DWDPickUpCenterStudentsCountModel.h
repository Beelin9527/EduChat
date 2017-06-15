//
//  DWDPickUpCenterStudentsModel.h
//  EduChat
//
//  Created by KKK on 16/4/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDPickUpCenterStudentsCountModel : NSObject <NSCoding>

//toSchool 上学时间 String，格式2016-03-22 09:00:00，允许为空
//afterSchool 放学时间 String 格式2016-03-22 09:00:00 允许为空
//index int 上学方放学序号，从0开始
//memberNum 班级人数 int
//noteNum 请假人数 int
//attendanceNum 出勤人数 int
//attendanceRate 出勤率 int  已经乘100了，移动端显示直接加%

@property (nonatomic, copy) NSString *toSchool;
@property (nonatomic, copy) NSString *afterSchool;
@property (nonatomic, strong) NSNumber  *index;
@property (nonatomic, assign) NSInteger memberNum;
@property (nonatomic, assign) NSInteger noteNum;
@property (nonatomic, assign) NSInteger attendanceNum;
@property (nonatomic, assign) CGFloat attendanceRate;

@end
