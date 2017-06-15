//
//  DWDGroupNameSetupViewController.h
//  EduChat
//
//  Created by Gatlin on 15/12/22.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDGroupNameSetupViewController,DWDGroupEntity;
@protocol DWDGroupNameSetupViewControllerDelegate <NSObject>

@optional
- (void)groupNameSetupViewController:(DWDGroupNameSetupViewController *)groupNameSetupViewController groupName:(NSString *)groupName;

@end
@interface DWDGroupNameSetupViewController : UIViewController

@property (strong, nonatomic) DWDGroupEntity *groupModel;

@property (nonatomic,weak) id <DWDGroupNameSetupViewControllerDelegate> delegate;
@end
