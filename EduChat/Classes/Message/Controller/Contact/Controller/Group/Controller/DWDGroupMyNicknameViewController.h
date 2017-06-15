//
//  DWDGroupMyNicknameViewController.h
//  EduChat
//
//  Created by Gatlin on 16/2/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDGroupEntity,DWDGroupMyNicknameViewController;
@protocol DWDGroupMyNicknameViewControllerDelegate <NSObject>

@optional
- (void)groupMyNicknameViewController:(DWDGroupMyNicknameViewController *)groupMyNicknameViewController myGroupNickname:(NSString *)myGroupNickname;

@end
@interface DWDGroupMyNicknameViewController : UIViewController

@property (strong, nonatomic) DWDGroupEntity *groupModel;
@property (nonatomic,weak) id <DWDGroupMyNicknameViewControllerDelegate> delegate;
@end
