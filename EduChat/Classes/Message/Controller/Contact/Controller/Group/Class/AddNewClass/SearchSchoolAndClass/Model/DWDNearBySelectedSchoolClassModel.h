//
//  DWDNearBySelectedSchoolClassModel.h
//  EduChat
//
//  Created by Superman on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDNearBySelectedSchoolClassModel : NSObject
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , strong) NSNumber *standardId;
@property (nonatomic , assign) BOOL used;

@end
