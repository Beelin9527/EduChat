//
//  BaseTableViewController.h
//  EduChat
//
//  Created by Gatlin on 16/1/29.
//  Copyright © 2016年 dwd. All rights reserved.
//  基类 TableView

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UIImageView *noDataImv;   //列表空数据。加载此ImageView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;


/**
 * 小免崽子状态View
 */
@property (nonatomic, strong) UIView *stateView;
- (UIView *)setupStateViewWithImageName:(NSString *)imageName describe:(NSString *)describe;
- (UIView *)setupStateViewWithImageName:(NSString *)imageName describe:(NSString *)describe reloadDataBtnEventBlock:(void(^)())block;
/** 动画 拼命加载 */
- (UIView *)setupStateLoadView;
@end
