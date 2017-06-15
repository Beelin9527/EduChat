//
//  DWDMyChildInfoViewController.h
//  EduChat
//
//  Created by Gatlin on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDMyChildListEntity;
@interface DWDMyChildInfoViewController : UITableViewController
@property (strong, nonatomic) NSNumber *childCustId;
@property (strong, nonatomic) DWDMyChildListEntity *myChildListEntity;
@end

