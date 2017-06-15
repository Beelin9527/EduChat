//
//  DWDUserInfoModel.h
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDUserInfoModel : NSObject

@property (nonatomic, assign) int gender;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, strong) NSNumber *custType;




@end
