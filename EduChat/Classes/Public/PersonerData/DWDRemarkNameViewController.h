//
//  DWDRemarkNameViewController.h
//  EduChat
//
//  Created by Gatlin on 16/2/4.
//  Copyright © 2016年 dwd. All rights reserved.
//  备注好友 ViewController

#import <UIKit/UIKit.h>
@class DWDRemarkNameViewController;
@protocol DWDRemarkNameViewControllerDelegate <NSObject>

/** 返回上一级修改备注名 */
- (void)remarkNameViewController:(DWDRemarkNameViewController *)remarkNameViewController doneRemarkName:(NSString *)doneRemarkName;

@end
@interface DWDRemarkNameViewController : UIViewController

@property (strong, nonatomic) NSNumber *friendId;       //好友ID
@property (copy, nonatomic) NSString *friendRemarkName; //备注名
@property (copy, nonatomic) NSString *nickname; //昵称

@property (nonatomic,weak) id<DWDRemarkNameViewControllerDelegate> delegate;
@end


