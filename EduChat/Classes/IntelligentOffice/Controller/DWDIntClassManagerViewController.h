//
//  DWDIntClassManagerViewController.h
//  EduChat
//
//  Created by Beelin on 16/12/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "BaseViewController.h"

#import "DWDIntClassItemView.h"

@class DWDSchoolModel;
@interface DWDIntClassManagerViewController : BaseViewController
@property (nonatomic, strong) DWDIntClassItemView *intClassItemView;

@property (nonatomic, strong) DWDSchoolModel *schoolModel;
@end
