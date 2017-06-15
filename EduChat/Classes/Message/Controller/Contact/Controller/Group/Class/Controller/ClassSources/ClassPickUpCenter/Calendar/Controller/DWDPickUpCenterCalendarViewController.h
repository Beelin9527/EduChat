//
//  DWDPickUpCenterCalendarViewController.h
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDPickUpCenterCalendarViewController : UIViewController

/**
 *  进入状态 0 上学 1 放学
 */
@property (nonatomic, assign) NSInteger timeState;

@property (nonatomic, strong) NSNumber *classId;

@end
