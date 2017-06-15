//
//  DWDAddNotificationSelectedCell.h
//  EduChat
//
//  Created by KKK on 16/5/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CellCheckType) {
    CellCheckTypeNone,
    CellCheckTypeSelected,
    CellCheckTypeDisabled,
};

@class DWDClassNotificationSelectGroupModel;
@interface DWDAddNotificationSelectedCell : UITableViewCell

@property (nonatomic, strong) DWDClassNotificationSelectGroupModel *model;

@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, assign) CellCheckType type;

@end
