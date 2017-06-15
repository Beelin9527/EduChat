//
//  DWDMyClassListViewController.m
//  EduChat
//
//  Created by Gatlin on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyClassListViewController.h"
#import "DWDAddNewClassViewController.h"
#import "DWDSearchClassNumberController.h"

#import "DWDCustInfoClient.h"

#import <Masonry.h>
@interface DWDMyClassListViewController ()

@property (strong, nonatomic) NSArray *arrDataSource;
@property (strong, nonatomic) UIView *notingView;
@end

@implementation DWDMyClassListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"学校/班级";
    self.tableView.backgroundColor = DWDColorBackgroud;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self requestData];
    
  
}

#pragma mark - Getter
- (UIView *)notingView
{
    if (!_notingView) {
        _notingView  = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UILabel *lab = [[UILabel alloc]init];
        lab.text = @"您还没有创建/加入班级";
        lab.font = DWDFontBody;
        lab.textColor = DWDColorContent;
        [_notingView addSubview:lab];
        
        [lab makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(lab.superview.centerX);
            make.top.equalTo(lab.superview.centerY).offset(-80);
        }];
        
        UIButton *newAddClass = [UIButton buttonWithType:UIButtonTypeCustom];
        newAddClass.backgroundColor = DWDColorMain;
        [newAddClass setTitle:@"新建班级" forState:UIControlStateNormal];
        newAddClass.layer.masksToBounds = YES;
        newAddClass.layer.cornerRadius = 20;
        [newAddClass addTarget:self action:@selector(createClassAction) forControlEvents:UIControlEventTouchUpInside];
        [_notingView addSubview:newAddClass];
        
        [newAddClass makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(newAddClass.superview.centerX).offset(-20);
            make.centerY.equalTo(newAddClass.superview.centerY).offset(-30);
            make.width.equalTo(@120);
            make.height.equalTo(@40);
        }];
        
        UIButton *joinClass = [UIButton buttonWithType:UIButtonTypeCustom];
        joinClass.backgroundColor = DWDColorMain;
        [joinClass setTitle:@"加入班级" forState:UIControlStateNormal];
        joinClass.layer.masksToBounds = YES;
        joinClass.layer.cornerRadius = 20;
        [joinClass addTarget:self action:@selector(addClassAction) forControlEvents:UIControlEventTouchUpInside];
        [_notingView addSubview:joinClass];
        
        [joinClass makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(joinClass.superview.centerX).offset(20);
            make.centerY.equalTo(joinClass.superview.centerY).offset(-30);
            make.width.equalTo(@120);
            make.height.equalTo(@40);
        }];

        
        //区分权限
        if (![DWDCustInfo shared].isTeacher) {
            newAddClass.hidden = YES;
            [joinClass makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(joinClass.superview.centerX).offset(-60);
                make.centerY.equalTo(joinClass.superview.centerY).offset(-30);
                make.width.equalTo(@120);
                make.height.equalTo(@40);
            }];
        }
    }
    
    return _notingView;
}


#pragma mark - Button Action
- (void)createClassAction
{
    DWDAddNewClassViewController *vc = [[DWDAddNewClassViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addClassAction
{
    DWDSearchClassNumberController *vc = [[DWDSearchClassNumberController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.arrDataSource.count == 0) {
        self.tableView.scrollEnabled = NO;
        [self.view addSubview:self.notingView];
    }else{
        self.tableView.scrollEnabled = YES;
        [self.notingView removeFromSuperview];
    }
    return self.arrDataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dictItem = self.arrDataSource[indexPath.row];
    cell.textLabel.text = dictItem[@"schoolName"];
    cell.detailTextLabel.text = dictItem[@"className"];
    
    return cell;
}



#pragma mark request
- (void)requestData
{
    __weak typeof(self) weakSelf = self;
    [[DWDCustInfoClient sharedCustInfoClient] requestClassGetListCustId:[DWDCustInfo shared].custId success:^(id responseObject) {
        
        weakSelf.arrDataSource = responseObject;
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
