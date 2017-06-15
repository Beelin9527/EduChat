//
//  DWDGroupInfoViewController.h
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "BaseViewController.h"
@class DWDGroupEntity;
@interface DWDGroupInfoViewController : BaseViewController
//@property (nonatomic, strong) NSNumber *<#name#>;
@property (strong, nonatomic) DWDGroupEntity *groupModel;
@end
