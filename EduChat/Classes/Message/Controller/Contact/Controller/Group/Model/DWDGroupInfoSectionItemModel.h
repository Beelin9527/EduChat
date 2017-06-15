//
//  DWDGroupInfoSectionItemModel.h
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DWDGroupEntity;
@interface DWDGroupInfoSectionItemModel : NSObject
@property (strong, nonatomic) NSArray *arrSectionItem;
@property (strong, nonatomic) DWDGroupEntity *groupModel;
@end
