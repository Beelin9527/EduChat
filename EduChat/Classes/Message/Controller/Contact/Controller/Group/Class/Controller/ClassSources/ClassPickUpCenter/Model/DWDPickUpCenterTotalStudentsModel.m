//
//  DWDPickUpCenterTotalStudentsModel.m
//  EduChat
//
//  Created by KKK on 16/6/27.
//  Copyright © 2016年 dwd. All rights reserved.
//




#import "DWDPickUpCenterTotalStudentsModel.h"

@implementation DWDPickUpCenterTotalStudentsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"students" : [DWDTeacherGoSchoolStudentDetailModel class],
             };
}

////第 index 次 上/放学
//@property (nonatomic, strong) NSNumber *index;
////上学 1 还是放学 2
//@property (nonatomic, strong) NSNumber *type;
////全学生数组
//@property (nonatomic, strong) NSArray<DWDPickUpCenterTotalStudentsModel *> *students;
////本次请求的失效日期
//@property (nonatomic, copy) NSString *deadline;
////存储时 记录日期 自行写入
////存储时 记录时间 自行写入 时间用来判断 最后一条消息的时间和最后一次存储请求的时间之间的关系
//@property (nonatomic, strong) NSDate *dateTime;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.index forKey:@"index"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.students forKey:@"students"];
    [aCoder encodeObject:self.deadline forKey:@"deadline"];
    [aCoder encodeObject:self.dateTime forKey:@"dateTime"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    self.index = [aDecoder decodeObjectForKey:@"index"];
    self.type = [aDecoder decodeObjectForKey:@"type"];
    self.students = [aDecoder decodeObjectForKey:@"students"];
    self.deadline = [aDecoder decodeObjectForKey:@"deadline"];
    self.dateTime = [aDecoder decodeObjectForKey:@"dateTime"];
    
    return self;
}


@end
