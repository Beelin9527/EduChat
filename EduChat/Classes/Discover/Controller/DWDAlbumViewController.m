//
//  DWDAlbumViewController.m
//  EduChat
//
//  Created by Superman on 15/11/13.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAlbumViewController.h"

@interface DWDAlbumViewController ()

@end

@implementation DWDAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户相册";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%zd" , indexPath.row];
    
    return cell;
}

@end
