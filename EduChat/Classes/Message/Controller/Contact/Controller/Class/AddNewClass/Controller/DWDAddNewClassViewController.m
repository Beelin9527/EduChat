//
//  DWDAddNewClassViewController.m
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "DWDAddNewClassViewController.h"
#import "DWDCurrentDistrictViewController.h"
#import "DWDSearchSchoolAndClassController.h"
#import "DWDSearchSchoolAndClassController.h"

#import "DWDClassIntroductionCell.h"
#import "DWDAddNewClassLabel.h"

#import "DWDNearbySchoolModel.h"
#import "DWDContactsClient.h"
#import <YYModel.h>
#import <MBProgressHUD.h>
@interface DWDAddNewClassViewController () <CLLocationManagerDelegate>
@property (nonatomic , copy) NSString *province;
@property (nonatomic , copy) NSString *cityName;
@property (nonatomic , strong) CLLocationManager *mgr;
@property (nonatomic , strong) CLGeocoder *coder;
@property (nonatomic , strong) MBProgressHUD *hud;
@property (nonatomic , strong) DWDCurrentDistrictViewController *currentDistrictVc;

@property (nonatomic , copy) NSString *currentLocation;
@property (nonatomic , copy) NSString *regionName;
@property (nonatomic , copy) NSString *detailRegionCode;

@property (nonatomic , copy) NSString *schoolName;
@property (nonatomic , copy) NSString *className;
@property (nonatomic , assign) NSUInteger schoolId;


@property (nonatomic , copy) NSString *districtDetailLabeltext;

@property (nonatomic , weak) DWDAddNewClassIntroductionField *introductionTextView;

@end

@implementation DWDAddNewClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
//    self.navigationItem.rightBarButtonItem.enabled = NO;  // 使用了"KMNavigationBarTransition" 之后 导航栏的按钮设置enable不管用了
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChange:) name:DWDDWDCityNameDidSelectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedSchool:) name:DWDSearchSchoolAndClassControllerSelectSchoolNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedClasses:) name:DWDSelectedNearbyClassesNotification object:nil];
    
    [self getAuthorization];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = @"正在定位当前位置,请稍候...";
    hud.animationType = MBProgressHUDAnimationZoomOut;
    [hud show:YES];
    _hud = hud;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_regionName && !_cityName) {
        [self.mgr startUpdatingLocation];
    }
}

- (void)rightBarBtnClick{
    DWDLogFunc;
    if (_schoolName && _className) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"正在创建班级,请稍候...";
        [hud show:YES];
        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                 @"schoolId" : @(_schoolId),
                                 @"className" : _className,
                                 @"introduce" : _introductionTextView.text};
        [[HttpClient sharedClient] postApi:@"ClassRestService/addGradeClass" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            hud.labelText = @"创建班级成功!";
            [hud hide:YES afterDelay:1.0];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:DWDContactUpdateNotification
             object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DWDLog(@"error:%@" , error);
            hud.labelText = @"已经有同名字班级了哦~";
            [hud hide:YES afterDelay:2.0];
        }];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = @"您还没有选择班级,请先选择班级";
        [hud show:YES];
        [hud hide:YES afterDelay:2.0];
    }
    
    
}



- (void)getAuthorization{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([self.mgr respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.mgr requestAlwaysAuthorization];
        }
    }
}

