//
//  DWDClassSourceHomeWorkViewController.h
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDClassModel;

@interface DWDClassSourceHomeWorkViewController : UIViewController

@property (strong, nonatomic) NSNumber *classId;

@property (strong, nonatomic) DWDClassModel *classModel;

@end
