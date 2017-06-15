//
//  DWDGroupListViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGroupListViewController.h"
#import "DWDGroupAddViewController.h"
#import "DWDChatController.h"

#import "DWDContactCell.h"

#import "DWDContactsDatabaseTool.h"

#import "DWDGroupDataBaseTool.h"

@interface DWDGroupListViewController ()
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) DWDContactsDatabaseTool *client;
@end

@implementation DWDGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"群组";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"AddGroup", nil)style:UIBarButtonItemStylePlain target:self action:@selector(pushAddGroupVC)];
    
    self.searchController.searchBar.placeholder = @"搜索群组";
   
    _dataSource = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupList:[DWDCustInfo shared].custId];

    //数据为空，显示小免崽子图片
    self.stateView = [self setupStateViewWithImageName:@"img_group_empty" describe:@"暂无群组\n快去创建加入一起交流吧~"];
    self.stateView.y += 40;
    //监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroupListAction) name:DWDNotificationGroupListReload object:nil];
    
    [self setupTableView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark Setup
- (void)setupTableView
{
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[DWDContactCell class] forCellReuseIdentifier:NSStringFromClass([DWDContactCell class])];
    //搜索UITableViewController 注册Cell
    [((UITableViewController *)self.searchController.searchResultsController).tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDContactCell class]) bundle:nil ] forCellReuseIdentifier:NSStringFromClass([DWDContactCell class])];

    
}

#pragma mark - Getter
- (DWDContactsDatabaseTool *)client
{
    if (!_client) {
        _client = [[DWDContactsDatabaseTool alloc] init];
    }
    return _client;
}


#pragma mark - Button Action
- (void)pushAddGroupVC
{
    DWDGroupAddViewController *vc = [[DWDGroupAddViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)reloadGroupListAction
{
     _dataSource = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupList:[DWDCustInfo shared].custId];
    [self.tableView reloadData];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableView == tableView){
        //如果无联系人，显示无数据默认页
        if (self.dataSource.count == 0) {
            [self.view addSubview:self.stateView];
        }
        else{
            if ([self.view.subviews containsObject:self.stateView]) {
                [self.stateView removeFromSuperview];
            }
        }
        return 1;
    }
    else{
        if (self.arrSearchResult.count == 0) {
            [self.searchTableView addSubview:self.notDataResultLab];
        }
        else{
            if ([self.searchTableView.subviews containsObject:self.notDataResultLab]) {
                [self.notDataResultLab removeFromSuperview];
            }
        }
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView) {
         return self.dataSource.count;
    }
    else{
        return self.arrSearchResult.count;
    }
    
    
}

//返回单元格内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    DWDContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactCell class])];
    
    DWDGroupEntity *entity;
    if (self.tableView == tableView) {
        entity =  self.dataSource[indexPath.row];
    }else{
        entity = self.arrSearchResult[indexPath.row];
    }
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:entity.photoKey] placeholderImage:DWDDefault_GroupImage];
    cell.indexPath = indexPath;
    cell.nicknameLable.text = entity.groupName;
    cell.status = DWDContactCellStatusDefault;
    cell.desLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MemberCount", nil), entity.memberCount];
    
    return cell;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDGroupEntity *entity;
    if (self.tableView == tableView) {
        entity =  self.dataSource[indexPath.row];
    }else{
        entity = self.arrSearchResult[indexPath.row];
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
    DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    vc.chatType = DWDChatTypeGroup;
    vc.title = entity.groupName;
    vc.toUserId = entity.groupId;
    vc.groupEntity = entity;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - SearchController Delegate
// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // Set searchString equal to what's typed into the searchbar
    NSString *searchString = self.searchController.searchBar.text;
    
    [self updateFilteredContentForAirlineName:searchString];
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
    
}

- (void)updateFilteredContentForAirlineName:(NSString *)airlineName
{
    if (airlineName == nil) {
        
        // If empty the search results are the same as the original data
        self.arrSearchResult = [self.dataSource mutableCopy];
    } else {
        
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        // Else if the airline's name is
        
        for (DWDGroupEntity *entity in self.dataSource) {
            if ([entity.groupName containsString:airlineName]) {
                
                [searchResults addObject:entity];
               
            }
             self.arrSearchResult = searchResults;
        }
        
        
    }
}



@end
