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
//消息已读/未读 设置不同的textcolor
@property (nonatomic, strong) NSNumber *readed;

+ (instancetype)cellWithTableView:(UITableView *)tableview;
@end
