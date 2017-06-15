//
//  DWDRQViewController.h
//  EduChat
//
//  Created by Gatlin on 16/1/28.
//  Copyright © 2016年 dwd. All rights reserved.
//  二维码 ViewController

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,DWDQRType) {
    DWDQRTypePerson,
    DWDQRTypeGroup,
    DWDQRTypeClass
};
@interface DWDQRViewController : UIViewController
@property (copy, nonatomic) NSString *info;
@property (nonatomic, strong) UIImage *image;   //头像
@property (copy, nonatomic) NSString *nickname; //昵称
@property (nonatomic, assign) DWDQRType type;
@end
