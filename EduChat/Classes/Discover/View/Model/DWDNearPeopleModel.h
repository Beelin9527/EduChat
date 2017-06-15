//
//  DWDNearPeopleModel.h
//  EduChat
//
//  Created by Superman on 15/12/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger , DWDNearPeopleModelType){
    DWDNearPeopleModelTypeTeacher = 4,
    DWDNearPeopleModelTypeParents,
    DWDNearPeopleModelTypeStudents
};

typedef NS_ENUM(NSUInteger , DWDNearPeopleModelGender){
    DWDNearPeopleModelGenderMan = 1,
    DWDNearPeopleModelGenderWomen
};

@interface DWDNearPeopleModel : NSObject

@property (nonatomic , strong) NSNumber *userId;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , strong) NSNumber *educhatAccount;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , assign) DWDNearPeopleModelType type;  //type 4-教师号 5-家长号 6-学生号
@property (nonatomic , assign) DWDNearPeopleModelGender gender;   // 1-男 2-女
@property (nonatomic , copy) NSString *photoKey;
@property (nonatomic , strong) NSNumber *districtCode;
@property (nonatomic , copy) NSString *school;   // 学校名称
@property (nonatomic , copy) NSString *classGrade;  // 班级名称
@property (nonatomic , assign) BOOL isFriend;
@property (nonatomic , strong) NSNumber *distance;  // 附近多少米

@end
