//
//  DWDAuthorEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//  作者 entity

#import <Foundation/Foundation.h>

@interface DWDAuthorEntity : NSObject

@property (copy, nonatomic) NSNumber *addTime;
@property (strong, nonatomic) NSNumber *authorId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *photoKey;

- (id)initWithDict:(NSDictionary *)dict;

+ (NSMutableArray *)initWithArray:(NSArray *)array;
@end


/*
 author =                 {
 addtime = "2015-12-29";
 authorId = 4010000005409;
 name = "";
 photokey = "";
 };
*/