//
//  DWDLastNoteModel.h
//  EduChat
//
//  Created by Superman on 16/3/29.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDLastNoteDetail.h"
@interface DWDLastNoteModel : NSObject

@property (nonatomic , strong) NSNumber *count;

@property (nonatomic , strong) DWDLastNoteDetail *last;


@end
