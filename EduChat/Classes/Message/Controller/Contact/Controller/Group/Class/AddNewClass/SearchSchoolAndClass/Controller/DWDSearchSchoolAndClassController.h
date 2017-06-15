//
//  DWDSearchSchoolAndClassController.h
//  EduChat
//
//  Created by Superman on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDSearchSchoolAndClassController : UIViewController
@property (nonatomic , copy) NSString *detailRegionCode;
@property (nonatomic , copy) NSString *province;
@property (nonatomic , copy) NSString *cityName;
@property (nonatomic , copy) NSString *regionName;

@property (nonatomic , copy) NSString *selectSchoolName;
@property (nonatomic , copy) NSString *selectClassName;

@property (nonatomic , strong) NSNumber *schoolId;


@end
