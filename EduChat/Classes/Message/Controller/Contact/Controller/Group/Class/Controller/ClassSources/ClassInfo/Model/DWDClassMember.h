//
//  DWDClassMember.h
//  EduChat
//
//  Created by Superman on 16/2/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 custId = 4010000005409;
 educhatAccount = abc;
 isManager = 1;
 isMian = 1;
 name = "\U674e\U6bc5\U5927\U5e1d";
 nickname = "";
 photokey = "http://192.168.1.70:8080/EduChatWebService/html/img/defaulthead.png";
 */
@interface DWDClassMember : NSObject

@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , copy) NSString *educhatAccount;
@property (nonatomic , strong) NSNumber *isManager;
@property (nonatomic , strong) NSNumber *isMian;
@property (nonatomic , copy) NSString *name;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *remarkName;

@property (nonatomic , copy) NSString *photoKey;
@property (strong, nonatomic) NSNumber *isExist;  //是否存在这个班级

@end

