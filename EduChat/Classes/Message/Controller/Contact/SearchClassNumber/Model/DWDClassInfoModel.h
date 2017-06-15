//
//  DWDClassInfoModel.h
//  EduChat
//
//  Created by Superman on 16/2/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

/*
 classGrade = 0;
 classId = 8010000001080;
 className = "\U4e8c\U5e74\U7ea7\U4e00\U73ed";
 classNum = 0;
 introduce = "";
 isClose = 0;
 isShowNick = 1;
 isTop = 0;
 memberNum = 4;
 nickName = "";
 standardId = 0;
 */

#import <Foundation/Foundation.h>

@interface DWDClassInfoModel : NSObject
@property (nonatomic , strong) NSNumber *classGrade;
@property (nonatomic , strong) NSNumber *classId;
@property (nonatomic , copy) NSString *className;
@property (nonatomic , strong) NSNumber *classNum;
@property (nonatomic , copy) NSString *introduce;
@property (nonatomic , assign) BOOL isClose;
@property (nonatomic , assign) BOOL isShowNick;
@property (nonatomic , assign) BOOL isTop;
@property (nonatomic , strong) NSNumber *memberNum;
@property (nonatomic , copy) NSString *nickName;
@property (nonatomic , strong) NSNumber *standardId;

@end
