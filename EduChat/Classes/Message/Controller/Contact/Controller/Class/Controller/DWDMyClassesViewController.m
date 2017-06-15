//
//  DWDMyClassesViewController.m
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMyClassesViewController.h"
#import "DWDSearchResultController.h"
#import "DWDClassConversationViewController.h"
@interface DWDMyClassesViewController () <UISearchResultsUpdating , UISearchControllerDelegate , UISearchBarDelegate , DWDSearchResultControllerDelegate>
@property (nonatomic , weak) UISearchBar *searchBar;
@property (nonatomic , strong) NSArray *myClasses;
@property (nonatomic , strong) UISearchController *searchVc;
@end

@implementation DWDMyClassesViewController

/**
 *  lazy
 */
- (UISearchBar *)searchBar{
    if (!_searchBar) {
        DWDSearchResultController *searchResultVc = [[DWDSearchResultController alloc] init];
        searchResultVc.resultVcDelegate = self;
        UISearchController *searchVc = [[UISearchController alloc] initWithSearchResultsController:searchResultVc];
        searchVc.searchResultsUpdater = self;
        searchVc.delegate = self;
        searchVc.searchBar.delegate = self;
        searchVc.definesPresentationContext = YES;
        searchResultVc.searchBar = searchVc.searchBar;
        _searchVc = searchVc;
        _searchBar = searchVc.searchBar;
    }
    return _searchBar;
}

- (NSArray *)myClasses{
    if (!_myClasses) {
        _myClasses = @[@"3年1班",@"3年2班",@"3年3班",@"3年4班",@"3年5班",@"3年6班",@"3年7班",@"3年8班",@"3年9班",@"3年10班",@"3年11班",@"3年12班",
                       @"4年1班",@"4年2班",@"4年3班",@"4年4班",@"4年5班",@"4年6班",@"4年7班",@"4年8班",@"4年9班",@"4年10班",@"4年11班",@"4年12班",
                       @"5年1班",@"5年2班",@"5年3班",@"5年4班",@"5年5班",@"5年6班",@"5年7班",@"5年8班",@"5年9班",@"5年10班",@"5年11班",@"5年12班"];
    }
    return _myClasses;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择现有的班级";
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.searchBar sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DWDLogFunc;
    // 在这里覆盖数组,  取回最初的数组刷新表格
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        
    }
    cell.imageView.image = [UIImage imageNamed:@"ic_class_contact_press"];
    cell.textLabel.text = self.myClasses[indexPath.row];
    cell.detailTextLabel.text = @"12";
    
    return cell;
}

#pragma mark - <UISearchResultsUpdating>
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    if (!searchController.active) {
        return;
    }
    
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF contains[c] '%@'", searchController.searchBar.text]];
    
    NSArray *results = [self.myClasses filteredArrayUsingPredicate:sPredicate];
    
    // 结果控制器是navVc
    DWDSearchResultController *searchResultVc = (DWDSearchResultController *)searchController.searchResultsController;
    searchResultVc.results = results;
    
    searchResultVc.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDClassConversationViewController class]) bundle:nil];
    DWDClassConversationViewController *conversationVc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassConversationViewController class])];
    [self.navigationController pushViewController:conversationVc animated:YES];
}

#pragma mark - <UISearchControllerDelegate>

#pragma mark - 自定义代理方法 - <DWDSearchResultControllerDelegate>
- (void)resultControllerCellDidSelectWithResults:(NSArray *)results indexPath:(NSIndexPath *)indexPath{
    self.myClasses = results;
    
    [self.tableView reloadData];
    // 取出indexpath这行的模型   Push到班级对话控制器
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

@end
