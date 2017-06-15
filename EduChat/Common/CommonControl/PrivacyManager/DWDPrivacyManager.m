//
//  DWDPrivacyManager.m
//  EduChat
//
//  Created by KKK on 16/10/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

@import Photos;
@import AddressBook;
@import Contacts;

#import "DWDPrivacyManager.h"

#import <SDVersion.h>

@implementation DWDPrivacyManager

#pragma mark - Public Method
+ (instancetype)shareManger {
    static DWDPrivacyManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWDPrivacyManager alloc] init];
    });
    return manager;
}



- (void)needPrivacy:(DWDPrivacyType)privacyType
     withController:(UIViewController *)vc
         authorized:(void (^)())authorizedCallback {
    
    switch (privacyType) {
        case DWDPrivacyTypeCamera:
            [self cameraPrivacyWithController:vc authorized:authorizedCallback];
            break;
            
        case DWDPrivacyTypeMicroPhone:
            [self microPhonePrivacyWithController:vc authorized:authorizedCallback];
            break;
            
        case DWDPrivacyTypePhotoLibrary:
            [self photoLibraryPrivacyWithController:vc authorized:authorizedCallback];
            break;
            
        case DWDPrivacyTypeContacts:
            [self contactsPrivacyWithController:vc authorized:authorizedCallback];
            break;

        default:
            break;
    }
}

- (void)cameraPrivacyWithController:(UIViewController *)vc
                         authorized:(void (^)())authorizedCallback {
//    typedef NS_ENUM(NSInteger, AVAuthorizationStatus) {
//        AVAuthorizationStatusNotDetermined = 0, //未选择
//        AVAuthorizationStatusRestricted,
//        AVAuthorizationStatusDenied,
//        AVAuthorizationStatusAuthorized
//    } NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;
    
     AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    authorizedCallback();
                }
            }];
            break;
        }

        case AVAuthorizationStatusRestricted:
            [self showAlertViewWithType:DWDPrivacyTypeCamera viewController:vc];
            break;
            
        case AVAuthorizationStatusDenied:
            [self showAlertViewWithType:DWDPrivacyTypeCamera viewController:vc];
            break;
            
        case AVAuthorizationStatusAuthorized: {
            dispatch_async(dispatch_get_main_queue(), ^{
                authorizedCallback();
            });
            break;
        }
            
        default:
            break;
    }
    
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
    
}

- (void)VideoRecordPrivacyWithController:(UIViewController *)vc
                              authorized:(void(^)())authorizedCallback {
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (cameraStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self needPrivacy:DWDPrivacyTypeMicroPhone withController:vc authorized:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedCallback();
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertViewWithType:DWDPrivacyTypeCamera viewController:vc];
                });
            }
        }];
    } else if (cameraStatus == AVAuthorizationStatusRestricted || cameraStatus == AVAuthorizationStatusDenied) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertViewWithType:DWDPrivacyTypeCamera viewController:vc];
        });
    } else if (cameraStatus == AVAuthorizationStatusAuthorized) {
        [self needPrivacy:DWDPrivacyTypeMicroPhone withController:vc authorized:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                authorizedCallback();
            });
        }];
    }
}

- (void)microPhonePrivacyWithController:(UIViewController *)vc
                             authorized:(void (^)())authorizedCallback {
    //    typedef NS_ENUM(NSInteger, AVAuthorizationStatus) {
    //        AVAuthorizationStatusNotDetermined = 0,
    //        AVAuthorizationStatusRestricted,
    //        AVAuthorizationStatusDenied,
    //        AVAuthorizationStatusAuthorized
    //    } NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;
    
//    AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    authorizedCallback();
                });
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
            [self showAlertViewWithType:DWDPrivacyTypeMicroPhone viewController:vc];
            break;
            
        case AVAuthorizationStatusDenied:
            [self showAlertViewWithType:DWDPrivacyTypeMicroPhone viewController:vc];
            break;
            
        case AVAuthorizationStatusAuthorized: {
            dispatch_async(dispatch_get_main_queue(), ^{
                authorizedCallback();
            });
            break;
        }
            
        default:
            break;
    }
}

