//
//  DWDIntH5ViewController.h
//  EduChat
//
//  Created by Catskiy on 2016/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "BaseViewController.h"

@class DWDSchoolModel;
@interface DWDIntH5ViewController : BaseViewController

@property (nonatomic, strong) DWDSchoolModel *schoolModel;
@property (nonatomic, strong) NSNumber *schoolId;

@property (nonatomic, copy) NSString *mCode;
@property (nonatomic, copy) NSString *url;

@end
