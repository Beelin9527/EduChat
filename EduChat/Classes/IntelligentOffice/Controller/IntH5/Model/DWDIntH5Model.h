//
//  DWDIntH5Model.h
//  EduChat
//
//  Created by Catskiy on 2016/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDIntH5Model : NSObject

@property (nonatomic, strong) NSNumber *cid; //班级ID
@property (nonatomic, strong) NSNumber *uid; //客户ID

@property (nonatomic, strong) NSNumber *schoolId; //学校ID
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NSString *token;

@end
