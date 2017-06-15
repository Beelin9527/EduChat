//
//  DWDRegisterViewController.h
//  EduChat
//
//  Created by apple on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//  注册ViewController

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,DWDRegisterType) {
    DWDRegisterTypeTeacher,DWDRegisterTypeParent
};
@interface DWDRegisterViewController : UIViewController

@property (strong, nonatomic) NSNumber *courseTag;//科目标识
@property (assign, nonatomic) DWDRegisterType registerType;
@end
