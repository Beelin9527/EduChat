//
//  DWDClassSourceCheckScoreViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSourceCheckScoreViewController.h"
#import "DWDSearchResultController.h"
#import "DWDClassCheckScoreDetailViewController.h"
@interface DWDClassSourceCheckScoreViewController() <UISearchResultsUpdating , UISearchControllerDelegate , UISearchBarDelegate , DWDSearchResultControllerDelegate>
@property (nonatomic , weak) UISearchBar *searchBar;
@property (nonatomic , strong) UISearchController *searchVc;
@property (nonatomic , strong) NSArray *myUser;
@property (nonatomic , strong) NSArray *allMyUser;

@end

@implementation DWDClassSourceCheckScoreViewController

- (void)loadView{
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"选择用户";
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.searchBar sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    DWDLogFunc;
    // 在这里覆盖数组,  取回最初的数组刷新表格
}

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

- (NSArray *)myUser{
    if (!_myUser) {
        _myUser = @[@{@"A" : @[@"用户名称1",@"用户名称2",@"用户名称3"]},
  @{@"B" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]},
  @{@"C" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]}
                    ,@{@"D" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]},
                    @{@"E" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]},
                    @{@"F" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]},
                    @{@"G" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]},
                    @{@"H" : @[@"用户名称1",@"用户名称2",@"用户名称3",@"用户名称4",@"用户名称5",@"用户名称6",@"用户名称7",@"用户名称8"]}];
    }
    return _myUser;
}
- (NSArray *)allMyUser{
    if (!_allMyUser) {
        NSMutableArray *muArr = [NSMutableArray array];
        for (int i = 0; i < _myUser.count; i ++) {
            NSDictionary *dict = _myUser[i];
            NSArray *arr = [[dict allValues] firstObject];
            [muArr addObject:arr];
        }
        _allMyUser = muArr;
    }
    return _allMyUser;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.myUser.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = self.myUser[section];
    NSArray *arr = [[dict allValues] firstObject];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    
    NSDictionary *dict = self.myUser[indexPath.section];
    NSArray *arr = [[dict allValues] firstObject];
    cell.textLabel.text = arr[indexPath.row];
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *dict = self.myUser[section];
    return [[dict allKeys] firstObject];
}
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
//    
//}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DWDLogFunc;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DWDClassCheckScoreDetailViewController" bundle:nil];
    DWDClassCheckScoreDetailViewController *scoreDetailVc = [sb instantiateViewControllerWithIdentifier:@"DWDClassCheckScoreDetailViewController"];
    [self.navigationController pushViewController:scoreDetailVc animated:YES];
}

#pragma mark - <DWDSearchResultControllerDelegate>
- (void)resultControllerCellDidSelectWithResults:(NSArray *)results indexPath:(NSIndexPath *)indexPath{
    DWDLogFunc;
    self.myUser = results;
    
    [self.tableView reloadData];
    // 取出indexpath这行的模型   Push到班级对话控制器
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - <UISearchResultsUpdating>
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    if (!searchController.active) {
        return;
    }
    
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF contains[c] '%@'", searchController.searchBar.text]];
    
    NSMutableArray *mutaArr = [NSMutableArray array];
    for (NSArray *arr in self.allMyUser) {
        NSArray *results = [arr filteredArrayUsingPredicate:sPredicate];
        [mutaArr addObjectsFromArray:results];
    }
    
    
    // 结果控制器是navVc
    DWDSearchResultController *searchResultVc = (DWDSearchResultController *)searchController.searchResultsController;
    searchResultVc.results = mutaArr;
    
    searchResultVc.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
}

@end
