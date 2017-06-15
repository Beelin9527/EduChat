//
//  DWDIntSchoolItemView.h
//  EduChat
//
//  Created by Beelin on 16/12/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDSchoolModel;
@interface DWDIntSchoolItemView : UIView

@property (nonatomic, strong) void(^selectItemBlock)(DWDSchoolModel *model);
@property (nonatomic, strong) void(^removeFromSuperViewBlock)();
@property (nonatomic, copy) NSArray *dataSource;

@end
