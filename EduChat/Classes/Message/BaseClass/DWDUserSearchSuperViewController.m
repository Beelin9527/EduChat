//
//  DWDUserSearchSuperViewController.m
//  EduChat
//
//  Created by apple on 11/6/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDUserSearchSuperViewController.h"
#import "DWDSearchClassNumberController.h"
#import "DWDQRCodeViewController.h"
#import "DWDFindNewFriendsViewController.h"
#import "DWDGroupAddViewController.h"
#import "DWDAddNewClassViewController.h"


#import "KxMenu.h"
#import "UIImage+Utils.h"

@interface DWDUserSearchSuperViewController () <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

@end

@implementation DWDUserSearchSuperViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self CreateSearchController];
}

#pragma mark - Getter
- (UILabel *)notDataResultLab
{
    if (!_notDataResultLab) {
        _notDataResultLab = [[UILabel alloc] init];
        _notDataResultLab.frame = CGRectMake(DWDScreenW/2-50, 80, 100, 21);
        _notDataResultLab.textAlignment = NSTextAlignmentCenter;
        _notDataResultLab.text = @"无结果";
        
    }
    return _notDataResultLab;
}
- (NSMutableArray *)arrSearchResult
{
    if (!_arrSearchResult) {
        _arrSearchResult = [NSMutableArray array];
    }
    return _arrSearchResult;
}

#pragma mark - Init methods
- (void)CreateSearchController {
    
   [[UISearchBar appearance] setTintColor:DWDColorMain];
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_searchbox"]];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbox"] forState:UIControlStateNormal];
    
    UITableViewController *searchResultVC = [[UITableViewController alloc] init];
    _searchTableView = searchResultVC.tableView;
    searchResultVC.tableView.delegate = self;
    searchResultVC.tableView.dataSource = self;
    searchResultVC.tableView.rowHeight = 60;
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultVC];
    
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = NSLocalizedString(@"SearchHolder", nil);
    //very important
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
}

- (UIBarButtonItem *)buildPublicNavBarItem {
    UIBarButtonItem *addContactItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnPopAdd"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(addContact:event:)];
    return addContactItem;
}



#pragma mark - uisearchcontroller delegate methods
- (void)willPresentSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = YES;
}
//- (void)didPresentSearchController:(UISearchController *)searchController;
- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = !self.isShowTabbarWhenDismiss;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
//- (void)didDismissSearchController:(UISearchController *)searchController;


#pragma mark - Button Action 
- (void)addContact:(UIBarButtonItem *)sender event:(UIEvent *) event {
    
    //控件老师、家长的区别 家长无创建班级
    NSArray *menuItems = [[NSArray alloc] init];
    KxMenuItem *addFriendItem = [KxMenuItem menuItem:NSLocalizedString(@"AddFriend", nil) image:[UIImage imageNamed:@"Msg_Con_AF_NOR"] target:self action:@selector(addFriend)];
    KxMenuItem *addGroupItem = [KxMenuItem menuItem:NSLocalizedString(@"AddGroup", nil) image:[UIImage imageNamed:@"Msg_Con_AG_NOR"] target:self action:@selector(addGroup)];
    KxMenuItem *addClassItem = [KxMenuItem menuItem:NSLocalizedString(@"AddClass", nil) image:[UIImage imageNamed:@"Msg_Con_NC_NOR"] target:self action:@selector(addClass)];
    KxMenuItem *joinClassItem = [KxMenuItem menuItem:NSLocalizedString(@"JoinClass", nil) image:[UIImage imageNamed:@"Msg_Con_JC_NOR"] target:self action:@selector(searchClass)];
    KxMenuItem *scanItem = [KxMenuItem menuItem:NSLocalizedString(@"Scan", nil) image:[UIImage imageNamed:@"Msg_Con_SP_NOR"] target:self action:@selector(scan)];
    
    if ([DWDCustInfo shared].isTeacher) {
        menuItems = @[addFriendItem,addGroupItem,addClassItem,joinClassItem,scanItem];
    }else{
         menuItems = @[addFriendItem,addGroupItem,joinClassItem,scanItem];
    }
    
    CGRect fromRect = [[event.allTouches anyObject] view].frame;
    
    fromRect.origin.y += 20;
    [KxMenu setTitleFont:DWDFontContent];
    [KxMenu showMenuInView:self.view.window
                  fromRect:fromRect
                 menuItems:menuItems];
    
}

-(void) addFriend {
    DWDFindNewFriendsViewController *vc = [[DWDFindNewFriendsViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) addGroup {
    DWDGroupAddViewController *vc = [[DWDGroupAddViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) addClass {
    DWDAddNewClassViewController *addNewClassVc = [[DWDAddNewClassViewController alloc] init];
    addNewClassVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addNewClassVc animated:YES];
}

- (void) searchClass{
    DWDSearchClassNumberController *searchNumVc = [[DWDSearchClassNumberController alloc] init];
    searchNumVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchNumVc animated:YES];
}

-(void) scan {
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeCamera withController:self authorized:^{
        DWDQRCodeViewController *vc = [[DWDQRCodeViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
}

@end
