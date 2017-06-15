//
//  DWDContactsInviteSearchResultTableViewController.h
//  EduChat
//
//  Created by KKK on 16/11/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDContactInviteModel, DWDContactsInviteSearchResultTableViewController;

@protocol DWDContactsInviteSearchResultTableViewControllerDelegate <NSObject>

@optional
- (void)contactsInviteSearchResultControllerDidScrollTableView:(DWDContactsInviteSearchResultTableViewController *)vc;

- (void)contactsInviteSearchResultController:(DWDContactsInviteSearchResultTableViewController *)vc
                                  didInvited:(DWDContactInviteModel *)model;

@end

@interface DWDContactsInviteSearchResultTableViewController : UITableViewController

@property (nonatomic, weak) id<DWDContactsInviteSearchResultTableViewControllerDelegate> controllerDelegate;

- (void)reloadResultArray:(NSArray <DWDContactInviteModel *>*)resultArray;

@end
