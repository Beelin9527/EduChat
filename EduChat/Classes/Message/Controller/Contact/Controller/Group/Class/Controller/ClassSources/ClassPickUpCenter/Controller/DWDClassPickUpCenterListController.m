//
//  DWDClassPickUpCenterListController.m
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassPickUpCenterListController.h"
#import "DWDTeacherDetailViewController.h"

#import "DWDPickUpCenterListCell.h"

#import "DWDPickUpCenterListDataBaseModel.h"
#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

@interface DWDClassPickUpCenterListController ()

@property (nonatomic, strong) NSArray *listArray;

@end

@implementation DWDClassPickUpCenterListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    self.navigationItem.title = @"接送中心";
    [self.tableView registerClass:[DWDPickUpCenterListCell class] forCellReuseIdentifier:@"cell"];
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDPickUpCenterListCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *array = [[DWDPickUpCenterDatabaseTool sharedManager] selectTeacherList];
    _listArray = array;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    /**
     DWDPickUpCenterDidUpdateListInfomation
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tableViewShouldUpdate)
                                                 name:DWDPickUpCenterDidUpdateListInfomation
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DWDPickUpCenterDidUpdateListInfomation
                                                  object:nil];
}

#pragma mark - Notification
- (void)tableViewShouldUpdate {
    self.listArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectTeacherList];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDPickUpCenterListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.dataModel = self.listArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //提示数字逻辑更改 只有点进某个班级的时候 才清空该班级的红点数字
    //当在更深层次的页面(view will disappear)的时候,更改badge number,更改逻辑跟
    //现在决定在返回之前不改了 尝试一下
    
    DWDPickUpCenterListDataBaseModel *dataModel = self.listArray[indexPath.row];
    //badge number 清零
//    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:dataModel.classId subNumber:dataModel.badgeNumber];
    
    DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
    vc.classId = dataModel.classId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
