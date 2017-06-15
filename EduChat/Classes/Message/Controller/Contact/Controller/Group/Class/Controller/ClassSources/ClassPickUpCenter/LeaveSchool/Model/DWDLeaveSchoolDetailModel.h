//
//  DWDLeaveSchoolDetailModel.h
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDLeaveSchoolDetailModel : NSObject

@property (nonatomic, copy) NSString *studentPhotoStr;
@property (nonatomic, copy) NSString *parentPhotoStr;
@property (nonatomic, copy) NSString *studentName;
@property (nonatomic, copy) NSString *parentName;
@property (nonatomic, copy) NSString *statusData;
@property (nonatomic, copy) NSString *leaveTime;
@property (nonatomic, copy) NSString *leaveType;

@property (nonatomic, assign) int type;

@end
