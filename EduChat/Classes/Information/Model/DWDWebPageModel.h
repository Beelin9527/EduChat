//
//  DWDWebPageModel.h
//  EduChat
//
//  Created by Gatlin on 16/8/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDVisitStat.h"

@interface DWDMenu : NSObject
@property (nonatomic, strong) NSNumber *authType;
@property (nonatomic, strong) NSNumber *menuId;
@end


@interface DWDWebPageModel : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *topic;
@property (nonatomic, assign) BOOL *isPay;
@property (nonatomic, strong) NSString *contentLink;
@property (nonatomic, strong) NSString *shareLink;
@property (nonatomic, strong) NSNumber *collectId;

@property (nonatomic, strong) DWDVisitStat *visitStat;
@property (nonatomic, strong) DWDMenu *menu;
@end


