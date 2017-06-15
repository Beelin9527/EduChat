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
#import "DWDClassDataHandler.h"
#import "HttpClient.h"

#import "OOLocationManager.h"
#import "DWDCustInfoClient.h"

#import <MBProgressHUD.h>
#import <YYModel.h>

@interface DWDCurrentDistrictViewController () 
@property (nonatomic , strong) NSMutableArray *districts;
@property (nonatomic , strong) NSMutableArray *cityArray;
@property (nonatomic , weak) MBProgressHUD *hud;
@property (nonatomic, strong) OOLocationManager *locationManager;

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@end

@implementation DWDCurrentDistrictViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"地区";
    
    if (self.type == DWDSelfClassPropertyTypeSelectCityForChangeMeArea) {
        __weak typeof(self) weakSelf = self;
        [self.locationManager startLocationSuccess:^(NSString *areaName, NSString *province, NSString *city, NSString *district) {
            weakSelf.currentLocationName = areaName;
            weakSelf.province = province;
            weakSelf.city = city;
            weakSelf.district = district;
            
            [weakSelf.tableView reloadData];
        }];
 
    }
    
    [DWDClassDataHandler getDistrictWithDistrictCode:@"000000" subdistrict:@1 success:^(NSMutableArray *data) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"获取省份地区成功!";
        hud.animationType = MBProgressHUDAnimationZoomOut;
        [hud show:YES];
        [hud hide:YES afterDelay:1.0];
        
        [self.districts addObjectsFromArray:data];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
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

- (OOLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[OOLocationManager alloc] init];
    }
    return _locationManager;
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
        cell.currentLocation = self.currentLocationName ? self.currentLocationName : @"定位中..";
     
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0){
        if (self.type == DWDSelfClassPropertyTypeSelectCityForChangeMeArea) {
            if (self.currentLocationName.length == 0 || [self.currentLocationName isEqualToString:@"定位中.."]) {
                return;
            }
            //reqeust
            [self requestLocationWithCode];
        }
        else{
            return;
        }
    }
    else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"正在获取城市,请稍候...";
        DWDDistrictModel *province = self.districts[indexPath.row];
        
        [DWDClassDataHandler getDistrictWithDistrictCode:province.regionCode subdistrict:@1 success:^(NSMutableArray *data) {
            
            [self.cityArray addObjectsFromArray:data];
            hud.labelText = @"获取成功!";
            [hud hide:YES afterDelay:1.0];
            // 跳转
            DWDAddNewClassCityViewController *cityVc = [[DWDAddNewClassCityViewController alloc] init];
            cityVc.provinceName = province.name;
            cityVc.cityArray = self.cityArray;
            cityVc.destinationVc = _destinationVc;
            
            if (self.type == DWDSelfClassPropertyTypeSelectCityForChangeMeArea) {
                cityVc.type = DWDSelfClassPropertyTypeSelectCityForChangeMeArea;
            }
            [self.navigationController pushViewController:cityVc animated:YES];
            
        } failure:^(NSError *error) {
            hud.labelText = @"获取失败!";
            [hud hide:YES afterDelay:1.0];
        }];
    }
    
}

#pragma mark - Request
- (void)requestLocationWithCode{
    NSDictionary *params;
    if (self.district.length > 0) {
        
        params = @{@"province" : self.province,
                   @"city" : self.city,
                   @"district" : self.district};
    }else{
        
        params = @{@"province" : self.province,
                   @"city" : self.city};
    }
    
    [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntityByName" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arr = responseObject[@"data"];
        NSString *detailRegionCode = [arr firstObject][@"districtCode"];
     
        //request commit area
        [[DWDCustInfoClient sharedCustInfoClient]
         requestUpdateWithRegionName:detailRegionCode
         success:^(id responseObject)
         {
             [self.navigationController popViewControllerAnimated:YES];
             
         }];

        //[self.navigationController popViewControllerAnimated:YES];
        return ;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [DWDProgressHUD showText:@"修改失败" afterDelay:1.0];
    }];

}
@end
