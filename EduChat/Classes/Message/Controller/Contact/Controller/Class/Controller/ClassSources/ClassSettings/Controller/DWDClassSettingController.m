//
//  DWDClassSettingController.m
//  EduChat
//
//  Created by Bharal on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSettingController.h"
#import "DWDClassChangeClassNameViewController.h"

#import "DWDRequestClassSetting.h"
#import "DWDGroupInfoModel.h"
#import "DWDClassSettingSectiomItemsModle.h"

#import "DWDGroupInfoCell.h"

@interface DWDClassSettingController ()
@property (strong, nonatomic) NSMutableArray *arrItems;
@property (strong, nonatomic) NSMutableArray *arrGroupCusts;
@property (strong, nonatomic) NSDictionary *dictDataSource;
@end

@implementation DWDClassSettingController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"班级设置";
    
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self.tableView registerClass:[DWDGroupInfoCell class] forCellReuseIdentifier:NSStringFromClass([DWDGroupInfoCell class])];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self requestData];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    //是否更新设置
    DWDGroupInfoModel *isTopModel_Now = _arrItems[1][0];
    DWDLog(@"==== %d",isTopModel_Now.isOpen);
    DWDGroupInfoModel *isCloseModel_Now = _arrItems[1][1];
    DWDGroupInfoModel *isShowNickModel_Now = _arrItems[2][1];
    
   
    
    if (isTopModel_Now.isOpen  != [self.dictDataSource[@"isTop"] boolValue]
        || isCloseModel_Now.isOpen != [self.dictDataSource[@"isClose"] boolValue]
        || isShowNickModel_Now.isOpen != [self.dictDataSource[@"isShowNick"] boolValue] ) {
        
        //上传服务器
        [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:@4010000005410 classId:@8010000001047 isTop:[NSNumber numberWithInt:isTopModel_Now.isOpen] isClose:[NSNumber numberWithInt:isCloseModel_Now.isOpen] isShowNick:[NSNumber numberWithInt:isShowNickModel_Now.isOpen] success:^(id responseObject) {
            
        } failure:^(NSError *error) {
            
        }];

    }
    
    
}
-(NSMutableArray *)arrItems
{
    if (!_arrItems) {
        
        _arrItems = [NSMutableArray array];
        
    }
    DWDClassSettingSectiomItemsModle *item = [[DWDClassSettingSectiomItemsModle alloc]init];
    item.dictDataSource = self.dictDataSource;
    _arrItems = [item.arrSectionItem copy];

    return _arrItems;
}
-(NSMutableArray *)arrGroupCusts
{
    if (!_arrGroupCusts) {
        _arrGroupCusts = [NSMutableArray array];
        
    }
    return _arrGroupCusts;
}

    

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    DWDLog(@"---- %ld",self.arrItems.count);
    return self.arrItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray * arrRow = self.arrItems[section];
    return arrRow.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDGroupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDGroupInfoCell class])];
    
    DWDGroupInfoModel *model = _arrItems[indexPath.section][indexPath.row];
    cell.groupInfoModel = model;
    
    return cell;
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DWDPadding;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - scrollView delegate
//delete UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 10;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}

#pragma mark - request
- (void)requestData
{
    
    __weak typeof(self) weakSelf = self;
    [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:@4010000005410 classId:@8010000001047 success:^(id responseObject) {
        
        weakSelf.dictDataSource = responseObject;
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
