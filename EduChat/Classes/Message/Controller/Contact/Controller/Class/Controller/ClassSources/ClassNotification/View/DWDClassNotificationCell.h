//
//  DWDClassNotificationCell.h
//  EduChat
//
//  Created by Superman on 15/11/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDClassNotificatoinListEntity;
@interface DWDClassNotificationCell : UITableViewCell

@property (strong, nonatomic) DWDClassNotificatoinListEntity *entity;
+ (instancetype)cellWithTableView:(UITableView *)tableview;
@end
