//
//  DWDGroupInfoCell.h
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDGroupInfoModel;
@interface DWDGroupInfoCell : UITableViewCell
@property (strong, nonatomic) DWDGroupInfoModel *groupInfoModel;

@property (nonatomic, strong) void(^clickShowNicknameButton)(NSNumber *state);
@end
