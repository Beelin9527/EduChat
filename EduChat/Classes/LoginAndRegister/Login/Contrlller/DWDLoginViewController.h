//
//  DWDLoginViewController.h
//  EduChat
//
//  Created by Gatlin on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//  登录ViewController

#import <UIKit/UIKit.h>

@class DWDLoginViewController;

@protocol DWDLoginViewControllerDelegate <NSObject>

@optional
- (void)presentControllerDidDismiss:(DWDLoginViewController *)vc;

@end

@interface DWDLoginViewController : UIViewController

@property (nonatomic, weak) id<DWDLoginViewControllerDelegate> delegate;

@end
