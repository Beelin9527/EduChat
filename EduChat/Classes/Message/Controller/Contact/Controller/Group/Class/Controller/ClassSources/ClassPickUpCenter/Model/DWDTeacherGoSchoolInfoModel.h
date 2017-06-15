//
//  DWDTeacherGoSchoolInfoModel.h
//  EduChat
//
//  Created by KKK on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDTeacherGoSchoolInfoModel : NSObject

@property (nonatomic, assign) NSInteger totalStudent;
@property (nonatomic, assign) NSInteger succeedCount;
@property (nonatomic, assign) NSInteger vacateCount;
/**
 *  小数
 */
@property (nonatomic, assign) CGFloat attendanceRate;

@end
