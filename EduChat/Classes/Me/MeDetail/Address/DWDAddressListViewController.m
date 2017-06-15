//
//  DWDAddressListViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddressListViewController.h"
#import "DWDAddressEditViewController.h"

#import "DWDAddressListCell.h"

#import "DWDRequestLocation.h"
#import "DWDLocationEntity.h"


@interface DWDAddressListViewController ()

@property (strong, nonatomic) NSArray *arrDataSour;
@end

@implementation DWDAddressListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDAddressListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DWDAddressListCell class])];
    
    [self setupTableViewFootView];
    
    //requeset data
    [self requestData];
}

// setup tableView footView
- (void)setupTableViewFootView
{
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DWDScreenW, 100)];
    footView.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn  setBackgroundColor:DWDColorMain];
    [btn setTitle:@"十 新增地址" forState:UIControlStateNormal];
    btn.frame = CGRectMake(50, 50, DWDScreenW-100, 40);
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 20;
    [btn addTarget:self action:@selector(addNewAddressAction) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btn];
    
    self.tableView.tableFooterView = footView;

}


#pragma mark  - action
//add new address
- (void)addNewAddressAction
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDAddressEditViewController class]) bundle:nil];
    DWDAddressEditViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDAddressEditViewController class])];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.arrDataSour.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDAddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDAddressListCell class]) forIndexPath:indexPath];
    
    DWDLocationEntity *entity = self.arrDataSour[indexPath.row];
    cell.entity = entity;
    
    return cell;
}

#pragma mark - tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // push edit address viewController
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDAddressEditViewController class]) bundle:nil];
    DWDAddressEditViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDAddressEditViewController class])];
    
    DWDLocationEntity *entity = self.arrDataSour[indexPath.row];
    vc.entity = entity;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark - request
- (void)requestData
{
    __weak DWDAddressListViewController *weakSelf = self;
    [[DWDRequestLocation sharedDWDRequestServerLocation] requestServerLocationgetListCustId:[DWDCustInfo shared].custId success:^(NSArray *result) {
        
        weakSelf.arrDataSour = result;
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}
@end
