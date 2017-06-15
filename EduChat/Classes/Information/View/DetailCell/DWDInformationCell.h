//
//  DWDInformationCell.h
//  EduChat
//
//  Created by Gatlin on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//  资讯列表cell

#import <UIKit/UIKit.h>

@class DWDArticleFrameModel;
@interface DWDInformationCell : UITableViewCell
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nickname;   //来源
@property (nonatomic, strong) UILabel *title;      //标题
@property (nonatomic, strong) UIImageView *readIcon;      //阅读icon
@property (nonatomic, strong) UILabel *readcnt;      //阅读数
@property (nonatomic, strong) UIImageView *praiseIcon;      //点赞icon
@property (nonatomic, strong) UILabel *praisecnt;      //点赞数
@property (nonatomic, strong) UILabel *time;        //发布时间
@property (nonatomic, strong) UILabel *unreadCnt;   // 未读数(订阅)

@property (nonatomic, strong) DWDArticleFrameModel *fmodel;
@end


@interface DWDArticleCell : DWDInformationCell
- (instancetype)initArticleCellWithTableView:(UITableView *)tableView;
@end


@interface DWDPhotoCell : DWDInformationCell
- (instancetype)initPhotoCellWithTableView:(UITableView *)tableView;
@end


@interface DWDVideoCell : DWDInformationCell
- (instancetype)initVideoCellWithTableView:(UITableView *)tableView;
@end



