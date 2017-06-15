//
//  DWDDiscoverViewController.m
//  DWDSj
//
//  Created by apple  on 15/10/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDDiscoverViewController.h"
#import "DWDQRCodeViewController.h"
#import "DWDNearPeopleViewController.h"
@interface DWDDiscoverViewController ()

@end

@implementation DWDDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.w, 10)];
    self.tableView.rowHeight = pxToH(88);
}


#pragma mark - <UITableViewDataSource>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"扫一扫";
        cell.textLabel.textColor = DWDColorBody;
        cell.imageView.image = [UIImage imageNamed:@"ic_sweep_find"];
    }else{
        cell.textLabel.text = @"附近的人";
        cell.textLabel.textColor = DWDColorBody;
        cell.imageView.image = [UIImage imageNamed:@"ic_near_find"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    
}


#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        // 跳转到扫一扫界面
        DWDQRCodeViewController *QRCodeVc = [[DWDQRCodeViewController alloc] init];
        QRCodeVc.hidesBottomBarWhenPushed = YES;
       [self.navigationController pushViewController:QRCodeVc animated:YES];
    }else{
        // 跳转到附近的人
        DWDNearPeopleViewController *nearVc = [[DWDNearPeopleViewController alloc] init];
        nearVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nearVc animated:YES];
    }
    
}

@end
