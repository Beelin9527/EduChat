//
//  DWDSearchResultController.m
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSearchResultController.h"
@interface DWDSearchResultController ()

@end

@implementation DWDSearchResultController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setResults:(NSArray *)results{
    _results = results;
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    cell.textLabel.text = _results[indexPath.row];
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 通知代理, 结果中的某一行被点了,
    if ([self.resultVcDelegate respondsToSelector:@selector(resultControllerCellDidSelectWithResults:indexPath:)]) {
        [self.resultVcDelegate resultControllerCellDidSelectWithResults:_results indexPath:indexPath];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _searchBar.text = nil;
}


@end
