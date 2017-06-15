//
//  DWDSetupChildEduchatViewController.h
//  EduChat
//
//  Created by Gatlin on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDSetupChildEduchatViewController;
@protocol DWDSetupChildEduchatViewControllerDelegate <NSObject>

@required
- (void)setupChildEduchatViewController:(DWDSetupChildEduchatViewController *)SetupChildEduchatViewController childName:(NSString *)childName educhatAccount:(NSString *)educhatAccount;

@end

@interface DWDSetupChildEduchatViewController : UITableViewController
@property (nonatomic,weak) id<DWDSetupChildEduchatViewControllerDelegate> delegate;
@end
