//
//  DWDNotificationDetailContentCell.h
//  EduChat
//
//  Created by Gatlin on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//  通知详情内容Cell

#import <UIKit/UIKit.h>

@class DWDNotificationDetailContentCell;
@protocol DWDNotificationDetailContentCellDelegate <NSObject>

@optional
- (void)cell:(DWDNotificationDetailContentCell *)cell didClickImageView:(UIImageView *)imageView AtIndex:(NSInteger)index;

- (void)cell:(DWDNotificationDetailContentCell *)cell shouldReloadDataWithDataSource:(NSDictionary *)datasource;
@end

@interface DWDNotificationDetailContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (strong, nonatomic) NSNumber *type;
@property (assign, nonatomic) float notiDetailContentHight;

@property (strong, nonatomic) NSDictionary *dictDataSource;

@property (nonatomic, strong) NSNumber *readed;
//更新应答情况需要传的属性
@property (nonatomic, strong) NSNumber *noticeId;
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, weak) id<DWDNotificationDetailContentCellDelegate> delegate;

@end
