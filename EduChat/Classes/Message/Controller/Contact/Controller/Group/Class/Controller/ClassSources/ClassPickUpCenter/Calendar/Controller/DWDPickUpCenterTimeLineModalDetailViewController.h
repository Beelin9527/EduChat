//
//  DWDPickUpCenterTimeLineModalDetailViewController.h
//  EduChat
//
//  Created by KKK on 16/3/28.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDPickUpCenterDataBaseModel;
@class DWDPickUpCenterTimeLineModalDetailViewController;

@protocol DWDPickUpCenterTimeLineModalDetailViewControllerDelegate <NSObject>

@optional
- (void)controllerShouldDismiss:(DWDPickUpCenterTimeLineModalDetailViewController *)controller;

@end

@interface DWDPickUpCenterTimeLineModalDetailViewController : UIViewController

@property (nonatomic, strong) DWDPickUpCenterDataBaseModel *dataModel;

@property (nonatomic, weak) id<DWDPickUpCenterTimeLineModalDetailViewControllerDelegate> delegate;

@end
