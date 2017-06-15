//
//  DWDPickUpCenterTimeLineTableViewController.h
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDPickUpCenterTimeLineTableViewController : UITableViewController

// 0 上学 1 放学
@property (nonatomic, assign) NSInteger state;

@property (nonatomic, strong) NSNumber *classId;

@property (nonatomic, assign) BOOL requestSucceed;

/**
 *  点击日期按钮
 *
 *  @param dateStr 日期字符串
 */
- (void)reloadDataWithDate:(NSString *)dateStr;

@end
