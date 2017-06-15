//
//  DWDSearchClassNumberController.m
//  EduChat
//
//  Created by Superman on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSearchClassNumberController.h"
#import "DWDSearchResultController.h"
#import "DWDClassInfoModel.h"
#import <YYModel.h>

@interface DWDSearchClassNumberController () <UITableViewDataSource,UITableViewDelegate,UISearchResultsUpdating ,UISearchControllerDelegate, UISearchBarDelegate , DWDSearchResultControllerDelegate>
@property (nonatomic , strong) DWDSearchResultController *resultVc;
@property (nonatomic , strong) NSArray *resultDatas;
@property (nonatomic , strong) UISearchController *searchVc;
@property (nonatomic , weak) UITableView *tableview;

@end

@implementation DWDSearchClassNumberController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请输入班级号";
    DWDSearchResultController *resultVc = [[DWDSearchResultController alloc] init];
    // UISearchController的searchbar初始化有一个过程,设置转场动画和代理,更新者等,需要时间  必须都完成了之后,才创建tableview, tableview的headerview也是有一个创建过程和设置动画过程, 因此必须都创建好之后,才给headerview赋值 , 并且在取消的时候,nav的动画有会闪 , 必须手动让nav出现, 原因不详
    UISearchController *searchVc = [[UISearchController alloc] initWithSearchResultsController:resultVc];
    resultVc.searchBar = searchVc.searchBar;
    resultVc.searchBar.keyboardType = UIKeyboardTypeNumberPad;
    resultVc.resultVcDelegate = self;
    _resultVc = resultVc;
    
    searchVc.searchResultsUpdater = self;
    searchVc.searchBar.delegate = self;
    searchVc.delegate = self;
    _searchVc = searchVc;
    
    
    self.tableview.tableHeaderView = searchVc.searchBar;
    self.definesPresentationContext = YES;
}

- (UITableView *)tableview{
    if (!_tableview) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableview = tableView;
        [self.view addSubview:tableView];
    }
    return _tableview;
}

- (NSArray *)resultDatas{
    if (!_resultDatas) {
        _resultDatas = [NSArray array];
    }
    return _resultDatas;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%zd",indexPath.row];
    return cell;
}

#pragma mark - <DWDSearchResultControllerDelegate>
- (void)resultControllerCellDidSelectWithResults:(NSArray *)results indexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - <UISearchControllerDelegate>
- (void)willPresentSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = !self.tabBarController.tabBar.hidden;
}

#pragma mark - <UISearchResultsUpdating>
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
}

#pragma mark - <UISearchBarDelegate>
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    DWDLogFunc;
    for (NSUInteger i = 0; i < searchBar.text.length; i++) {
        char c = [searchBar.text characterAtIndex:i];
        if (!(c >= '0' && c <= '9')) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = @"请输入合法的班级号!只能是数字!";
            [hud show:YES];
            [hud hide:YES afterDelay:2.0];
//            [self.view endEditing:YES];
            return;
        }else{
            // 拿到text发请求  8010000001059
            long long myClassId = [searchBar.text longLongValue];
            NSDictionary *params = @{@"classId" : [NSNumber numberWithLong:myClassId],
                                     @"custId" : [DWDCustInfo shared].custId};
            [[HttpClient sharedClient] getApi:@"ClassRestService/getClassInfo" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                
                DWDClassInfoModel *classInfo = [DWDClassInfoModel yy_modelWithJSON:responseObject[@"data"]];
                // 弹出班级信息控制器
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DWDLog(@"error:%@",error);
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                hud.labelText = @"班级不存在!";
                [hud show:YES];
                [hud hide:YES afterDelay:1.0];
            }];
        }
    }
    // 获取到数据之后传给resultVc , 让resultVc 刷新表格
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    DWDLogFunc;
}

@end
