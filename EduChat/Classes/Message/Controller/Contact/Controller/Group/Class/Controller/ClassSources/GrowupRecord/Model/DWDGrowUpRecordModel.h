//
//  DWDGrowUpRecordModel.h
//  EduChat
//
//  Created by Superman on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDGrowUpAuthor.h"
#import "DWDGrowUpRecord.h"
#import "DWDGrowUpVisitstat.h"
#import "DWDPhotoInfoModel.h"
#import "DWDGrowUpComments.h"

@interface DWDGrowUpRecordModel : NSObject

@property (nonatomic , strong) DWDGrowUpAuthor *author;
@property (nonatomic , strong) DWDGrowUpRecord *record;
@property (nonatomic , strong) DWDGrowUpVisitstat *visitstat;
@property (nonatomic , strong) NSArray *photos;
@property (nonatomic , strong) NSArray *comments;
@property (nonatomic, strong) NSArray *praises;
@property (nonatomic, strong) NSNumber *forCustId;
//存储cell indexpath
@property (nonatomic, strong)NSIndexPath *indexPath;

//展开内容
@property (nonatomic, assign, getter=isExpandBody) BOOL expandBody;
//"展开"按钮的状态 默认是NO
@property (nonatomic, assign) BOOL expandButtonOn;
//展开评论列表
@property (nonatomic, assign, getter=isExpandCommentList) BOOL expandCommentList;


@end
