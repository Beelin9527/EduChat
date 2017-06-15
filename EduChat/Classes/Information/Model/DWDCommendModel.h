//
//  DWDCommendModel.h
//  EduChat
//
//  Created by Gatlin on 16/8/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDArticleModel.h"
#import "DWDInfoExpertModel.h"
@interface DWDCommendModel : NSObject
@property (nonatomic, strong) NSNumber *commendId;
@property (nonatomic, strong) NSNumber *contentCode;

@property (nonatomic, strong) DWDArticleModel *New;
@property (nonatomic, strong) DWDArticleModel *article;
@property (nonatomic, strong) DWDInfoExpertModel *expert;

@property (nonatomic, assign) float height;
@end
