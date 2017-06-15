//
//  OOLocationManager.m
//  EduChat
//
//  Created by Gatlin on 16/6/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "OOLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface OOLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, copy) callBolck successBlock;


@end
@implementation OOLocationManager

#pragma mark - Getter
- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

#pragma mark - Public Method
- (void)startLocationSuccess:(callBolck)success{
    
    _successBlock = success;
    
    //是否启用定位服务，通常如果用户没有启用定位服务可以提示用户打开定位服务
//    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"定位服务尚未打开，若要定位请设置打开！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        return;
//    }
  
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        //请求授权
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
    }else if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
        //设置代理
        self.locationManager.delegate=self;
        //设置定位精度
        self.locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters;
        //定位频率,每隔多少米定位一次
        //CLLocationDistance distance=10.0;//十米定位一次
        //_locationManager.distanceFilter=distance;
        //启动跟踪定位
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CoreLocation Delegate
#pragma mark 跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
//可以通过模拟器设置一个虚拟位置，否则在模拟器中无法调用此方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //如果不需要实时定位，使用完即使关闭定位服务
    [self.locationManager stopUpdatingLocation];
    
    CLLocation *location=[locations lastObject];//取出最后一个位置
   
    __weak typeof(self) weakSelf = self;
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                           
                            CLPlacemark *placemark=[placemarks lastObject];
                            NSString *administrativeArea=placemark.administrativeArea; // 州、省
                            NSString *locality=placemark.locality; // 城市
                            NSString *subLocality=placemark.subLocality; //其他行政区域信息
                            
                            NSMutableString *areaName = [NSMutableString stringWithFormat:@""];
                            if (administrativeArea) {
                                [areaName appendString:administrativeArea];
                            }
                            if (locality) {
                                 [areaName appendString:locality];
                            }
                            if (subLocality) {
                                 [areaName appendString:subLocality];
                            }
                            
                            //call back
                            __strong typeof(self) strongSelf = weakSelf;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 strongSelf.successBlock(areaName,administrativeArea,locality,subLocality);
                            });
                           
                        }];
    
}
@end
