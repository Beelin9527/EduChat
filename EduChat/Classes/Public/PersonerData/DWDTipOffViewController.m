//
//  DWDTipOffViewController.m
//  EduChat
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTipOffViewController.h"
#import "DWDTipOffCell.h"

@interface DWDTipOffViewController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    UITableView *_tableView;
    NSArray *_titleArray;
    UITextView *_textView;
}
@end

@implementation DWDTipOffViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self setSubviews];
}

- (void)setNav
{
    self.title = @"举报";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commitTopOff)];
}

- (void)setSubviews
{
    _titleArray = @[@"色情低俗",@"广告骚扰",@"政治敏感",@"谣言",@"欺诈骗钱",@"违法（暴力恐怖、违禁品等）",@"售假投诉"];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

#pragma mark - TableViewDataSource && Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _titleArray.count;
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        static NSString *ID = @"tipOffCell";
        DWDTipOffCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDTipOffCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.title = _titleArray[indexPath.row];
        return cell;
        
    }else {
        
        static NSString *ID = @"textViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        _textView =[[UITextView alloc] init];
        _textView.frame = CGRectMake(10.0f, 15.0f, DWDScreenW - 20.0f, 130.0f);
        _textView.delegate = self;
        _textView.font = DWDFontMin;
        _textView.textColor = DWDColorSecondary;
        
        UILabel *placeLbl = [[UILabel alloc] init];
        placeLbl.frame = CGRectMake(0, 0, 100.0f, 12.0f);
        placeLbl.textColor = DWDColorSecondary;
        placeLbl.font = DWDFontMin;
        placeLbl.text = @"输入其他原因";
        placeLbl.tag = 999;
        [_textView addSubview:placeLbl];
        [cell.contentView addSubview:_textView];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0f;
    }else {
        return 160.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.frame = CGRectMake(0, 0, DWDScreenW, 33.0f);
    titleLbl.textColor = DWDColorContent;
    titleLbl.font = DWDFontContent;
    
    if (section == 0) {
        titleLbl.text = @"  请选择举报原因";
    }else {
        titleLbl.text = @"  其他原因";
    }
    return titleLbl;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - TextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UILabel *placeLlb = (UILabel *)[textView viewWithTag:999];
    placeLlb.hidden = YES;
}

- (void)keyboardShow:(NSNotification *)notification
{
    DWDLog(@"%@",notification);
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 74.0f, 0.0);
    _tableView.contentInset = contentInsets;
    
    [_tableView setContentOffset:CGPointMake(0, _tableView.frame.size.height - _tableView.contentSize.height + 64.0f)
     animated:YES];
    
}

- (void)keyboardHide:(NSNotification *)notification
{
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_textView resignFirstResponder];
}

- (void)commitTopOff
{
    DWDLogFunc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
