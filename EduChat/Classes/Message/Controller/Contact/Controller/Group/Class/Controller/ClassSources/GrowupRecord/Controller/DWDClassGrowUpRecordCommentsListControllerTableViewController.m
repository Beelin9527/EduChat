//
//  DWDClassGrowUpRecordCommentsListControllerTableViewController.m
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassGrowUpRecordCommentsListControllerTableViewController.h"
#import "DWDGrowCommentListCell.h"
@interface DWDClassGrowUpRecordCommentsListControllerTableViewController ()

@end

@implementation DWDClassGrowUpRecordCommentsListControllerTableViewController
static NSString *ID = @"cell";
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息列表";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentList.count;
}



- (DWDGrowCommentListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDGrowCommentListCell *cell = [DWDGrowCommentListCell cellWithTableView:tableView];
    
    cell.commentList = self.commentList[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDGrowUpRecordCommentList *commentList = self.commentList[indexPath.row];
    return commentList.cellHeight;
}

@end
