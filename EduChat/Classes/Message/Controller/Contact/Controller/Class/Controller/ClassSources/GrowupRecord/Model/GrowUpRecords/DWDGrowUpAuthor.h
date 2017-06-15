//
//  DWDGrowUpAuthor.h
//  EduChat
//
//  Created by Superman on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDGrowUpAuthor : NSObject

@property (nonatomic , copy) NSString *addtime;  // 创建时间
@property (nonatomic , strong) NSNumber *authorId;  // cusID
@property (nonatomic , copy) NSString *name;    //
@property (nonatomic , copy) NSString *photokey; //  头像的URL

@end
