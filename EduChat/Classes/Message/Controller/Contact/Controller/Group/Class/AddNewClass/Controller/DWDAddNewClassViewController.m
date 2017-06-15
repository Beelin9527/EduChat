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
#import "DWDChatController.h"
#import "DWDClassIntroductionCell.h"
#import "DWDAddNewClassLabel.h"
#import "DWDNearbySchoolModel.h"
#import "DWDNearBySelectedSchoolClassModel.h"
#import "DWDClassDataHandler.h"

@interface DWDAddNewClassViewController () <CLLocationManagerDelegate , UITextViewDelegate>

@property (nonatomic , copy  ) NSString          *province;
@property (nonatomic , copy  ) NSString          *cityName;
@property (nonatomic , strong) CLLocationManager *mgr;
@property (nonatomic , strong) CLGeocoder        *coder;
@property (nonatomic , strong) MBProgressHUD     *hud;
@property (nonatomic , strong) DWDCurrentDistrictViewController *currentDistrictVc;

@property (nonatomic , copy  ) NSString *currentLocation;
@property (nonatomic , copy  ) NSString *regionName;
@property (nonatomic , copy  ) NSString *detailRegionCode;

@property (nonatomic , copy  ) NSString *schoolName;
@property (nonatomic , strong) NSNumber *schoolId;

@property (nonatomic , assign) CGFloat  beyondHeight;

@property (nonatomic , copy  ) NSString *districtDetailLabeltext;

@property (nonatomic , weak  ) DWDAddNewClassIntroductionField *introductionTextView;

@property (nonatomic , assign) int introduceTextCount;

@property (nonatomic , strong) DWDNearBySelectedSchoolClassModel *selectedClass;


@end

@implementation DWDAddNewClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新建班级";
    self.tableView.backgroundColor = DWDRGBColor(242, 242, 242);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
//    self.navigationItem.rightBarButtonItem.enabled = NO;  // 使用了"KMNavigationBarTransition" 之后 导航栏的按钮设置enable不管用了
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChange:) name:DWDDWDCityNameDidSelectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedSchool:) name:DWDSearchSchoolAndClassControllerSelectSchoolNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedSchoolId:) name:@"searchControllerDidSelectedSchoolId" object:nil];
    
    
    [self.mgr startUpdatingLocation];
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//    hud.labelText = @"正在定位当前位置,请稍候...";
//    hud.animationType = MBProgressHUDAnimationZoomOut;
//    [hud show:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if ([hud.labelText isEqualToString:@"正在定位当前位置,请稍候..."]) {
//            hud.labelText = @"定位失败!请重试";
//            [hud hide:YES afterDelay:1.0];
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    });
//    _hud = hud;
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    if (!_regionName && !_cityName) {
//        [self.mgr startUpdatingLocation];
//    }
//}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - 创建班级
- (void)rightBarBtnClick
{
    if (_schoolName && _selectedClass) {
        
        [DWDClassDataHandler createClassWithSchoolId:_schoolId className:[_selectedClass.name trim] introduce:[_introductionTextView.text trim] standardId:_selectedClass.standardId success:^(DWDClassModel *class) {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
            DWDChatController *chatVc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
            chatVc.chatType = DWDChatTypeClass;
            chatVc.toUserId = class.classId;
            chatVc.myClass  = class;
            [self.navigationController pushViewController:chatVc animated:YES];
            
        } failure:^(NSError *error) {

        }];
        
        [DWDClassDataHandler createSchoolWithFullName:_schoolName type:@5 districtCode:_detailRegionCode success:^(NSNumber *schoolId) {
            
            //                    _schoolId = schoolId;
        } failure:^(NSError *error) {
            
        }];
        
    }else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"您还没有选择班级,请先选择班级";
        [hud show:YES];
        [hud hide:YES afterDelay:2.0];
    }
}

