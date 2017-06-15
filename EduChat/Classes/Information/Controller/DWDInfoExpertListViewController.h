//
//  DWDInfoExpertListViewController.h
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, ExpertListType) {
    ExpertListTypeNomal,
    ExpertListTypeSubsc,
};

@interface DWDInfoExpertListViewController : BaseViewController

@property (nonatomic, assign) ExpertListType type;

@end
