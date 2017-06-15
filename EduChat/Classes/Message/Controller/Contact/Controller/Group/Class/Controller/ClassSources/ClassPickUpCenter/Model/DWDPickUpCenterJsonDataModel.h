//
//  DWDPickUpCenterJsonDataModel.h
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterDataBaseModel.h"

#import <Foundation/Foundation.h>

@interface DWDPickUpCenterJsonDataModel : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) DWDPickUpCenterDataBaseModel *entity;

@property (nonatomic , copy) NSString *uuid;

@end
