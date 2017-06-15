//
//  DWDHomeWorkListCell.h
//  EduChat
//
//  Created by Catskiy on 2016/10/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDHomeWorkCellDelegate <NSObject>
@required
- (void)homeWorkCellDidMultiSelectAtIndexPath:(NSIndexPath *)indexPath;
- (void)homeWorkCellDidMultiDisselectAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface DWDHomeWorkListCell : UITableViewCell

@property (nonatomic, strong) UIButton *selectBtn;
@property (nonatomic, strong) UIImageView *backImgV;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *homeWorkLabel;
@property (nonatomic, strong) UILabel *homeWorkSubjectLabel;
@property (nonatomic, assign) BOOL canSelected;

@property (nonatomic) BOOL isMultiSelected;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<DWDHomeWorkCellDelegate> actionDelegate;

@end
