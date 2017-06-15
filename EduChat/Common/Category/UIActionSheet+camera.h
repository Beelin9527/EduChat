//
//  UIActionSheet+camera.h
//  EduChat
//
//  Created by Gatlin on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//  调用相机 分类 封装

#import <UIKit/UIKit.h>

@interface UIActionSheet (camera)<UIActionSheetDelegate>
@property (nonatomic, weak) id targer; //目标 ViewController

/** 类方法 */
+ (instancetype)showCameraActionSheet;
@end
