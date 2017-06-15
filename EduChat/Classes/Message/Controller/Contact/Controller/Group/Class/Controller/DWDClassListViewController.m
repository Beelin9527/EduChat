//
//  DWDClassListViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassListViewController.h"
#import "DWDAddNewClassViewController.h"
#import "DWDSearchClassNumberController.h"
#import "DWDQRCodeViewController.h"
#import "DWDMessageViewController.h"
#import "DWDClassInfoViewController.h"

#import "DWDChatController.h"

#import "DWDContactCell.h"

#import "DWDClassModel.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDClassDataBaseTool.h"

#import "KxMenu.h"
#import <Masonry/Masonry.h>
#import <YYModel.h>
@interface DWDClassListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@end

@implementation DWDClassListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"班级";

    self.searchController.searchBar.placeholder = @"搜索班级";
    
    //判断当前控制器是否为导航栏第一个控制器。若是要搜索取消时要显示Tabbar,否则隐藏
    if ([self isEqual:[self.navigationController.viewControllers objectAtIndex:0]]) {
         self.isShowTabbarWhenDismiss = YES;
    }else{
        self.isShowTabbarWhenDismiss = NO;
    }
    
    //数据为空，显示小免图片
    self.stateView = [self setupStateViewWithImageName:@"img_class_empty" describe:@"你还没有加入班级呦~"];
    self.stateView.y += 40; 
     _dataSource = [[[DWDClassDataBaseTool sharedClassDataBase] getClassList:[DWDCustInfo shared].custId] copy];
    
    //监听
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadClassListAction) name:kDWDNotificationClassListReload object:nil];
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnPopAdd"] style:UIBarButtonItemStyleDone target:self action:@selector(showMoreItem:Event:)];
    
    _dataSource = [[[DWDClassDataBaseTool sharedClassDataBase] getClassList:[DWDCustInfo shared].custId] copy];
    [self.tableView reloadData];
}
#pragma mark Setup
- (void)setupTableView
{
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[DWDContactCell class] forCellReuseIdentifier:NSStringFromClass([DWDContactCell class])];
    //搜索UITableViewController 注册Cell
    [self.searchTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDContactCell class]) bundle:nil ] forCellReuseIdentifier:NSStringFromClass([DWDContactCell class])];
    
   
}

#pragma mark - Button Action
- (void)showMoreItem:(UIBarButtonItem *)sender Event:(UIEvent *) event {
    
    NSArray *menuItems = [[NSArray alloc] init];
    KxMenuItem *addClassItem = [KxMenuItem menuItem:NSLocalizedString(@"AddClass", nil) image:[UIImage imageNamed:@"Msg_Con_NC_NOR"] target:self action:@selector(addClass)];
    KxMenuItem *joinClassItem = [KxMenuItem menuItem:NSLocalizedString(@"JoinClass", nil) image:[UIImage imageNamed:@"Msg_Con_JC_NOR"] target:self action:@selector(searchClass)];
    KxMenuItem *scanItem = [KxMenuItem menuItem:NSLocalizedString(@"Scan", nil) image:[UIImage imageNamed:@"Msg_Con_SP_NOR"] target:self action:@selector(scan)];
    
    //区分权限
    if ([DWDCustInfo shared].isTeacher) {
        menuItems = @[addClassItem,joinClassItem,scanItem];
    }
    else{
        menuItems = @[joinClassItem,scanItem];

    }
    
    CGRect fromRect = [[event.allTouches anyObject] view].frame;
    
    fromRect.origin.y += 20;
    [KxMenu setTitleFont:DWDFontContent];
    [KxMenu showMenuInView:self.view.window
                  fromRect:fromRect
                 menuItems:menuItems];
    
}

- (void)addClass
{
    DWDAddNewClassViewController *addNewClassVc = [[DWDAddNewClassViewController alloc] init];
    addNewClassVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addNewClassVc animated:YES];
    
}
- (void)searchClass
{
    DWDSearchClassNumberController *searchNumVc = [[DWDSearchClassNumberController alloc] init];
    searchNumVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchNumVc animated:YES];
}
-(void)scan {
    DWDQRCodeViewController *vc = [[DWDQRCodeViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
//    DWDNavViewController *navVc = [[DWDNavViewController alloc] initWithRootViewController:vc];
//    [self presentViewController:navVc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Notification
//- (void)reloadClassListAction
//{
//    _dataSource = [[[DWDClassDataBaseTool sharedClassDataBase] getClassList:[DWDCustInfo shared].custId] copy];
//    [self.tableView reloadData];
//}
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
    
    DWDClassModel *classEntity;
    if (self.tableView == tableView) {
        classEntity =  self.dataSource[indexPath.row];
    }else{
        classEntity = self.arrSearchResult[indexPath.row];
    }
    
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:classEntity.photoKey] placeholderImage:DWDDefault_GradeImage];
    cell.indexPath = indexPath;
    
    cell.nicknameLable.text = classEntity.className;
    cell.status = DWDContactCellStatusDefault;
    
    if ([DWDCustInfo shared].isTeacher) {
        cell.desLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MemberCount", nil), classEntity.memberNum];
    }else{
        cell.desLabel.text = nil;
    }
//    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:dictDataSource[@"photoKey"]] placeholderImage:DWDDefault_GradeImage];
//    cell.indexPath = indexPath;
//    
//    cell.nicknameLable.text = dictDataSource[@"gradeName"];
//    cell.status = DWDContactCellStatusDefault;
//    cell.desLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MemberCount", nil), dictDataSource[@"memberCount"]];
    
    
    return cell;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDClassModel *classEntity;
    if (self.tableView == tableView) {
        classEntity =  self.dataSource[indexPath.row];
    }else{
        classEntity = self.arrSearchResult[indexPath.row];
    }

    if ([self isEqual:[self.navigationController.viewControllers objectAtIndex:0]]) {
        DWDClassInfoViewController *vc = [[DWDClassInfoViewController alloc] init];
        vc.typeShow = DWDClassTypeShowComeInChat;
        vc.myClass = classEntity;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
        DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        vc.chatType = DWDChatTypeClass;
        vc.myClass = classEntity;
        vc.toUserId = classEntity.classId;
        
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
   
}


#pragma mark - SearchController Delegate
// Called when the search bar becomes first responder
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    // Set searchString equal to what's typed into the searchbar
    NSString *searchString = self.searchController.searchBar.text;
    
    [self updateFilteredContentForAirlineName:searchString];
    [self.searchTableView reloadData];
    
}

- (void)updateFilteredContentForAirlineName:(NSString *)airlineName
{
    if (airlineName == nil) {
        
        // If empty the search results are the same as the original data
        self.arrSearchResult = [self.dataSource mutableCopy];
    } else {
        
        NSMutableArray *searchResults = [[NSMutableArray alloc] init];
        
        // Else if the airline's name is
        
        for (DWDClassModel *airline in self.dataSource) {
            if ([airline.className containsString:airlineName]) {
                
                [searchResults addObject:airline];
                
            }
            self.arrSearchResult = searchResults;
        }
        
        
    }
}


@end
