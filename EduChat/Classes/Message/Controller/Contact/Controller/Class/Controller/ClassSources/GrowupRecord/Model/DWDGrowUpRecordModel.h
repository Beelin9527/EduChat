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


@end
