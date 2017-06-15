//
//  DWDSelectRegisterIdView.h
//  EduChat
//
//  Created by Gatlin on 16/1/20.
//  Copyright © 2016年 dwd. All rights reserved.
//  选择注册身份 View

#import <UIKit/UIKit.h>

@interface DWDSelectRegisterIdView : UIView
@property (strong, nonatomic) id target;
@property (assign, nonatomic) SEL selectTeacherSubjectAction;
@property (assign, nonatomic) SEL selectParentAction;
@property (assign, nonatomic) SEL selectCancleAction;
+ (instancetype)selectRegisterIdView;
@end
