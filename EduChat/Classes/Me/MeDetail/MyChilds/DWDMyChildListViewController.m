//
//  DWDMyChildsListViewController.m
//  EduChat
//
//  Created by Gatlin on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyChildListViewController.h"
#import "DWDMyChildInfoViewController.h"
#import "DWDSearchClassNumberController.h"

#import "DWDMyChildsListCell.h"

#import "DWDMyChildListEntity.h"
#import "DWDMyChildClient.h"

#import <YYModel/YYModel.h>
#import <Masonry.h>
@interface DWDMyChildListViewController ()
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIView *notingView;
@end

@implementation DWDMyChildListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的孩子";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDMyChildsListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DWDMyChildsListCell class])];
    self.tableView.rowHeight = 80;
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    //request
    [self requestDataWithCustId:[DWDCustInfo shared].custId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Getter
- (NSMutableArray *)datasource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSource;
}

- (UIView *)notingView
{
    if (!_notingView) {
        _notingView  = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"您还没有加入班级";
        lab.font = DWDFontBody;
        lab.textColor = DWDColorContent;
        [_notingView addSubview:lab];
        
        [lab makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(lab.superview.centerX);
            make.top.equalTo(lab.superview.centerY).offset(-80);
        }];
        UIButton *joinClass = [UIButton buttonWithType:UIButtonTypeCustom];
        joinClass.backgroundColor = DWDColorMain;
        [joinClass setTitle:@"申请加入班级" forState:UIControlStateNormal];
        joinClass.layer.masksToBounds = YES;
        joinClass.layer.cornerRadius = 20;
        [joinClass addTarget:self action:@selector(addClassAction) forControlEvents:UIControlEventTouchUpInside];
        [_notingView addSubview:joinClass];
        
        [joinClass makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(joinClass.superview.centerX).offset(-80);
            make.centerY.equalTo(joinClass.superview.centerY).offset(-30);
            make.width.equalTo(@160);
            make.height.equalTo(@40);
        }];

}
    
    return _notingView;
}

#pragma mark - Button Action
- (void)addClassAction
{
    DWDSearchClassNumberController *vc = [[DWDSearchClassNumberController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count == 0) {
        [self.tableView addSubview:self.notingView];
    }else{
        [self.notingView removeFromSuperview];
        self.notingView = nil;
        
    }
     return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   DWDMyChildsListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDMyChildsListCell class])];
    
    DWDMyChildListEntity *entity = self.dataSource[indexPath.row];
    cell.entity = entity;
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDMyChildListEntity *entity = self.dataSource[indexPath.row];

    DWDMyChildInfoViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDMyChildInfoViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDMyChildInfoViewController class])];
    vc.childCustId = entity.childCustId;
    vc.myChildListEntity = entity;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Request
- (void)requestDataWithCustId:(NSNumber *)custId
{
     DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    __weak typeof(self) weakSelf = self;
    [[DWDMyChildClient sharedMyChildClient] requestGetMyChildrenListWithCustId:custId
                                                                       success:^(id responseObject) {
                                                                           
                                                                           [hud hideHud];
                                                                           __strong typeof(self) strongSelf = weakSelf;
                                                                           
                                                                           for (NSDictionary *dict in responseObject) {
                                                                               
                                                                               DWDMyChildListEntity *entity = [DWDMyChildListEntity yy_modelWithDictionary:dict];
                                                                               [strongSelf.datasource addObject:entity];
                                                                           }
                                                                           [strongSelf.tableView reloadData];
                                                                       }
                                                                       failure:^(NSError *error) {
                                                                           [hud showText:@"加载失败"];
                                                                       }];
}
@end
