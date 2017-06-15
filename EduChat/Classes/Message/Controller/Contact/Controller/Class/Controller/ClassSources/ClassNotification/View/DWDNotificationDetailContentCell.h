//
//  DWDNotificationDetailContentCell.h
//  EduChat
//
//  Created by doublewood on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//  通知详情内容Cell

#import <UIKit/UIKit.h>

@interface DWDNotificationDetailContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (strong, nonatomic) NSNumber *type;

@property (assign, nonatomic) float notiDetailContentHight;

@property (strong, nonatomic) NSDictionary *dictDataSource;

@end
