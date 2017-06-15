//
//  DWDCurrentDistrictViewController.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//


#import "DWDCurrentDistrictViewController.h"
#import "DWDAddNewClassCityViewController.h"

#import "DWDAddNewClassDistrictCell.h"
#import "DWDProvinceCell.h"

#import "DWDDistrictModel.h"
#import "DWDCityModel.h"

#import "HttpClient.h"
#import <MBProgressHUD.h>
#import <YYModel.h>
@interface DWDCurrentDistrictViewController () 
@property (nonatomic , strong) NSMutableArray *districts;
@property (nonatomic , strong) NSMutableArray *cityArray;
@property (nonatomic , weak) MBProgressHUD *hud;
@end

@implementation DWDCurrentDistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地区";
    NSDictionary *params = @{@"districtCode" : @"000000",
                             @"subdistrict" : @1,
                             };
    
    [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arr = responseObject[DWDApiDataKey][@"districtList"];
        for (int i = 0; i < arr.count; i++) {
            DWDDistrictModel *province = [DWDDistrictModel yy_modelWithJSON:arr[i]];
            [self.districts addObject:province];
        }
        
        [self.tableView reloadData];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        _hud = hud;
        hud.labelText = @"获取省份地区成功!";
        hud.animationType = MBProgressHUDAnimationZoomOut;
        [hud show:YES];
        [hud hide:YES afterDelay:1.0];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"%@",error);
    }];
}

- (NSMutableArray *)cityArray{
    if (!_cityArray) {
        _cityArray = [NSMutableArray array];
    }
    return _cityArray;
}
- (NSArray *)districts{
    if (!_districts) {
        _districts = [NSMutableArray array];
    }
    return _districts;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return self.districts.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        DWDAddNewClassDistrictCell *cell = [[DWDAddNewClassDistrictCell alloc] init];
        cell.currentLocation = self.currentLocationName;
        return cell;
    }else{
        static NSString *ID = @"cell";
        DWDProvinceCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDProvinceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        DWDDistrictModel *province = self.districts[indexPath.row];
        cell.textLabel.text = province.name;
        return cell;
    }
}

#pragma mark - <UITableViewDelegate>
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"全部";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return pxToH(20);
    }else{
        return pxToH(66);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"正在获取城市,请骚候";
    DWDDistrictModel *province = self.districts[indexPath.row];
    NSDictionary *params = @{@"districtCode" : province.regionCode,
                             @"subdistrict" : @1,
                             };
    [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arr = responseObject[DWDApiDataKey][@"districtList"];
        for (int i = 0; i < arr.count; i ++) {
            DWDCityModel *citymodel = [DWDCityModel yy_modelWithJSON:arr[i]];
            [self.cityArray addObject:citymodel];
        }
        hud.labelText = @"获取成功!";
        // 跳转
        DWDAddNewClassCityViewController *cityVc = [[DWDAddNewClassCityViewController alloc] init];
        cityVc.provinceName = province.name;
        cityVc.cityArray = self.cityArray;
        cityVc.addNewVc = _addNewVc;
        
        //this is meDetail change area
        if (self.type == DWDSelfClassPropertyTypeSelectCityForChangeMeArea) {
            cityVc.type = DWDSelfClassPropertyTypeSelectCityForChangeMeArea;
        }
        
        [self.navigationController pushViewController:cityVc animated:YES];
        
        [hud hide:YES afterDelay:1.0];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"%@",error);
        hud.labelText = @"获取失败!";
        [hud hide:YES afterDelay:1.0];
    }];
}


@end
