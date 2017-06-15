//
//  OOStretchTableHeaderView.h
//  StretchTableHeaderView
//
//  Created by Gatlin-man on 16/4/7.
//  Copyright © 2016年 Gatlin. All rights reserved.
//  TableView headerView 图片拉伸

/**  需要在控制器实现此方法，进行布局
 - (void)viewDidLayoutSubviews
 {
    resizeView
 }
 
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface OOStretchTableHeaderView : NSObject
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *view;

+ (instancetype)stretchHeaderForTableView:(UITableView*)tableView withView:(UIView*)view;
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
- (void)resizeView;

@end
