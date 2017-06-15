//
//  DWDMeAlbumViewController.m
//  EduChat
//
//  Created by Superman on 15/11/16.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMeAlbumViewController.h"

@interface DWDMeAlbumViewController ()

@end

@implementation DWDMeAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpRightBarItem];
    
}

- (void)setUpRightBarItem{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
}

- (void)rightBarBtnClick{
    // 添加蒙版自定义view
    DWDLogFunc;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return @"哈哈哈哈我是相册";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.001;
    }
    return 40;
}
@end
