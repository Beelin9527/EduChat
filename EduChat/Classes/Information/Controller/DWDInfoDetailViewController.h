//
//  DWDInfoDetailViewController.h
//  DWDSj
//
//  Created by apple  on 15/10/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "BaseViewController.h"
@class DWDArticleModel;
@class DWDInformationCell;
@class DWDInfoExpArticleCell;

@interface DWDInfoDetailViewController : BaseViewController

@property (strong, nonatomic) NSNumber *contentCode; //外部必须赋值
@property (strong, nonatomic) NSNumber *commendId;  //外部必须赋值
@property (strong, nonatomic) NSString *contentLink;  //外部必须赋值
@property (nonatomic, strong) NSNumber *expertId;  //专家Id,仅专家传值

@property (weak, nonatomic) DWDArticleModel *articleModel;
@property (weak, nonatomic) DWDInformationCell *articleCell;
@property (weak, nonatomic) DWDInfoExpArticleCell *expArticleCell;


/**
 *  收藏列表 取消收藏的回调
 */
@property (nonatomic, copy) void(^collectCancleBlock)(NSNumber *collectId); 
@end
