//
//  DWDNotificationHeaderIocnTableViewCell.h
//  EduChat
//
//  Created by Gatlin on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//  通知已读、未读Cell

#import <UIKit/UIKit.h>

@interface DWDNotificationHeaderIocnTableViewCell : UITableViewCell
@property (assign, nonatomic) float cellHight;
@property (nonatomic, strong) NSArray *userArray;

@property (nonatomic, strong) NSNumber *type;
@end
