//
//  DWDUtilityFunc.m
//  EduChat
//
//  Created by Catskiy on 16/8/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDUtilityFunc.h"

@implementation DWDUtilityFunc

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
+(void)setHeaderViewDropDownEnlargeImageView:(UIImageView *)imageView withHeaderView:(UIView *)headerView withImageViewHeight:(CGFloat)height withOffsetY:(CGFloat)offsetY withScrollView:(UIScrollView *)scrollView{
    CGFloat yOffset = scrollView.contentOffset.y;
    //向上偏移量变正  向下偏移量变负
    /**
     *  设置偏移多少开始形变  例如是：offset_y = 64 说明就是y向下偏移64像素开始放大
     宏：k_headerViewHeight 就是header的高度
     */
    CGFloat offset_y = offsetY;
    CGFloat imageHeight = height;
    
    if (yOffset < -offset_y) {
        CGFloat factor = ABS(yOffset)+imageHeight-offset_y;
        CGRect f = CGRectMake(-([[UIScreen mainScreen] bounds].size.width*factor/imageHeight-[[UIScreen mainScreen] bounds].size.width)/2,-ABS(yOffset)+offset_y, [[UIScreen mainScreen] bounds].size.width*factor/imageHeight, factor);
        imageView.frame = f;
    }else {
        CGRect f = headerView.frame;
        f.origin.y = 0;
        headerView.frame = f;
        imageView.frame = CGRectMake(0, f.origin.y, [[UIScreen mainScreen] bounds].size.width, imageHeight);
    }
}

@end
