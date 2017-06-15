//
//  DWDSearchMsgRecordViewController.m
//  EduChat
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSearchMsgRecordViewController.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDMsgRecordCell.h"

@interface DWDSearchMsgRecordViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITextField *_searchBar;
    UITableView *_tableView;
    
    NSMutableArray *_resultArray;
}
@end

@implementation DWDSearchMsgRecordViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self setNav];
    
    [self setSubviews];
}

#pragma mark - 设置导航
- (void)setNav
{
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDTopHight)];
    navBar.backgroundColor = DWDRGBColor(244, 245, 246);
    navBar.alpha = 0.8;
    [self.view addSubview:navBar];
    
    //搜索栏
    UITextField *searchBar = [[UITextField alloc] init];
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.frame = CGRectMake(10, 25, DWDScreenW - 65, 30);
    searchBar.layer.cornerRadius = 15;
    searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    searchBar.layer.borderWidth = 0.5;
    searchBar.layer.masksToBounds = YES;
    searchBar.returnKeyType = UIReturnKeySearch;
    searchBar.placeholder = @"搜索";
    searchBar.font = DWDFontContent;
    searchBar.delegate = self;
    UIImageView *leftIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_search_normal"]];
    leftIcon.frame = CGRectMake(0, 0, 35, 22);
    leftIcon.contentMode = UIViewContentModeScaleAspectFit;
    searchBar.leftView = leftIcon;
    searchBar.leftViewMode = UITextFieldViewModeAlways;
    [searchBar becomeFirstResponder];
    [navBar addSubview:searchBar];
    _searchBar = searchBar;
    
    //取消按钮
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(DWDScreenW - 55, searchBar.y, 50, searchBar.h);
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleColor:DWDColorBody forState:UIControlStateNormal];
    [rightBtn setTitleColor:DWDColorSecondary forState:UIControlStateHighlighted];
    rightBtn.titleLabel.font = DWDFontContent;
    [rightBtn addTarget:self action:@selector(rightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:rightBtn]; 
    
    //底部分割线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, navBar.h - 1., DWDScreenW, 1.)];
    bottomLine.backgroundColor = DWDColorSeparator;
    [navBar addSubview:bottomLine];
}

- (void)setSubviews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, DWDTopHight, DWDScreenW, DWDScreenH - DWDTopHight) style:UITableViewStylePlain];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

- (void)rightBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchMsgRecord];
    return YES;
}


#pragma mark - 搜索
- (void)searchMsgRecord
{
    
}

#pragma mark - TableView Delegate && DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return _resultArray.count;
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    DWDMsgRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDMsgRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
}

@end
