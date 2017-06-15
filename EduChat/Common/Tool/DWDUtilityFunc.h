//
//  DWDUtilityFunc.h
//  EduChat
//
//  Created by Catskiy on 16/8/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDUtilityFunc : NSObject

#pragma mark scrollView顶部视图下拉放大
/**
 *  scrollView顶部视图下拉放大
 *
 *  @param imageView  需要放大的图片
 *  @param headerView 图片所在headerView 如果没有则传图片自己本身
 *  @param height     图片的高度
 *  @param offsetY    设置偏移多少开始形变  例如是：offset_y = 64 说明就是y向下偏移64像素开始放大
 *  @param scrollView 对应的scrollView
 */
+(void)setHeaderViewDropDownEnlargeImageView:(UIImageView *)imageView withHeaderView:(UIView *)headerView withImageViewHeight:(CGFloat)height withOffsetY:(CGFloat)offsetY withScrollView:(UIScrollView *)scrollView;

@end
