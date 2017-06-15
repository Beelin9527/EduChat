//
//  DWDExpertHomeViewController.h
//  EduChat
//
//  Created by Catskiy on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "BaseViewController.h"

@interface DWDExpertHomeViewController : BaseViewController

@property (nonatomic, strong) NSNumber *expertId;

/**
 *  订阅,取消订阅的回调
 */
@property (nonatomic, copy) void(^subscribeBlock)(BOOL isSub);

/**
 *  收藏列表 取消收藏的回调
 */
@property (nonatomic, copy) void(^collectCancleBlock)(NSNumber *collectId);
@end
