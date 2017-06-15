//
//  DWDUserSearchSuperViewController.h
//  EduChat
//
//  Created by apple on 11/6/15.
//  Copyright © 2015 dwd. All rights reserved.
//  基类 搜索 ViewController

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DWDSearchResultViewController.h"
#import "DWDNavViewController.h"
@interface DWDUserSearchSuperViewController : BaseViewController

@property (nonatomic) BOOL isShowTabbarWhenDismiss;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableView *searchTableView;         //搜索TableView
@property (nonatomic,strong) UILabel *notDataResultLab;             //搜索无结果Label
@property (strong, nonatomic) NSMutableArray *arrSearchResult;      //搜索结果数据

- (UIBarButtonItem *)buildPublicNavBarItem;

@end
