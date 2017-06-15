//
//  DWDPickUpCenterDataBaseModel.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterDataBaseModel.h"

@implementation DWDPickUpCenterDataBaseModel

- (id)copyWithZone:(NSZone *)zone {
    DWDPickUpCenterDataBaseModel *model = [[DWDPickUpCenterDataBaseModel allocWithZone:zone] init];
    model.custId = self.custId;
    model.name = self.name;
    model.photokey = self.photokey;
    model.schoolId = self.schoolId;
    model.schoolName = self.schoolName;
    model.classId = self.classId;
    model.className = self.className;
    model.relation = self.relation;
    model.contextual = self.contextual;
    model.photo = self.photo;
    model.date = self.date;
    model.time = self.time;
    model.parent = self.parent;
    model.type = self.type;
    model.formatTime = self.formatTime;
    model.teacher = self.teacher;
    model.index = self.index;
    return model;
}

- (instancetype)init {
    self = [super init];
    
    self.parent = [DWDPickUpCenterParentDataBaseModel new];
    self.teacher = [DWDPickUpCenterTeacherDataBaseModel new];
    
    return self;
}

@end
