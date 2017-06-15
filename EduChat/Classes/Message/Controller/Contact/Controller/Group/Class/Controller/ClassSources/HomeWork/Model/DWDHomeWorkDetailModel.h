//
//  DWDHomeWorkDetailModel.h
//  EduChat
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDHomeWorkDetailModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *subject;
@property (nonatomic, assign) BOOL     isFinished;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *addTime;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *deadLine;
@property (nonatomic, strong) NSArray *picsArray;

@end
