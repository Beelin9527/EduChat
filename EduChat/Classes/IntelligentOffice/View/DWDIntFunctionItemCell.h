//
//  DWDIntFunctionItemCell.h
//  EduChat
//
//  Created by Beelin on 16/12/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntFunctionItemCell,DWDIntelligenceMenuModel;
@protocol DWDIntFunctionItemCellDelegate <NSObject>

- (void)intFunctionItemCell:(DWDIntFunctionItemCell* )intFunctionItemCell selectItemWithModel:(DWDIntelligenceMenuModel* )model;

@end
@interface DWDIntFunctionItemCell : UITableViewCell
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic,weak) id<DWDIntFunctionItemCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView headTitle:(NSString *)title;

@end
