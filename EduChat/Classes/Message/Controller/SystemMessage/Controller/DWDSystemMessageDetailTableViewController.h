//
//  DWDSystemMessageDetailTableViewController.h
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

@class DWDSystemMessageDetailTableViewController, DWDSystemMessageDetailModel;
#import <UIKit/UIKit.h>


@protocol DWDSystemMessageDetailTableViewControllerDelegate <NSObject>

- (void)systemMessageDetailController:(DWDSystemMessageDetailTableViewController *)controller didChangeVerifyState:(NSNumber *)state;

@end

@interface DWDSystemMessageDetailTableViewController : UITableViewController

@property (nonatomic, strong) DWDSystemMessageDetailModel *data;

@property (nonatomic, weak) id<DWDSystemMessageDetailTableViewControllerDelegate> eventDelegate;

@end
