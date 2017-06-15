//
//  DWDClassChangeClassNameViewController.h
//  EduChat
//
//  Created by Gatlin on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDClassChangeClassNameViewController,DWDClassModel;
@protocol DWDClassChangeClassNameViewControllerDelegate <NSObject>

/** 返回上一级修改备注名 */
- (void)classChangeMyNicknameViewController:(DWDClassChangeClassNameViewController *)selfViewController doneRemarkName:(NSString *)doneRemarkName;

@end
@interface DWDClassChangeClassNameViewController : UIViewController
@property (strong, nonatomic) DWDClassModel *classModel;


@property (nonatomic,weak) id<DWDClassChangeClassNameViewControllerDelegate> delegate;
@end