- (void)photoLibraryPrivacyWithController:(UIViewController *)vc
                               authorized:(void (^)())authorizedCallback {
//    typedef NS_ENUM(NSInteger, PHAuthorizationStatus) {
//        PHAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
//        PHAuthorizationStatusRestricted,        // This application is not authorized to access photo data.
//        // The user cannot change this application’s status, possibly due to active restrictions
//        //   such as parental controls being in place.
//        PHAuthorizationStatusDenied,            // User has explicitly denied this application access to photos data.
//        PHAuthorizationStatusAuthorized         // User has authorized this application to access photos data.
//    } NS_AVAILABLE_IOS(8_0);
    
     PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        authorizedCallback();
                    });
                }
            }];
            break;
        }
            
        case PHAuthorizationStatusRestricted:
            [self showAlertViewWithType:DWDPrivacyTypePhotoLibrary viewController:vc];
            break;
            
        case PHAuthorizationStatusDenied:
            [self showAlertViewWithType:DWDPrivacyTypePhotoLibrary viewController:vc];
            break;
            
        case PHAuthorizationStatusAuthorized: {
            dispatch_async(dispatch_get_main_queue(), ^{
                authorizedCallback();
            });
            break;
        }
            
        default:
            break;
    }
}

- (void)contactsPrivacyWithController:(UIViewController *)vc
                           authorized:(void(^)())authorizedCallback {
    if (iOSVersionLessThan(@"9.0")) { //iOS 9.0以前和9.0以及以后不同
        //< iOS 9
        //ABAddressBook
        __block ABAddressBookRef abaddress = ABAddressBookCreateWithOptions(NULL, NULL);
        if (abaddress == NULL) return;
        
        ABAddressBookRequestAccessWithCompletion(abaddress, ^(bool granted, CFErrorRef error) {
            if (granted) {
                authorizedCallback();
            } else {
                [self showAlertViewWithType:DWDPrivacyTypeContacts viewController:vc];
            }
            if (abaddress) {
                CFRelease(abaddress);
                abaddress = NULL;
            }
        });
    } else {
        //≥ iOS 9
        //CNContact
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                authorizedCallback();
            } else {
                [self showAlertViewWithType:DWDPrivacyTypeContacts viewController:vc
                 ];
            }
        }];
    }
}

- (void)needLocationPrivacyWithController:(UIViewController *)vc
                          locationManager:(CLLocationManager *)manager
                               authorized:(void (^)())authorizedCallback {
    
//    用户从未选择过权限
//    kCLAuthorizationStatusNotDetermined
//    
//    无法使用定位服务，该状态用户无法改变
//    kCLAuthorizationStatusRestricted
//    
//    用户拒绝该应用使用定位服务，或是定位服务总开关处于关闭状态
//    kCLAuthorizationStatusDenied
//    
//    用户允许该程序无论何时都可以使用地理信息
//    kCLAuthorizationStatusAuthorizedAlways
//    
//    用户同意程序在可见时使用地理位置
//    kCLAuthorizationStatusAuthorizedWhenInUse
}

#pragma mark - 拒绝权限提醒

- (void)showAlertViewWithType:(DWDPrivacyType)type viewController:(UIViewController *)vc {
    NSString *titleString;
    NSString *msgString;
    NSURL *jumpURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    switch (type) {
        case DWDPrivacyTypeCamera:
        {
            titleString = @"“多维度”无权限访问您的相机";
            msgString = @"进入设置->“多维度”应用->允许访问“相机”";
            break;
        }
        case DWDPrivacyTypeMicroPhone:
        {
            titleString = @"“多维度”无权限访问您的麦克风";
            msgString = @"进入设置->“多维度”应用->允许访问“麦克风”";
            break;
        }
        case DWDPrivacyTypePhotoLibrary:
        {
            titleString = @"“多维度”无权限访问您的相册";
            msgString = @"进入设置->“多维度”应用->允许访问“相册”";
            break;
        }
        case DWDPrivacyTypeLocation:
        {
            titleString = @"“多维度”无权限访问您的位置";
            msgString = @"进入设置->“多维度”应用->允许访问“位置”";
            break;
        }
        case DWDPrivacyTypeContacts:
        {
            titleString = @"“多维度”无权限访问您的通讯录";
            msgString = @"进入设置->“多维度”应用->允许访问“通讯录";
            break;
        }
        default:
            break;
    }
    
    
    UIAlertController *alctr = [UIAlertController alertControllerWithTitle:titleString message:msgString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *pushSettingAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] canOpenURL:jumpURL]) {
            [[UIApplication sharedApplication] openURL:jumpURL];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alctr addAction:pushSettingAction];
    [alctr addAction:cancelAction];
    [vc presentViewController:alctr animated:YES completion:nil];
}
@end
