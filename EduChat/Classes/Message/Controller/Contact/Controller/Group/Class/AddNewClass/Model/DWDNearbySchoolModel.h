//
//  DWDNearbySchoolModel.h
//  EduChat
//
//  Created by Superman on 15/12/18.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDNearbySchoolModel : NSObject
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , copy) NSString *fullName;
@property (nonatomic , copy) NSString *shortName;
@property (nonatomic , copy) NSString *photokey;
@property (nonatomic , strong) NSNumber *regionCode;
//@property (nonatomic , strong) id photohead;
@property (nonatomic , copy) NSString *address;

@end
