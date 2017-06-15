//
//  DWDPickUpCenterStudentsModel.m
//  EduChat
//
//  Created by KKK on 16/4/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterStudentsCountModel.h"

@implementation DWDPickUpCenterStudentsCountModel
//@property (nonatomic, copy) NSString *toSchool;
//@property (nonatomic, copy) NSString *afterSchool;
//@property (nonatomic, strong) NSNumber  *index;
//@property (nonatomic, assign) NSInteger memberNum;
//@property (nonatomic, assign) NSInteger noteNum;
//@property (nonatomic, assign) NSInteger attendanceNum;
//@property (nonatomic, assign) CGFloat attendanceRate;
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.toSchool forKey:@"toSchool"];
    [aCoder encodeObject:self.afterSchool forKey:@"index"];
    [aCoder encodeObject:self.index forKey:@"index"];
    [aCoder encodeInteger:self.memberNum forKey:@"memberNum"];
    [aCoder encodeInteger:self.noteNum forKey:@"noteNum"];
    [aCoder encodeInteger:self.attendanceNum forKey:@"attendanceNum"];
    [aCoder encodeFloat:self.attendanceRate forKey:@"attendanceRate"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    self.toSchool = [aDecoder decodeObjectForKey:@"toSchool"];
    self.afterSchool = [aDecoder decodeObjectForKey:@"afterSchool"];
    self.index = [aDecoder decodeObjectForKey:@"index"];
    self.memberNum = [aDecoder decodeIntegerForKey:@"memberNum"];
    self.noteNum = [aDecoder decodeIntegerForKey:@"noteNum"];
    self.attendanceNum = [aDecoder decodeIntegerForKey:@"attendanceNum"];
    self.attendanceRate = [aDecoder decodeFloatForKey:@"attendanceRate"];
    return self;
}

@end
