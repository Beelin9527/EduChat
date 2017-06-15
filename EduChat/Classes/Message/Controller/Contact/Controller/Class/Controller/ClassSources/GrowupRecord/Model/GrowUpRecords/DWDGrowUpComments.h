//
//  DWDGrowUpComments.h
//  EduChat
//
//  Created by Superman on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDGrowUpComments : NSObject
@property (nonatomic , copy) NSString *addtime;
@property (nonatomic , strong) NSNumber *commentId;
@property (nonatomic , copy) NSString *commentTxt;
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , strong) NSNumber *forCustId;
@property (nonatomic , copy) NSString *forNickname;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *photokey;

@end
