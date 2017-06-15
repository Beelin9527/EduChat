//
//  DWDSchoolModel.h
//  EduChat
//
//  Created by Beelin on 16/12/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDIntClassModel : NSObject
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, copy) NSString *className;
@end

@interface DWDSchoolModel : NSObject
@property (nonatomic, strong) NSNumber *schoolId;
@property (nonatomic, copy) NSString *schoolName;
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) NSArray <DWDIntClassModel*> *arrayClassModel;
@end