- (CLGeocoder *)coder{
    if (!_coder) {
        _coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}
- (CLLocationManager *)mgr{
    if (!_mgr) {
        _mgr = [[CLLocationManager alloc] init];
        _mgr.delegate = self;
        _mgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _mgr.distanceFilter = 1.0;
    }
    return _mgr;
}

#pragma mark - <Notification>
- (void)selectedSchool:(NSNotification *)note{
    _schoolName = note.userInfo[@"fullName"];
    _schoolId = [note.userInfo[@"schoolId"] unsignedIntegerValue];
    if (_className.length > 0) {
        [self.tableView reloadData];
    }else{
        return;
    }
}

- (void)selectedClasses:(NSNotification *)note{
    _className = note.userInfo[@"name"];
    if (_schoolName.length > 0) {
        [self.tableView reloadData];
    }else{
        return;
    }
}

- (void)cityChange:(NSNotification *)note{
    DWDLog(@"%@",note.userInfo);
    _province = note.userInfo[@"province"];
    _cityName = note.userInfo[@"cityName"];
    _detailRegionCode = note.userInfo[@"regionCode"];
    if (note.userInfo[@"regionName"]) {
        _regionName = note.userInfo[@"regionName"];
    }else{
        _regionName = nil;
    }
    [self.tableView reloadData];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"所在地区";
            cell.textLabel.font = DWDFontContent;
            cell.textLabel.textColor = DWDColorSecondary;
            
            if (_province && _cityName && _regionName) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@",_province,_cityName,_regionName];
            }else if (_province && _cityName){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",_province,_cityName];
            }else{
                cell.detailTextLabel.text = _currentLocation;
            }
            _districtDetailLabeltext = cell.detailTextLabel.text;
            cell.detailTextLabel.font = DWDFontBody;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.textLabel.text = @"学校/班级";
            cell.textLabel.font = DWDFontContent;
            cell.textLabel.textColor = DWDColorSecondary;
            if (_schoolName && _className) {
                NSString *name = [NSString stringWithFormat:@"%@/%@",_schoolName,_className];
                cell.detailTextLabel.text = name;
            }else{
                cell.detailTextLabel.text = @"您任教的学校/班级";
            }
            
            cell.detailTextLabel.font = DWDFontContent;
            cell.detailTextLabel.textColor = DWDColorSecondary;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else{
        DWDClassIntroductionCell * cell = [[DWDClassIntroductionCell alloc] init];
        _introductionTextView = cell.textView;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    DWDAddNewClassLabel *label = [[DWDAddNewClassLabel alloc] init];
    if (section == 0) {
        label.text = @"基本信息";
    }else{
        label.text = @"班级介绍";
    }
    [label sizeToFit];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return pxToH(66);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return pxToH(88);
    }else{
        return pxToH(214);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 区域
        [self.navigationController pushViewController:_currentDistrictVc animated:YES];
    }else{
        // 学校/班级
        if (_districtDetailLabeltext.length > 0) {
            [self.view endEditing:YES];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            // 跳转
            if (_detailRegionCode == nil) {  // 没有选过省市区
                NSDictionary *params;
                if (_regionName.length > 0) {
                    params = @{@"province" : _province,
                                             @"city" : _cityName,
                                             @"district" : _regionName};
                }else{
                    params = @{@"province" : _province,
                               @"city" : _cityName,};
                }
                
                [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntityByName" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                    NSArray *arr = responseObject[@"data"];
                    _detailRegionCode = [arr firstObject][@"districtCode"];
                    DWDSearchSchoolAndClassController *searchSchoolClassVc = [[UIStoryboard storyboardWithName:@"DWDSearchSchoolAndClassController" bundle:nil] instantiateViewControllerWithIdentifier:@"DWDSearchSchoolAndClassController"];
                    searchSchoolClassVc.detailRegionCode = _detailRegionCode;
                    [self.navigationController pushViewController:searchSchoolClassVc animated:YES];
                    return ;
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    DWDLog(@"error : %@" , error);
                }];
            }else{   // 自己动手选过省市区
                DWDSearchSchoolAndClassController *searchSchoolClassVc = [[UIStoryboard storyboardWithName:@"DWDSearchSchoolAndClassController" bundle:nil] instantiateViewControllerWithIdentifier:@"DWDSearchSchoolAndClassController"];
                searchSchoolClassVc.detailRegionCode = _detailRegionCode;
                [self.navigationController pushViewController:searchSchoolClassVc animated:YES];
            }
            
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            [hud show:YES];
            hud.labelText = @"请先定位您当前所在的区域!";
            [hud hide:YES afterDelay:1.5];
        }
    }
    
}

#pragma mark - <CLLocationManagerDelegate>
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = [locations lastObject];
    [self.coder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0){
            _hud.labelText = @"请求超时!请重新定位!";
            [_hud hide:YES afterDelay:1.0];
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }
        DWDCurrentDistrictViewController *districtVc = [[DWDCurrentDistrictViewController alloc] init];
        districtVc.addNewVc = self;
        _currentDistrictVc = districtVc;
        for (CLPlacemark *pm in placemarks) {
            NSString *currentLocationName = [NSString stringWithFormat:@"%@%@%@",pm.administrativeArea,pm.locality,pm.subLocality];
            districtVc.currentLocationName = currentLocationName;
            _province = pm.administrativeArea;
            _cityName = pm.locality;
            _regionName = pm.subLocality;
            _currentLocation = currentLocationName;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
        [self.tableView reloadData];
        _hud.labelText = @"定位完毕!";
        [_hud hide:YES afterDelay:1.0];
    }];
    [self.mgr stopUpdatingLocation];
}
@end
