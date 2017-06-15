//
//  DWDCollectModel.h
//  EduChat
//
//  Created by Gatlin on 16/8/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDArticleModel.h"
#import "DWDInfoExpertModel.h"
@interface DWDCollectModel : NSObject
@property (nonatomic, strong) NSNumber *collectId;
@property (nonatomic, strong) NSNumber *contentCode;
@property (nonatomic, strong) NSString *collectime;

@property (nonatomic, strong) DWDArticleModel *New;
@property (nonatomic, strong) DWDArticleModel *article;
@property (nonatomic, strong) DWDInfoExpertModel *expert;

@property (nonatomic, assign) float height;
@end