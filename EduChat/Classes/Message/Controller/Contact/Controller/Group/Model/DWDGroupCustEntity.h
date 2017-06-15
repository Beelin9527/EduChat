//
//  DWDGroupCustEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/22.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 custId = 4010000005414;
 myCustId = 4010000005410;
 nickname = "158\U767d\U4e91heitu66";
 photoKey = "http://192.168.1.70:8080/EduChatWebService/html/img/defaulthead.png";
 remark = 4010000005414;
 state = 0;

 
 
 */

@interface DWDGroupCustEntity : NSObject
@property (strong, nonatomic) NSNumber *custId;
@property (copy, nonatomic) NSString *nickname;
@property (copy, nonatomic) NSString *photoKey;
@property (copy, nonatomic) NSString *remark;

-(instancetype)initWithDict:(NSDictionary*)dict;
+ (NSMutableArray *)initWithArray:(NSArray *)array;
@end
