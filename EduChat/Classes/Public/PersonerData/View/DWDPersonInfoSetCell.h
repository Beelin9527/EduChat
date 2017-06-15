//
//  DWDPersonInfoSetCell.h
//  EduChat
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DWDCellRightViewType) {
    DWDCellRightViewTypeNone,
    DWDCellRightViewTypeArrow,
    DWDCellRightViewTypeSwitch
};

@interface DWDPersonInfoSetCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UIImageView *arrowImgV;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, assign) DWDCellRightViewType rightViewType;

@end
