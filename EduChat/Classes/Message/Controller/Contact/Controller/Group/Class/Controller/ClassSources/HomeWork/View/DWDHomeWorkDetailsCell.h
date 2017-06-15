//
//  DWDHomeWorkDetailsCell.h
//  EduChat
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "DWDHomeWorkDetailModel.h"
@class DWDHomeWorkDetailsCell;

@protocol DWDHomeWorkDetailsCellDelegate <NSObject>

@optional
/**
 *  点击了图片
 */
- (void)growCell:(DWDHomeWorkDetailsCell *)cell didClickImageView:(UIImageView *)imgView withIndex:(NSInteger)index;

@end

@interface DWDHomeWorkDetailsCell : UITableViewCell

@property (strong, nonatomic) DWDHomeWorkDetailModel *homeWorkModel;
@property (strong, nonatomic) UILabel                *contentTitleLabel;
@property (strong, nonatomic) UILabel                *deadlineTitleLabel;
@property (strong, nonatomic) UILabel                *fromTitleLabel;
@property (strong, nonatomic) UILabel                *titleLabel;
@property (strong, nonatomic) UILabel                *subjectLabel;
@property (strong, nonatomic) UILabel                *dateLabel;
@property (strong, nonatomic) TTTAttributedLabel     *contentLabel;
@property (strong, nonatomic) UILabel                *deadlineLabel;
@property (strong, nonatomic) TTTAttributedLabel     *fromLabel;
@property (strong, nonatomic) UIButton               *finishBtn;
@property (strong, nonatomic) UIImageView            *iconImgV;
@property (strong, nonatomic) NSArray                *picsArray;

@property (nonatomic, weak  ) id<DWDHomeWorkDetailsCellDelegate> delegate;

- (CGFloat)getHeight;

@end
