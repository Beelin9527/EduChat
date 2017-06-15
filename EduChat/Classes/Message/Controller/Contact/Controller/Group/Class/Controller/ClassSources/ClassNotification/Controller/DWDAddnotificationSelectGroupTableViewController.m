//
//  DWDAddnotificationSelectGroupTableViewController.m
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//
#define kCellIdentifier @"groupSelectCell"

#import "DWDAddnotificationSelectGroupTableViewController.h"
#import "DWDAddNotificationSelectedCell.h"
#import "DWDClassModel.h"

@interface DWDAddnotificationSelectGroupTableViewController ()

@property (nonatomic, strong) NSMutableArray *groupArray;
@end

@implementation DWDAddnotificationSelectGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *completeButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemClick)];
    
    self.navigationItem.rightBarButtonItem = completeButton;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.tableView setEditing:YES];
    
}
#pragma mark - private method
- (NSArray *)getGroupArrayWithRequst {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:[DWDCustInfo shared].custId forKey:@"custId"];
    [params setValue:self.myClass.classId forKey:@"classId"];
    WEAKSELF;
    [[HttpClient sharedClient] getClassGroupListWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *ar = responseObject[@"data"];
            for (int i = 0; i < ar.count; i ++) {
                [weakSelf.groupArray addObject:ar[i][@"name"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"%@", error);
    }];
    return self.groupArray;
}

#pragma mark - event response

- (void)rightBarButtonItemClick {
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDAddNotificationSelectedCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.textLabel.text = @"123";
    
    return cell;
}

#pragma mark - TableViewDelagate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        for (DWDAddNotificationSelectedCell *cell in [tableView visibleCells]) {
            if ([tableView indexPathForCell:cell].row != 0) {
                cell.type = CellCheckTypeDisabled;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        for (DWDAddNotificationSelectedCell *cell in [tableView visibleCells]) {
            cell.type = CellCheckTypeNone;
        }
    }
}

#pragma mark - setter / getter

- (NSMutableArray *)groupArray {
    if (!_groupArray) {
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@"发送给全班"];
        _groupArray = array;
    }
    return _groupArray;
}

@end
