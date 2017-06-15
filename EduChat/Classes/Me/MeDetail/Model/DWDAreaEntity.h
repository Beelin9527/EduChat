//
//  DWDAreaEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//  区域 entity

#import <Foundation/Foundation.h>

/*
 name = "";
 regionCode = 640000;
 shortName = "";
 */
 
@interface DWDAreaEntity : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *regionCode;
@property (copy, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSArray *districtList;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)initWithArray:(NSArray *)array;
@end