#pragma mark - 定位授权
//- (void)getAuthorization{
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (status == kCLAuthorizationStatusNotDetermined) {
//        if ([self.mgr respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//            [self.mgr requestAlwaysAuthorization];
//        }
//    }
//}

//- (void)getAuthorization{
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if (status == kCLAuthorizationStatusNotDetermined) {
//        if ([self.mgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//            [self.mgr requestWhenInUseAuthorization];
//        }
//    }else if (status == kCLAuthorizationStatusDenied){
//        // iOS8.4+
//        if ([IOS_SYSTEM_STRING floatValue] > 8.4) {
//            
//            [DWDProgressHUD showText:@"请到系统设置处打开定位服务" afterDelay:2.0];
//            
////            [self.navigationController popViewControllerAnimated:YES];
//            
//        }else{// ios8.4- 需要截图提醒引导用户
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"定位服务尚未打开，若要定位请到设置打开定位服务！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
//        }
////        if (![CLLocationManager locationServicesEnabled]) { // 系统级别不允许定位
////            
////        }
//    }else{
//        
//        _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
//        _hud.labelText = @"正在定位当前位置,请稍候...";
//        _hud.animationType = MBProgressHUDAnimationZoomOut;
//        [_hud show:YES];
//
//    }
//}

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

#pragma mark - Private

#pragma mark - <Notification>

- (void)didSelectedSchoolId:(NSNotification *)note{
    _schoolId = note.userInfo[@"schoolId"];
}

- (void)selectedSchool:(NSNotification *)note{
    _schoolName = note.userInfo[@"fullName"];
//    _schoolId = note.userInfo[@"schoolId"];
    _selectedClass = note.userInfo[@"className"];
    
    if (_selectedClass.name.length > 0 && _schoolName.length > 0) {
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
            if (_schoolName && _selectedClass.name) {
                NSString *name = [NSString stringWithFormat:@"%@/%@",_schoolName,_selectedClass.name];
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
        _introductionTextView.delegate = self;
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
        return pxToH(214) + 200;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 区域
        if (!_currentDistrictVc) {
            DWDCurrentDistrictViewController *districtVc = [[DWDCurrentDistrictViewController alloc] init];
            districtVc.destinationVc = self;
            districtVc.currentLocationName = @"未开启定位服务";
            _currentDistrictVc = districtVc;
        }
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
                                   @"city" : _cityName};
                }
                
                [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntityByName" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
                    NSArray *arr = responseObject[@"data"];
                    _detailRegionCode = [arr firstObject][@"districtCode"];
                    DWDSearchSchoolAndClassController *searchSchoolClassVc = [[UIStoryboard storyboardWithName:@"DWDSearchSchoolAndClassController" bundle:nil] instantiateViewControllerWithIdentifier:@"DWDSearchSchoolAndClassController"];
                    searchSchoolClassVc.detailRegionCode = _detailRegionCode;
                    searchSchoolClassVc.province = _province;
                    searchSchoolClassVc.cityName = _cityName;
                    searchSchoolClassVc.regionName = _regionName;
                    searchSchoolClassVc.selectSchoolName = _schoolName;
                    searchSchoolClassVc.selectClassName = _selectedClass.name;
                    searchSchoolClassVc.schoolId = _schoolId;
                    
                    [self.navigationController pushViewController:searchSchoolClassVc animated:YES];
                    return ;
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    [DWDProgressHUD showText:@"该区域暂无对应学校" afterDelay:1.0];
                }];
            }else{   // 自己动手选过省市区
                DWDSearchSchoolAndClassController *searchSchoolClassVc = [[UIStoryboard storyboardWithName:@"DWDSearchSchoolAndClassController" bundle:nil] instantiateViewControllerWithIdentifier:@"DWDSearchSchoolAndClassController"];
                searchSchoolClassVc.detailRegionCode = _detailRegionCode;
                searchSchoolClassVc.province = _province;
                searchSchoolClassVc.cityName = _cityName;
                searchSchoolClassVc.regionName = _regionName;
                searchSchoolClassVc.selectSchoolName = _schoolName;
                searchSchoolClassVc.selectClassName = _selectedClass.name;
                searchSchoolClassVc.schoolId = _schoolId;
                
                [self.navigationController pushViewController:searchSchoolClassVc animated:YES];
            }
            
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
        districtVc.destinationVc = self;
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
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"定位完毕!";
        [_hud hide:YES afterDelay:1.0];
    }];
    [self.mgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.mgr requestWhenInUseAuthorization];
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DWDPrivacyManager shareManger] showAlertViewWithType:DWDPrivacyTypeLocation viewController:self];
        });
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = @"正在定位当前位置,请稍候...";
        _hud.animationType = MBProgressHUDAnimationZoomOut;
        [_hud show:YES];
        [self.mgr startUpdatingLocation];
    }
}

// 常规思路
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"定位错误,请重试";
        [_hud hide:YES];
    });
    
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    DWDLog(@"xixixixix%@xixixixix%zd" , text , text.length);
    
    NSArray *arr = [textView.text componentsSeparatedByString:@"\n"];
    
    if ([text isEqualToString:@"\n"] && arr.count > 18) {
        [DWDProgressHUD showText:@"换行已超出范围" afterDelay:0.5];
        return NO;
    }
//
//    if (textView.text.length + text.length > 300 && text.length != 0) {
//        [DWDProgressHUD showText:@"字数已超过300" afterDelay:0.5];
//        return NO;
//    }
//    
//    if (text.length > 0) {
//        _introduceTextCount += text.length;
//        _introductionTextView.str2Count = _introduceTextCount;
//    }else if(text.length <= 0 && range.length == 1){
//        _introduceTextCount--;
//        _introductionTextView.str2Count = _introduceTextCount;
//    }else if(text.length <= 0 && range.length == textView.text.length){
//        _introduceTextCount = 0;
//        _introductionTextView.str2Count = _introduceTextCount;
//    }else{
//        _introduceTextCount-=range.length - 1;
//        _introductionTextView.str2Count = _introduceTextCount;
//    }
    return YES;
}

// 防止中文输入无限联想
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *toBeString = textView.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 300)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:300];
            if (rangeIndex.length == 1)
            {
                [DWDProgressHUD showText:@"字数已超过300" afterDelay:0.5];
                textView.text = [toBeString substringToIndex:300];
            }
            else
            {
                [DWDProgressHUD showText:@"字数已超过300" afterDelay:0.5];
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 300)];
                textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
        _introductionTextView.str2Count = (int)textView.text.length <= 300 ? (int)textView.text.length : 300;
    }
}

@end
