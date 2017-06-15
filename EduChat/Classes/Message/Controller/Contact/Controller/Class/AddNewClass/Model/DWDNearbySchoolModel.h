//
//  DWDNearbySchoolModel.h
//  EduChat
//
//  Created by Superman on 15/12/18.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDNearbySchoolModel : NSObject
@property (nonatomic , assign) long custId;
@property (nonatomic , copy) NSString *fullName;
@property (nonatomic , copy) NSString *shortName;
@property (nonatomic , copy) NSString *districtCode;
@property (nonatomic , copy) NSString *photokey;
@end
