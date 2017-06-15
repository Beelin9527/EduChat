//
//  DWDSearchClassNumberController.m
//  EduChat
//
//  Created by Superman on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDSearchClassNumberController.h"
#import "DWDSearchResultController.h"
#import "DWDSearchClassInfoViewController.h"
#import "DWDChatController.h"

#import "DWDClassDataBaseTool.h"
#import "DWDClassModel.h"

#import "DWDMyClassInfoCell.h"
#import <YYModel.h>

@interface DWDSearchClassNumberController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,DWDSearchResultControllerDelegate>
@property (nonatomic , weak) UITableView *tableview;
@property (nonatomic , strong) NSMutableArray *myClassList;

@end

@implementation DWDSearchClassNumberController

- (NSMutableArray *)myClassList{
    if (!_myClassList) {
        _myClassList = [NSMutableArray array];
    }
    return _myClassList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"请输入班级号";
//    DWDSearchResultController *resultVc = [[DWDSearchResultController alloc] init];
//    // UISearchController的searchbar初始化有一个过程,设置转场动画和代理,更新者等,需要时间  必须都完成了之后,才创建tableview, tableview的headerview也是有一个创建过程和设置动画过程, 因此必须都创建好之后,才给headerview赋值 , 并且在取消的时候,nav的动画有会闪 , 必须手动让nav出现, 原因不详
//    UISearchController *searchVc = [[UISearchController alloc] initWithSearchResultsController:resultVc];
//    resultVc.searchBar = searchVc.searchBar;
//    resultVc.searchBar.keyboardType = UIKeyboardTypeNumberPad;
//    resultVc.resultVcDelegate = self;
//    _resultVc = resultVc;
//    
//    searchVc.searchResultsUpdater = self;
//    searchVc.searchBar.delegate = self;
//    searchVc.delegate = self;
//    _searchVc = searchVc;
    
    
//    self.tableview.tableHeaderView = searchVc.searchBar;
//    self.definesPresentationContext = YES;
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = DWDColorBackgroud;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview = tableView;
    [self.view addSubview:tableView];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return self.myClassList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, pxToH(88))];
        searchBar.delegate = self;
        searchBar.placeholder = @"请输入班级号";
        
        [cell.contentView addSubview:searchBar];
        return cell;
    }else{
        DWDMyClassInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDMyClassInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.classModel = self.myClassList[indexPath.row];
        return cell;
    }
    
}

NSString *str = @"    班级";

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return pxToH(88);
    }else{
        return pxToH(140);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 1) {
        return 25;
    }else{
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return pxToH(20);
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 && self.myClassList.count > 0) {
        CGSize realSize = [str realSizeWithfont:DWDFontContent];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pxToW(50), pxToH(20), realSize.width, realSize.height)];
        label.font = DWDFontContent;
        label.textColor = DWDRGBColor(100, 100, 100);
        label.text = str;
        return label;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    //解决 点击section 里的searchBar ,之外一点空间。 会进来此方法。需要return，否则会执行下面代码，导致崩溃
    if (indexPath.section == 0) return;
   
    //判断是否已经加入班级,已加入则跳转会话窗口--Add By FZG
    DWDClassModel *classModel = self.myClassList[indexPath.row];
    
    //从本地库拿
    DWDClassModel *classModelDataBase = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:classModel.classId myCustId:[DWDCustInfo shared].custId];
    if ([classModelDataBase.isExist isEqual:@1])
    {
        
        DWDChatController *chatVC = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.toUserId = classModel.classId;
        chatVC.chatType = DWDChatTypeClass;
        chatVC.myClass = classModel;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
    else
    {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        DWDSearchClassInfoViewController *searchInfoVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDSearchClassInfoViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSearchClassInfoViewController class])];
        searchInfoVc.classModel = self.myClassList[indexPath.row];
        [self.navigationController pushViewController:searchInfoVc animated:YES];
    }
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
        }
    }
    
    // 拿到text发请求
    long long myClassId = [searchBar.text longLongValue];
    NSDictionary *params = @{DWDCustId : [DWDCustInfo shared].custId, @"classAcct" : [NSNumber numberWithLongLong:myClassId]};
    [[HttpClient sharedClient] getApi:@"ClassVerifyRestService/getClassInfoByEduAcct" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
     
        DWDClassModel *classInfo = [DWDClassModel yy_modelWithJSON:responseObject[@"data"]];
        // 弹出班级信息控制器
        [self.myClassList removeAllObjects];
        [self.myClassList addObject:classInfo];
        [self.tableview reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"班级不存在!";
        [hud show:YES];
        [hud hide:YES afterDelay:1.0];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    DWDLogFunc;
}

@end
