//
//  DWDMyClassModel.h
//  EduChat
//
//  Created by Superman on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DWDClassModel : NSObject
@property (nonatomic , strong) NSNumber *classId;
@property (nonatomic , copy) NSString *className;
@property (nonatomic , strong) NSNumber *memberNum;
@property (nonatomic , copy) NSString *photoKey;
@property (nonatomic , strong) NSNumber *status;
@property (nonatomic , strong) NSNumber *level;
@property (nonatomic , strong) NSNumber *albumId;
@property (nonatomic , strong) NSNumber *isMian;
@property (nonatomic , strong) NSNumber *isManager;
@property (nonatomic , strong) NSNumber *isShowNick;
@property (nonatomic , strong) NSNumber *isExist;
@property (copy, nonatomic) NSString *introduce;
@property (strong, nonatomic) NSNumber *schoolId;
@property (copy, nonatomic) NSString *schoolName;
@property (copy, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSNumber *classAcct;
@end
