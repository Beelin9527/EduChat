//
//  DWDPickUpCenterListDataBaseModel.h
//  EduChat
//
//  Created by KKK on 16/3/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDPickUpCenterListDataBaseModel : NSObject

@property (nonatomic, strong) NSNumber *schoolId;
@property (nonatomic, copy) NSString *schoolName;
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *studentName;
@property (nonatomic, copy) NSNumber *badgeNumber;

@end
