//
//  DWDPrivacyManager.h
//  EduChat
//
//  Created by KKK on 16/10/21.
//  Copyright © 2016年 dwd. All rights reserved.
//
/**
 权限控制器
 控制关于 相机, 麦克风, 相册, 定位的权限
 
 逻辑
 要进行需要权限的操作时, 先走方法进行权限检测
 如果权限是未选择,那由系统方法弹出alertController, 操作后会重启(定位除外)
 如果权限是拒绝(),那弹出自定义讯息的alertController,跳转到设置
 如果是通过,跳转到通过block回调
 
 注意
 定位权限因为其api的特殊性需要单独处理,无法用给定接口
 */

#import <Foundation/Foundation.h>
@class CLLocationManager;

@interface DWDPrivacyManager : NSObject

typedef NS_ENUM(NSInteger, DWDPrivacyType) {
    DWDPrivacyTypeCamera,  //相机权限
    DWDPrivacyTypeMicroPhone,  //麦克风权限
    DWDPrivacyTypePhotoLibrary,  //相册权限
    DWDPrivacyTypeContacts,  //通讯录权限
    
   
    //定位走单独方法
    DWDPrivacyTypeLocation,
};

+ (instancetype)shareManger;

/**
 检测权限是否通过

 @param privacyType        除定位权限外所有type
 @param vc                 当前控制器 如果在view内,利用分类方法[view viewController]
 @param authorizedCallback 权限允许回调
 */
- (void)needPrivacy:(DWDPrivacyType)privacyType
     withController:(UIViewController *)vc
         authorized:(void(^)())authorizedCallback;


/**
 录像功能权限

 */
- (void)VideoRecordPrivacyWithController:(UIViewController *)vc
                              authorized:(void(^)())authorizedCallback;


/**
 展示拒绝权限的alertController

 @param type 请求权限类型
 @param vc   控制器
 */
- (void)showAlertViewWithType:(DWDPrivacyType)type viewController:(UIViewController *)vc;

@end
