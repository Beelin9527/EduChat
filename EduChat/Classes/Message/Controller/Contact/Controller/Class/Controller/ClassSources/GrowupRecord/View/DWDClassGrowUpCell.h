//
//  DWDClassGrowUpCell.h
//  EduChat
//
//  Created by Superman on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDClassGrowUpCellExtendBtnClickDelegate <NSObject>
@optional
- (void)extendBtnClickWithIndex:(NSIndexPath *)index;

@end

@class DWDGrowUpRecordFrame;
@interface DWDClassGrowUpCell : UITableViewCell
@property (nonatomic , strong) DWDGrowUpRecordFrame *growUpRecordFrame;

@property (nonatomic , weak) id<DWDClassGrowUpCellExtendBtnClickDelegate> extendBtnDelegate;
@property (nonatomic , strong) NSIndexPath *cellIndexPath;

@property (nonatomic , copy) NSString *addNewZanPeopleName;


+ (instancetype)cellWithTableView:(UITableView *)tableview;

@end
