//
//  DWDIntHeaderClassInfoCell.h
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HeaderType) {
    DWDClassManagerHeaderType,
    DWDclassMainHeaderType
};


@class DWDClassModel, DWDIntHeaderClassInfoCell;
@protocol DWDIntHeaderClassInfoCellDelegate <NSObject>

@optional
/** 
 click avatar
 */

- (void)intHeaderClassInfoCellClickAvatar:(DWDIntHeaderClassInfoCell *)cell;

/**
 click intro
 */
- (void)intHeaderClassInfoCell:(DWDIntHeaderClassInfoCell *)cell clickIntroWithClassModel:(DWDClassModel *)classModel;
@end


@interface DWDIntHeaderClassInfoCell : UITableViewCell

@property (nonatomic, assign) HeaderType headertype;
@property (nonatomic, strong) DWDClassModel *classModel;
@property (nonatomic,weak) id<DWDIntHeaderClassInfoCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
