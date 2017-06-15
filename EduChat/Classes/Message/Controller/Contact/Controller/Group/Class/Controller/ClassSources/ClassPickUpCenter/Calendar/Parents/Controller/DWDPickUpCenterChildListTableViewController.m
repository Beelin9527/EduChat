//
//  DWDPickUpCenterChildListTableViewController.m
//  EduChat
//
//  Created by KKK on 16/3/28.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterChildListTableViewController.h"
#import "DWDPickUpCenterChildTableViewController.h"

#import "DWDPickUpCenterListCell.h"

#import "DWDPickUpCenterListDataBaseModel.h"
#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDPickUpCenterDatabaseTool.h"

#import "NSString+extend.h"

@interface DWDPickUpCenterChildListTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation DWDPickUpCenterChildListTableViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:[DWDPickUpCenterListCell class] forCellReuseIdentifier:@"cell"];
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDPickUpCenterListCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray *array = [[DWDPickUpCenterDatabaseTool sharedManager] selectChildList];
    _dataArray = array;
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    self.dataArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectTeacherList];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDPickUpCenterListDataBaseModel *dataModel = self.dataArray[indexPath.row];
    DWDPickUpCenterListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.dataModel = dataModel;
    return cell;
}

#pragma mark - UITablbeViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DWDPickUpCenterChildTableViewController *vc = [DWDPickUpCenterChildTableViewController new];
    DWDPickUpCenterListDataBaseModel *model = self.dataArray[indexPath.row];
    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:model.classId subNumber:model.badgeNumber];
    vc.classId = model.classId;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
