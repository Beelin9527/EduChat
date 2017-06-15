//
//  DWDSubscribeListCell.h
//  EduChat
//
//  Created by Beelin on 16/11/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDArticleModel.h"

@interface DWDSubscribeListCell : UITableViewCell
@property (nonatomic, strong) DWDArticleModel *articleModel;
@property (nonatomic, strong) void(^comeInExpertInfoBlock)(DWDArticleModel *articleModel);
@end

/** 文章 */
@interface DWDSubscribeListArticleCell : DWDSubscribeListCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

/** 图片 */
@interface DWDSubscribeListPhotoCell : DWDSubscribeListCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end


/** 视频 继承图片cell*/
@interface DWDSubscribeListVideoCell : DWDSubscribeListPhotoCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
