//
//  DWDIntAlertView.h
//  EduChat
//
//  Created by Beelin on 16/12/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDIntAlertViewModel;
@interface DWDIntAlertView : UIView
@property (nonatomic, strong) DWDIntAlertViewModel *model;
@end

@interface DWDIntAlertViewModel : NSObject
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *btntext;
@end
